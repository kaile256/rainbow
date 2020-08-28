function! s:set_highlight(target, lv) abort
  " Given: a:target is 'ctermfg'
  " 'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta']
  " returns 'lightcyan' when a:lv is 3.
  " or
  " 'ctermfg': -1, as the parent highlight is 224
  " returns 223 when a:lv is odd;
  " otherwise (when a:lv is even), returns 224.

  let color_name = a:target[a:lv % len(a:target)]
  return color_name
endfunction

function! stripedCamel#highlight#update(config)
  let conf = a:config
  let prefix = conf.syntax.prefix

  for id in range(len(conf.syntax.regexp))
    for lv in range(conf.cycle)
      let group = stripedCamel#unique#synID(prefix, 'o', lv, id)

      let hi_style = ''
      for color_lhs in keys(conf.highlight)
        " such as ctermfg=221, gui=bold, etc.
        let color_rhs = s:set_highlight(conf.highlight[color_lhs], lv)
        if empty(color_rhs) | continue | endif
        let hi_style .= color_lhs .'='. color_rhs .' '
      endfor

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

