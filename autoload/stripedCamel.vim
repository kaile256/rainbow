" Keep clean this file only with interface functions.

function! stripedCamel#load()
  let b:stripedCamel_confs = stripedCamel#config#generate(&filetype)
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

