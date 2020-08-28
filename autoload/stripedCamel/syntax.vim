" Copyright 2013 LuoChen (luochen1990@gmail.com). Licensed under the Apache License 2.0.

" gid: Group
" pid: P
" rid: Regions

function! s:trim_spaces_around(s)
  return matchstr(a:s, '^\s*\zs.*\ze\s*$')
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
    let key_value = split(s, '=')
    let k = key_value[0]
    let v = len(key_value) < 2 ? '' : join(key_value[1:], '')

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

  let ret = [
        \ humpOfCamel,
        \ contained,
        \ containedin,
        \ contains_prefix,
        \ contains,
        \ options
        \ ]
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
      let group = stripedCamel#unique#synID(prefix, 'o', lv, id)
      let parent = stripedCamel#unique#synID(prefix, 'r', lv, id)
      if len(options) > 2
        exe 'syn match' group
              \ options
              \ 'containedin='. parent
              \ 'contained'
              \ string(humpOfCamel)
      endif
    endfor
  endfor

  if empty(get(conf, 'after', [])) | return | endif

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

