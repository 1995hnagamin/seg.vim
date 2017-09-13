" seg.vim
" Version: 0.0.1
" Author: NAGAMINE Hideaki
" License: GPLv3

scriptencoding utf-8

if exists('g:loaded_seg')
  finish
endif
let g:loaded_seg = 1

let s:save_cpo = &cpo
set cpo&vim


let rom_to_hira_table = {
  \   'fu': ['う', ''],
  \   'se': ['せ', ''],
  \   'seg': ['せい', ''],
  \   'ss': ['っ', 's'],
  \   'syo': ['しょ', ''],
  \   't': ['っ', ''],
  \   'xa': ['は', ''],
  \   '.': ['。', ''],
  \   ',': ['、', ''],
  \ }


let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et:
