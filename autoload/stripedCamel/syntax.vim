" Copyright 2013 LuoChen (luochen1990@gmail.com). Licensed under the Apache License 2.0.

function! s:trim(s)
  return substitute(a:s, '\v^\s*(.{-})\s*$', '\1', '')
endfunction

function! s:concat(strs)
  return join(filter(a:strs, 'v:val !~# "^[ ]*$"'), ',')
endfunction

function! s:resolve_parenthesis_with(init_state, p)
  let [
        \ paren,
        \ contained,
        \ containedin,
        \ contains_prefix,
        \ contains,
        \ op] =
        \ a:init_state

  " preprocess the old style syntax_border config
  let p = type(a:p) != type([])
        \ ? a:p
        \ : len(a:p) == 3
        \   ? printf('start=#%s# step=%s end=#%s#', a:p[0], op, a:p[-1])
        \   : printf('start=#%s# end=#%s#', a:p[0], a:p[-1])


  let ls = split(p,
        \ '\v%(%(start|step|end)\=(.)%(\1@!.)*\1[^ ]*|\w+%(\=[^ ]*)?) ?\zs',
        \ 0)

  for s in ls
    let [k, v] = [
          \ matchstr(s, '^[^=]\+\ze\(=\|$\)'),
          \ matchstr(s, '^[^=]\+=\zs.*')
          \ ]
    if k ==# 'step'
      let op = s:trim(v)
    elseif k ==# 'contains_prefix'
      let contains_prefix = s:trim(v)
    elseif k ==# 'contains'
      let contains = s:concat([contains, s:trim(v)])
    elseif k ==# 'containedin'
      let containedin = s:concat([containedin, s:trim(v)])
    elseif k ==# 'contained'
      let contained = 1
    else
      let paren .= s
    endif
  endfor
  let rst = [paren, contained, containedin, contains_prefix, contains, op]
  "echom json_encode(rst)
  return rst
endfunction

function! s:resolve_parenthesis_from_config(config)
  return s:resolve_parenthesis_with([
        \ '', 0, '', a:config.contains_prefix, '', a:config.operators
        \ ], a:config.syntax_options)
endfunction

function! stripedCamel#syntax#update(config)
  let conf = a:config
  let prefix = conf.syn_name_prefix
  let cycle = conf.cycle

  let glob_paran_opts = s:resolve_parenthesis_from_config(conf)
  let b:stripedCamel_loaded = cycle

  for id in range(len(conf.syntax_border))
    let [paren, contained, containedin, contains_prefix, contains, op] =
          \ s:resolve_parenthesis_with(glob_paran_opts, conf.syntax_border[id])
    for lv in range(cycle)
      let lv2 = ((lv + cycle - 1) % cycle)
      let [rid, pid, gid2] = [
            \ stripedCamel#unique#synID(prefix, 'r', lv, id),
            \ stripedCamel#unique#synID(prefix, 'p', lv, id),
            \ stripedCamel#unique#synGroupID(prefix, 'Regions', lv2)
            \ ]

      if len(op) > 2
        exe 'syn match' stripedCamel#unique#synID(prefix, 'o', lv, id) op
              \ 'containedin='. stripedCamel#unique#synID(prefix, 'r', lv, id)
              \ 'contained'
      endif

      let real_contains = s:concat([contains_prefix, contains])
      let real_contained = lv != 0 || contained ? 'contained' : ''
      let real_containedin = lv == 0
            \ ? s:concat([containedin, '@'. gid2])
            \ : '@'. gid2

      exe 'syn region' rid
            \ 'matchgroup='. pid
            \ 'contains='. real_contains
            \ real_contained
            \ 'containedin='. real_containedin
            \ paren
    endfor
  endfor

  for lv in range(cycle)
    exe 'syn cluster' stripedCamel#unique#synGroupID(prefix, 'Regions', lv)
          \ 'contains='. join(map(range(len(conf.syntax_border)),
          \ 'stripedCamel#uniqu#synID(prefix, "r", lv, v:val)'), ',')
    exe 'syn cluster' stripedCamel#unique#synGroupID(prefix, 'syntax_border', lv)
          \ 'contains='. join(map(range(len(conf.syntax_border)),
          \ 'stripedCamel#uniqu#synID(prefix, "p", lv, v:val)'), ',')
    exe 'syn cluster' stripedCamel#unique#synGroupID(prefix, 'Operators', lv)
          \ 'contains='. join(map(range(len(conf.syntax_border)),
          \ 'stripedCamel#uniqu#synID(prefix, "o", lv, v:val)'), ',')
  endfor
  exe 'syn cluster' prefix .'Regions contains='.
        \ join(map(range(cycle),
        \ '"@". stripedCamel#uniqu#synGroupID(prefix, "Regions", v:val)'), ',')
  exe 'syn cluster' prefix .'syntax_border contains='.
        \ join(map(range(cycle),
        \ '"@". stripedCamel#uniqu#synGroupID(prefix, "syntax_border", v:val)'), ',')
  exe 'syn cluster' prefix .'Operators contains='.
        \ join(map(range(cycle),
        \ '"@". stripedCamel#uniqu#synGroupID(prefix, "Operators", v:val)'), ',')
  if has_key(conf, 'after') | return | endif

  for cmd in conf.after
    exe cmd
  endfor
endfunction

function! stripedCamel#syntax#clear(config)
  let conf = a:config
  let prefix = conf.syn_name_prefix

  for id in range(len(conf.syntax_border))
    for lv in range(conf.cycle)
      let [rid, oid] = [
            \ stripedCamel#unique#synID(prefix, 'r', lv, id),
            \ stripedCamel#unique#synID(prefix, 'o', lv, id)
            \ ]
      exe 'syn clear'. rid
      exe 'syn clear'. oid
    endfor
  endfor
endfunction

