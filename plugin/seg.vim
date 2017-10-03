" seg.vim
" Version: 0.0.1
" Author: NAGAMINE Hideaki
" License: NEW BSD LICENSE

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

function! s:add_branch(table, tree, word, index)
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
    return s:add_branch(a:table, a:tree[symbol]['child'], a:word, a:index + 1)
endfunction

function! seg#rom_to_hira_tree(table)
    let tree = {}
    for key in keys(a:table)
        call s:add_branch(a:table, tree, key, 0)
    endfor
    return tree
endfunction

function! seg#default_mapped_keys()
    return split(
                \ 'abcdefghijklmnopqrstuvwxyz',
                \ '\zs'
                \)
endfunction

function! seg#map_keys()
    let keys = seg#default_mapped_keys()
    for key in keys
        let n = char2nr(key)
        let char = "<Char-" . n . ">"
        execute "lmap <buffer> " . char . " <C-r>=seg#call_command('input_char', '" . key . "')<CR>"
        unlet char
        unlet n
        unlet key
    endfor
endfunction

function seg#call_command(cmd, key)
    let Fn = b:seg['state'][a:cmd]
    return Fn({'key' : a:key})
endfunction

function! seg#init()
    if exists('b:seg')
        return
    endif
    let b:seg = {
                \ 'state' : s:ascii_state,
                \ 'preedit' : ''
                \ }
    call seg#map_keys()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et:
