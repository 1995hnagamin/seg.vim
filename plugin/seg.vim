" seg.vim
" Version: 0.0.1
" Author: NAGAMINE Hideaki
" License: NEW BSD LICENSE

scriptencoding utf-8

" Load Once {{{
if exists('g:loaded_seg')
    finish
endif
let g:loaded_seg = 1
" }}}

" Save 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

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
    let prefix = a:word[0:(a:index)]
    if !has_key(a:tree, symbol)
        let a:tree[symbol] = {
                    \   'hira': '',
                    \   'next': prefix,
                    \   'child': {},
                    \ }
    endif
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

let s:rom_tree = seg#rom_to_hira_tree(rom_to_hira_table)

function! s:ascii_state_input_char(arg)
    return toupper(a:arg['key'])
endfunction

function! s:ascii_state_move_to_hira(arg)
    let b:seg['state'] = s:hira_state
    let b:seg['rom_tree'] = s:rom_tree
    return ""
endfunction

function! s:ascii_state_move_to_ascii(arg)
    call s:ascii_state_input_char({'key' : 'l'})
    return ""
endfunction

function! s:ascii_state_switch_hira_kana(arg)
    call s:ascii_state_input_char({'key' : 'q'})
    return ""
endfunction

function! s:ascii_state_move_to_zenei(arg)
    call s:ascii_state_input_char('L')
    return ""
endfunction

let s:ascii_state = {
            \ 'input_char' : function('s:ascii_state_input_char'),
            \ 'move_to_hira' : function('s:ascii_state_move_to_hira'),
            \ 'move_to_ascii' : function('s:ascii_state_move_to_ascii'),
            \ 'switch_hira_kana' : function('s:ascii_state_switch_hira_kana'),
            \ 'move_to_zenei' : function('s:ascii_state_move_to_zenei'),
            \ }

function! s:is_leaf(tree)
    return a:tree['child'] == {}
endfunction

function! s:hira_state_input_char(ch)
    let input = a:ch['key']
    let b:seg['preedit'] .= input

    if !has_key(b:seg['rom_tree'], input)
        " invalid input
        let b:seg['preedit'] = input
        let b:seg['rom_tree'] = s:rom_tree
        return ""
    endif

    if s:is_leaf(b:seg['rom_tree'][input])
        let result = b:seg['rom_tree'][input]['hira']
        let b:seg['preedit'] = b:seg['rom_tree'][input]['next']
        let b:seg['rom_tree'] = s:rom_tree
        return result
    endif

    let b:seg['rom_tree'] = b:seg['rom_tree'][input]['child']
    return ""
endfunction

function! s:hira_state_move_to_hira()
endfunction

function! s:hira_state_move_to_ascii()
endfunction

function! s:hira_state_switch_hira_kana()
endfunction

function! s:hira_state_move_to_zenei()
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
                \ 'rom_tree' : {},
                \ 'preedit' : ''
                \ }
    call seg#map_keys()
endfunction

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}

" vim:set et:
