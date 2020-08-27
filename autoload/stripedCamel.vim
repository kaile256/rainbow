" Copyright 2013 LuoChen (luochen1990@gmail.com). Licensed under the Apache License 2.0.

let s:stripedCamel_conf = {
      \ 'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
      \ 'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
      \ 'guis': [''],
      \ 'cterms': [''],
      \ 'operators': '_,_',
      \ 'contains_prefix': 'TOP',
      \ 'parentheses_options': '',
      \ 'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
      \ 'filetype': {
      \   '_': {},
      \   'markdown': {
      \     'parentheses_options': 'containedin=markdownCode contained',
      \   },
      \   'lisp': {
      \     'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
      \   },
      \   'haskell': {
      \     'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/\v\{\ze[^-]/ end=/}/ fold'],
      \   },
      \   'ocaml': {
      \     'parentheses': ['start=/(\ze[^*]/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/\[|/ end=/|\]/ fold', 'start=/{/ end=/}/ fold'],
      \   },
      \   'tex': {
      \     'parentheses_options': 'containedin=texDocZone',
      \     'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
      \   },
      \   'vim': {
      \     'parentheses_options': 'containedin=vimFuncBody,vimExecute',
      \     'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold'],
      \   },
      \   'xml': {
      \     'syn_name_prefix': 'xmlstripedCamel',
      \     'parentheses': ['start=/\v\<\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'))?)*\>/ end=#</\z1># fold'],
      \   },
      \   'xhtml': {
      \     'parentheses': ['start=/\v\<\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'))?)*\>/ end=#</\z1># fold'],
      \   },
      \   'html': {
      \     'parentheses': ['start=/\v\<((script|style|area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
      \   },
      \   'perl': {
      \     'syn_name_prefix': 'perlBlockFoldstripedCamel',
      \   },
      \   'php': {
      \     'syn_name_prefix': 'phpBlockstripedCamel',
      \     'contains_prefix': '',
      \     'parentheses': ['start=/(/ end=/)/ containedin=@htmlPreproc contains=@phpClTop', 'start=/\[/ end=/\]/ containedin=@htmlPreproc contains=@phpClTop', 'start=/{/ end=/}/ containedin=@htmlPreproc contains=@phpClTop', 'start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold contains_prefix=TOP'],
      \   },
      \   'stylus': {
      \     'parentheses': ['start=/{/ end=/}/ fold contains=@colorableGroup'],
      \   },
      \   'css': 0,
      \   'sh': 0,
      \ }
      \}

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
  let g = get(g:, 'stripedCamel_conf', {})
  let s = get(g, 'filetype', {})
  let dft_conf = extend(copy(s:stripedCamel_conf), g)
  unlet dft_conf.filetype

  let dx_conf = s:stripedCamel_conf.filetype['_']
  let ds_conf = get(s:stripedCamel_conf.filetype, a:ft, dx_conf)
  let ux_conf = get(s, '_', ds_conf)
  let us_conf = get(s, a:ft, ux_conf)
  let af_conf = s:eq(us_conf, 'default') ? ds_conf : us_conf

  if s:eq(af_conf, 0)
    return 0
  else
    let conf = extend(extend({'syn_name_prefix': substitute(a:ft, '\v\A+(\a)', '\u\1', 'g') .'stripedCamel'}, dft_conf), af_conf)
    let conf.cycle = (has('termguicolors') && &termguicolors)
          \ || has('gui_running')
          \ ? s:lcm(len(conf.guifgs), len(conf.guis))
          \ : s:lcm(len(conf.ctermfgs), len(conf.cterms))
    return conf
  endif
endfunction

function! s:gen_configs(ft)
  return filter(map(split(a:ft, '\v\.'), 's:gen_conf(v:val)'),
        \ 'type(v:val) == type({})')
endfunction

function! stripedCamel#load()
  let b:stripedCamel_confs = s:gen_configs(&filetype)
  for conf in b:stripedCamel_confs
    call stripedCamel#syntax#syn(conf)
    call stripedCamel#syntax#hi(conf)
  endfor
endfunction

function! stripedCamel#clear()
  if !exists('b:stripedCamel_confs') | return | endif
  for conf in b:stripedCamel_confs
    call stripedCamel#syntax#hi_clear(conf)
    call stripedCamel#syntax#syn_clear(conf)
  endfor
  unlet b:stripedCamel_confs
endfunction

function! stripedCamel#toggle()
  if exists('b:stripedCamel_confs')
    call stripedCamel#clear()
  else
    call stripedCamel#load()
  endif
endfunction

