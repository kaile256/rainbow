
function! stripedCamel#highlight#update(config)
  let conf = a:config
  let prefix = conf.syntax.prefix

  for id in range(len(conf.syntax.regexp))
    for lv in range(conf.cycle)
      let group = stripedCamel#unique#synID(prefix, 'o', lv, id)

      let ctermfg = conf.ctermfgs[lv % len(conf.ctermfgs)]
      let guifg = conf.guifgs[lv % len(conf.guifgs)]
      let cterm = conf.cterms[lv % len(conf.cterms)]
      let gui = conf.guis[lv % len(conf.guis)]

      let hi_style =
            \ 'ctermfg='. ctermfg
            \ .' guifg='. guifg
            \ . (len(cterm) > 0 ? ' cterm='. cterm : '')
            \ . (len(gui) > 0 ? ' gui='. gui : '')

      exe 'hi' group hi_style
    endfor
  endfor
endfunction

function! stripedCamel#highlight#clear(config)
  let conf = a:config
  let prefix = conf.syntax.prefix

  for id in range(len(conf.syntax.regexp))
    for lv in range(conf.cycle)
      let group = stripedCamel#unique#synID(prefix, 'o', lv, id)
      exe 'hi clear' group
    endfor
  endfor
endfunction

