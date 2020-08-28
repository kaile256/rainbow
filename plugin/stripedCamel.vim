if exists('g:loaded_stripedCamel') | finish | endif
let g:loaded_stripedCamel= 1

command! StripedCamelToggle  call stripedCamel#toggle()
command! StripedCamelEnable  call stripedCamel#load()
command! StripedCamelDisable call stripedCamel#clear()

if get(g:, 'stripedCamel_inactive', 0) | finish | endif

augroup stripedCamel
  au ColorScheme,Syntax * call stripedCamel#load()
augroup END
