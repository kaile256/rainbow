" Copyright 2013 LuoChen (luochen1990@gmail.com). Licensed under the Apache License 2.0.

" gid: Group
" pid: P
" rid: Regions

function! s:trim_spaces_around(s)
  return matchstr(a:s, '^\s*\zs.\{-}\ze\s*$')
endfunction

function! s:concat(strs)
  return join(filter(a:strs, 'v:val !~# "^[ ]*$"'), ',')
endfunction

function! s:resolve_parenthesis_with(init_state, pattern)
  let [
        \ humpOfCamel,
        \ contained,
        \ containedin,
        \ contains_prefix,
        \ contains,
        \ options
        \ ] = a:init_state

  " preprocess the old style syntax_border config
  let pattern = type(a:pattern) != type([])
        \ ? a:pattern
        \ : len(a:pattern) == 3
        \   ? printf('start=#%s# step=%s end=#%s#', a:pattern[0], options, a:pattern[-1])
        \   : printf('start=#%s# end=#%s#', a:pattern[0], a:pattern[-1])

  let ls = split(pattern,
        \ '\v%(%(start|step|end)\=(.)%(\1@!.)*\1[^ ]*|\w+%(\=[^ ]*)?) ?\zs',
        \ 0)

  for s in ls
    let [k, v] = [
          \ matchstr(s, '^[^=]\+\ze\(=\|$\)'),
          \ matchstr(s, '^[^=]\+=\zs.*')
          \ ]
    if k ==# 'step'
      let options = s:trim_spaces_around(v)
    elseif k ==# 'contains_prefix'
      let contains_prefix = s:trim_spaces_around(v)
    elseif k ==# 'contains'
      let contains = s:concat([contains, s:trim_spaces_around(v)])
    elseif k ==# 'containedin'
      let containedin = s:concat([containedin, s:trim_spaces_around(v)])
    elseif k ==# 'contained'
      let contained = 1
    else
      let humpOfCamel .= s
    endif
  endfor
  let ret = [humpOfCamel, contained, containedin, contains_prefix, contains, options]
  "echom json_encode(rst)
  return ret
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

  for id in range(len(conf.syntax_border))
    let [humpOfCamel, contained, containedin, contains_prefix, contains, options] =
          \ s:resolve_parenthesis_with(glob_paran_opts, conf.syntax_border[id])
    for lv in range(cycle)
      let lv2 = ((lv + cycle - 1) % cycle)
      let [rid, pid, gid2] = [
            \ stripedCamel#unique#synID(prefix, 'r', lv, id),
            \ stripedCamel#unique#synID(prefix, 'p', lv, id),
            \ stripedCamel#unique#synGroupID(prefix, 'Regions', lv2)
            \ ]

      if len(options) > 2
        exe 'syn match' stripedCamel#unique#synID(prefix, 'o', lv, id)
              \ options
              \ 'containedin='. rid
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
            \ humpOfCamel
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
    " Note: 'after' is to solve 3rd-party-plugin-compatibility problems with
    " `:syn clear xxx`.  Read the README of luochen1990/rainbow for detail at
    " https://bit.ly/2D9OsYI.
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

