" Keep clean this file only with interface functions.

function! stripedCamel#load()
  let b:stripedCamel_configs = stripedCamel#config#generate(&filetype)
  for conf in b:stripedCamel_configs
    call stripedCamel#syntax#update(conf)
    call stripedCamel#highlight#update(conf)
  endfor
endfunction

function! stripedCamel#clear()
  if !exists('b:stripedCamel_configs') | return | endif
  for conf in b:stripedCamel_configs
    call stripedCamel#highlight#clear(conf)
    call stripedCamel#syntax#clear(conf)
  endfor
  unlet b:stripedCamel_configs
endfunction

function! stripedCamel#toggle()
  if exists('b:stripedCamel_configs')
    call stripedCamel#clear()
  else
    call stripedCamel#load()
  endif
endfunction

