
function! stripedCamel#highlight#update(config)
  let conf = a:config
  let prefix = conf.syntax.prefix

  for id in range(len(conf.syntax.regexp))
    for lv in range(conf.cycle)
      let group = stripedCamel#unique#synID(prefix, 'o', lv, id)

      let ctermfg = conf.ctermfg[lv % len(conf.ctermfg)]
      let guifg = conf.guifg[lv % len(conf.guifg)]
      let cterm = conf.cterm[lv % len(conf.cterm)]
      let gui = conf.gui[lv % len(conf.gui)]

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

