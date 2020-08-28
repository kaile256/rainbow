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

function! s:set_syntax_config(ft) abort
  let config_syntax_local = has_key(g:stripedCamel#syntax_as_filetypes, a:ft)
        \ ? deepcopy(g:stripedCamel#syntax_as_filetypes[a:ft])
        \ : deepcopy(g:stripedCamel#syntax_as_filetypes['_'])

  if empty(config_syntax_local)
    return 0
  endif

  let config_syntax_local = extend(config_syntax_local,
        \ deepcopy(g:stripedCamel#syntax_global), 'keep')
  return config_syntax_local
endfunction

function! s:gen_conf(ft)
  let config = {}
  let config.syntax = s:set_syntax_config(a:ft)
  let config.highlight = g:stripedCamel#highlight

  let config.cycle = (has('termguicolors') && &termguicolors)
        \ || has('gui_running')
        \ ? s:lcm(len(config.highlight.guifg), len(config.highlight.gui))
        \ : s:lcm(len(config.highlight.ctermfg), len(config.highlight.cterm))

  return config
endfunction

function! stripedCamel#config#generate(ft)
  let fts = split(a:ft, '\.') " such as 'javascript.jsx'.
  let configs = map(fts, 's:gen_conf(v:val)')

  " Return an empty list as s:gen_conf() returns 0.
  let list_of_dicts = filter(configs, 'type(v:val) == type({})')
  return list_of_dicts
endfunction

