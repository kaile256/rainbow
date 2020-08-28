" Copyright 2013 LuoChen (luochen1990@gmail.com). Licensed under the Apache License 2.0.

let s:default_config = {
      \ 'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
      \ 'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
      \ 'cterms': [''],
      \ 'guis': [''],
      \ 'operators': '_,_',
      \ 'contains_prefix': 'TOP',
      \ 'syntax_border': ['\u[a-z0-9_]'],
      \ 'syntax_options': '',
      \ 'filetype': {
      \   '_': {},
      \   'vim': {
      \     'syntax_border': ['#\zs\w\{-}'],
      \     'syntax_options': 'containedin=vimFunction,vimVar',
      \   },
      \ }
      \}

function! s:get_config(name, default) abort
  " Sample:
  " let g:stripedCamel#syntax_global =
  "       \ extend(get(g:, 'stripedCamel#syntax_global', {
  "       \ 'regexp': ['\u[a-z0-9]'],
  "       \ 'option': ['contained', 'skipwhite', 'skipempty'],
  "       \ }, 'keep')

  let plugin = 'stripedCamel'
  let var = plugin .'#'. a:name
  let {'g:'. var} = extend(get(g:, var, {}), a:default, 'keep')
endfunction

call s:get_config('highlight', {
      \ 'guifg': -1,
      \ 'ctermfg': -1,
      \ 'gui': -1,
      \ 'cterm': -1,
      \ })

call s:get_config('syntax_global', {
      \ 'regexp': ['\u[a-z0-9]'],
      \ 'option': ['contained', 'skipwhite', 'skipempty'],
      \ })

call s:get_config('syntax_as_filetypes', {
      \ '_': {},
      \ 'vim': {
      \   'regexp': ['#\w\+'],
      \   'option': ['contained', 'skipwhite', 'skipempty'],
      \ }
      \ })

function! s:eq(x, y)
  return type(a:x) == type(a:y) && a:x == a:y
endfunction

function! s:gcd(a, b)
  let [a, b, t] = [a:a, a:b, 0]
  while b != 0
    let t = b
    let b = a % b
    let a = t
  endwhile
  return a
endfunction

function! s:lcm(a, b)
  return (a:a / s:gcd(a:a, a:b)) * a:b
endfunction

function! s:gen_conf(ft)
  let user_conf_global = get(g:, 'stripedCamel_conf', {})

  let default_conf_local_default = s:default_config.filetype['_']
  let default_conf_as_ft = get(s:default_config.filetype, a:ft,
        \ default_conf_local_default)

  let user_conf_as_filetypes = get(user_conf_global, 'filetype', {})
  let user_conf_local_default = get(user_conf_as_filetypes, '_',
        \ default_conf_as_ft)
  let user_conf_as_ft = get(user_conf_as_filetypes, a:ft,
        \ user_conf_local_default)

  let af_conf = s:eq(user_conf_as_ft, 'default')
        \ ? default_conf_as_ft
        \ : user_conf_as_ft

  if s:eq(af_conf, 0)
    return 0
  endif

  let conf = {
        \ 'syn_name_prefix' :
        \     substitute(a:ft, '\v\A+(\a)', '\u\1', 'g') .'stripedCamel'
        \ }

  let default_conf = extend(copy(s:default_config), user_conf_global, 'force')
  unlet default_conf.filetype
  let conf = extend(conf, default_conf)

  let conf = extend(conf, af_conf)

  let conf.cycle = (has('termguicolors') && &termguicolors)
        \ || has('gui_running')
        \ ? s:lcm(len(conf.guifgs), len(conf.guis))
        \ : s:lcm(len(conf.ctermfgs), len(conf.cterms))

  return conf
endfunction

function! stripedCamel#config#generate(ft)
  let fts = split(a:ft, '\.')
  let configs = map(fts, 's:gen_conf(v:val)')

  " Return an empty list as s:gen_conf() returns 0.
  let list_of_dicts = filter(configs, 'type(v:val) == type({})')
  return list_of_dicts
endfunction

