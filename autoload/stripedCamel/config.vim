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

" call extend(s:stripedCamel_conf, {
"      \ 'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
"      \ 'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
"      \ 'guis': [''],
"      \ 'cterms': [''],
"      \ 'operators': '_,_',
"      \ 'contains_prefix': 'TOP',
"      \ 'parentheses_options': '',
"      \ 'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
"      \ 'separately': {
"      \   '*': {},
"      \   'markdown': {
"      \     'parentheses_options': 'containedin=markdownCode contained',
"      \   },
"      \   'lisp': {
"      \     'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
"      \   },
"      \   'haskell': {
"      \     'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/\v\{\ze[^-]/ end=/}/ fold'],
"      \   },
"      \   'ocaml': {
"      \     'parentheses': ['start=/(\ze[^*]/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/\[|/ end=/|\]/ fold', 'start=/{/ end=/}/ fold'],
"      \   },
"      \   'tex': {
"      \     'parentheses_options': 'containedin=texDocZone',
"      \     'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
"      \   },
"      \   'vim': {
"      \     'parentheses_options': 'containedin=vimFuncBody,vimExecute',
"      \     'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold'],
"      \   },
"      \   'xml': {
"      \     'syn_name_prefix': 'xmlRainbow',
"      \     'parentheses': ['start=/\v\<\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'))?)*\>/ end=#</\z1># fold'],
"      \   },
"      \   'xhtml': {
"      \     'parentheses': ['start=/\v\<\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'))?)*\>/ end=#</\z1># fold'],
"      \   },
"      \   'html': {
"      \     'parentheses': ['start=/\v\<((script|style|area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
"      \   },
"      \   'perl': {
"      \     'syn_name_prefix': 'perlBlockFoldRainbow',
"      \   },
"      \   'php': {
"      \     'syn_name_prefix': 'phpBlockRainbow',
"      \     'contains_prefix': '',
"      \     'parentheses': ['start=/(/ end=/)/ containedin=@htmlPreproc contains=@phpClTop', 'start=/\[/ end=/\]/ containedin=@htmlPreproc contains=@phpClTop', 'start=/{/ end=/}/ containedin=@htmlPreproc contains=@phpClTop', 'start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold contains_prefix=TOP'],
"      \   },
"      \   'stylus': {
"      \     'parentheses': ['start=/{/ end=/}/ fold contains=@colorableGroup'],
"      \   },
"      \   'css': 0,
"      \   'sh': 0,
"      \ }
"      \}, 'keep')

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
  return filter(configs, 'type(v:val) == type({})')
endfunction

