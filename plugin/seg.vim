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
" }}} Load Once

" Save 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}} Save 'cpoptions'

let rom_to_hira_table = {
            \   'vo': ['を', ''],
            \   'va': ['わ', ''],
            \   've': ['え', ''],
            \   'vi': ['い', ''],
            \   'u': ['う', ''],
            \   'o': ['お', ''],
            \   'a': ['あ', ''],
            \   'e': ['え', ''],
            \   'i': ['い', ''],
            \   'hu': ['う', ''],
            \   'ho': ['お', ''],
            \   'ha': ['あ', ''],
            \   'he': ['え', ''],
            \   'hi': ['い', ''],
            \   'ju': ['ゆ', ''],
            \   'jo': ['よ', ''],
            \   'jaw': ['よ', ''],
            \   'ja': ['や', ''],
            \   'je': ['え', ''],
            \   'ru': ['る', ''],
            \   'ro': ['ろ', ''],
            \   'raw': ['ろ', ''],
            \   'ra': ['ら', ''],
            \   're': ['れ', ''],
            \   'ri': ['り', ''],
            \   'ryu': ['りゅ', ''],
            \   'ryo': ['りょ', ''],
            \   'rya': ['りゃ', ''],
            \   'su': ['す', ''],
            \   'sa': ['さ', ''],
            \   'se': ['せ', ''],
            \   'seg': ['せい', ''],
            \   'si': ['し', ''],
            \   'syu': ['しゅ', ''],
            \   'syo': ['しょ', ''],
            \   'sya': ['しゃ', ''],
            \   'ss': ['っ', 's'],
            \   'zu': ['ず', ''],
            \   'za': ['ざ', ''],
            \   'ze': ['ぜ', ''],
            \   'zi': ['じ', ''],
            \   'zyu': ['じゅ', ''],
            \   'zyo': ['じょ', ''],
            \   'zya': ['じゃ', ''],
            \   'nu': ['ぬ', ''],
            \   'na': ['な', ''],
            \   'ne': ['ね', ''],
            \   'ni': ['に', ''],
            \   'nyu': ['にゅ', ''],
            \   'nyo': ['にょ', ''],
            \   'nya': ['にゃ', ''],
            \   'nn': ['ん', 'n'],
            \   'tu': ['つ', ''],
            \   'ta': ['た', ''],
            \   'te': ['て', ''],
            \   'ti': ['ち', ''],
            \   'tyu': ['ちゅ', ''],
            \   'tyo': ['ちょ', ''],
            \   'tya': ['ちゃ', ''],
            \   't': ['っ', ''],
            \   'du': ['づ', ''],
            \   'da': ['だ', ''],
            \   'de': ['で', ''],
            \   'di': ['ぢ', ''],
            \   'dyu': ['ぢゅ', ''],
            \   'dyo': ['ぢょ', ''],
            \   'dya': ['ぢゃ', ''],
            \   'ku': ['く', ''],
            \   'ka': ['か', ''],
            \   'kyu': ['きゅ', ''],
            \   'kyo': ['きょ', ''],
            \   'kya': ['きゃ', ''],
            \   'kk': ['っ', 'k'],
            \   'gu': ['ぐ', ''],
            \   'ga': ['が', ''],
            \   'gyu': ['ぎょ', ''],
            \   'gyo': ['ぎょ', ''],
            \   'gya': ['ぎゃ', ''],
            \   'mu': ['む', ''],
            \   'ma': ['ま', ''],
            \   'myu': ['みゅ', ''],
            \   'myo': ['みょ', ''],
            \   'mya': ['みゃ', ''],
            \   'mm': ['ん', 'm'],
            \   'pu': ['ぽ', ''],
            \   'po': ['ぱ', ''],
            \   'pyu': ['ぴゅ', ''],
            \   'pyo': ['ぴょ', ''],
            \   'pya': ['ぴゃ', ''],
            \   'xa': ['は', ''],
            \   'xyu': ['ひゅ', ''],
            \   'xyo': ['ひょ', ''],
            \   'xya': ['ひゃ', ''],
            \   'bu': ['ぶ', ''],
            \   'bo': ['ぼ', ''],
            \   'ba': ['ば', ''],
            \   'byu': ['びゅ', ''],
            \   'byo': ['びょ', ''],
            \   'bya': ['びゃ', ''],
            \   'kwa': ['くゎ', ''],
            \   'kwe': ['くゑ', ''],
            \   'kwi': ['くゐ', ''],
            \   'kwyo': ['くを', ''],
            \   'kwya': ['くゎ', ''],
            \   'gwa': ['ぐゎ', ''],
            \   'gwe': ['ぐゑ', ''],
            \   'gwi': ['ぐゐ', ''],
            \   'gwyo': ['ぐを', ''],
            \   'gwya': ['ぐゎ', ''],
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
endfunction " s:add_branch

function! seg#rom_to_hira_tree(table)
    let tree = {}
    for key in keys(a:table)
        call s:add_branch(a:table, tree, key, 0)
    endfor
    return tree
endfunction " seg#rom_to_hira_tree

let s:rom_tree = seg#rom_to_hira_tree(rom_to_hira_table)

function! s:ascii_state_input_char(arg)
    return toupper(a:arg['key'])
endfunction " s:ascii_state_input_char

function! s:ascii_state_move_to_hira(arg)
    let b:seg['state'] = s:hira_state
    let b:seg['rom_tree'] = s:rom_tree
    return ""
endfunction " s:ascii_state_move_to_hira

function! s:ascii_state_move_to_ascii(arg)
    call s:ascii_state_input_char({'key' : 'l'})
    return ""
endfunction " s:ascii_state_move_to_ascii

function! s:ascii_state_switch_hira_kana(arg)
    call s:ascii_state_input_char({'key' : 'q'})
    return ""
endfunction " s:ascii_state_switch_hira_kana

function! s:ascii_state_move_to_zenei(arg)
    call s:ascii_state_input_char('L')
    return ""
endfunction " s:ascii_state_move_to_zenei

let s:ascii_state = {
            \ 'input_char' : function('s:ascii_state_input_char'),
            \ 'move_to_hira' : function('s:ascii_state_move_to_hira'),
            \ 'move_to_ascii' : function('s:ascii_state_move_to_ascii'),
            \ 'switch_hira_kana' : function('s:ascii_state_switch_hira_kana'),
            \ 'move_to_zenei' : function('s:ascii_state_move_to_zenei'),
            \ }

function! s:is_leaf(tree)
    return a:tree['child'] == {}
endfunction " s:is_leaf

function! s:hira_state_input_char(ch)
    let input = a:ch['key']
    let b:seg['preedit'] .= input

    if !has_key(b:seg['rom_tree'], input) && !has_key(s:rom_tree, input)
        " invalid input
        let b:seg['preedit'] = ''
        let b:seg['rom_tree'] = s:rom_tree
        echo 'A:' . b:seg['preedit']
        return ""
    endif

    if !has_key(b:seg['rom_tree'], input)
        let b:seg['preedit'] = input
        let b:seg['rom_tree'] = s:rom_tree[input]['child']
        echo 'D:' . b:seg['preedit']
        return ""
    endif

    if s:is_leaf(b:seg['rom_tree'][input])
        let result = b:seg['rom_tree'][input]['hira']
        let b:seg['preedit'] = b:seg['rom_tree'][input]['next']
        let b:seg['rom_tree'] = s:rom_tree
        echo 'B:' . b:seg['preedit']
        return result
    endif

    let b:seg['rom_tree'] = b:seg['rom_tree'][input]['child']
    echo 'C:' . b:seg['preedit'] . '(' . join(keys(b:seg['rom_tree']), '/') . ')'
    return ""
endfunction " s:hira_state_input_char

function! s:hira_state_move_to_hira()
endfunction " s:hira_state_move_to_hira

function! s:hira_state_move_to_ascii()
endfunction " s:hira_state_move_to_ascii

function! s:hira_state_switch_hira_kana()
endfunction " s:hira_state_switch_hira_kana

function! s:hira_state_move_to_zenei()
endfunction " s:hira_state_move_to_zenei

let s:hira_state = {
            \ 'input_char' : function('s:hira_state_input_char'),
            \ 'move_to_hira' : function('s:hira_state_move_to_hira'),
            \ 'move_to_ascii' : function('s:hira_state_move_to_ascii'),
            \ 'switch_hira_kana' : function('s:hira_state_switch_hira_kana'),
            \ 'move_to_zenei' : function('s:hira_state_move_to_zenei'),
            \ }

function! seg#default_mapped_keys()
    return split(
                \ 'abcdefghijklmnopqrstuvwxyz',
                \ '\zs'
                \)
endfunction " seg#default_mapped_keys

function! seg#map_keys()
    let keys = seg#default_mapped_keys()
    for key in keys
        let n = char2nr(key)
        let char = "<Char-" . n . ">"
        execute "lmap <buffer> <silent> " . char . " <C-r>=seg#call_command('input_char', '" . key . "')<CR>"
        unlet char
        unlet n
        unlet key
    endfor
    lmap <buffer> <silent> <C-j> <C-r>=seg#call_command('move_to_hira', '')<CR>
    lmap <buffer> <silent> $ <C-r>=seg#terminate_char()<CR>
endfunction " seg#map_keys

function seg#call_command(cmd, key)
    let Fn = b:seg['state'][a:cmd]
    return Fn({'key' : a:key})
endfunction " seg#call_command

function seg#terminate_char()
    let result = b:seg['rom_tree']
endfunction " seg#terminate_char

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
endfunction " seg#init

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}} Restore 'cpoptions'

" vim:set et:
