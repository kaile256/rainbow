function! stripedCamel#unique#synID(prefix, group, lv, id)
  " Return an unique syntax name
  return a:prefix .'_lv'. a:lv .'_'. a:group . a:id
endfunction

function! stripedCamel#unique#synGroupID(prefix, group, lv)
  " Return an unique syntax name
  return a:prefix . a:group .'_lv'. a:lv
endfunction

