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

function! seg#rom_to_hira_tree_rec(table, tree, word, index)
  if strlen(a:word) <= a:index
    return 0
  endif
  let symbol = a:word[a:index]
  if !has_key(a:tree, symbol)
    let a:tree[symbol] = { 'child': {} }
  endif
  let prefix = a:word[0:(a:index)]
  if has_key(a:table, prefix)
    let a:tree[symbol]['hira'] = a:table[prefix][0]
    let a:tree[symbol]['next'] = a:table[prefix][1]
  endif
  return seg#rom_to_hira_tree_rec(a:table, a:tree[symbol]['child'], a:word, a:index + 1)
endfunction

function! seg#rom_to_hira_tree(table)
  let tree = {}
  for key in keys(a:table)
    call seg#rom_to_hira_tree_rec(a:table, tree, key, 0)
  endfor
  return tree
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et:
