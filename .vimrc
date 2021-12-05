let mapleader = ","
let g:mapleader= ","

set nocompatible
set ignorecase
set smartcase
set timeout timeoutlen=200 ttimeoutlen=100
set mouse=r

filetype off

call plug#begin('~/.vim/plugged')

Plug 'junegunn/seoul256.vim'
Plug 'tpope/vim-sensible'
Plug 'airblade/vim-gitgutter'
Plug 'bignimbus/pop-punk.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'pbogut/fzf-mru.vim'
Plug 'airblade/vim-gitgutter'
Plug 'i3d/vim-jimbothemes'

Plug 'itchyny/lightline.vim'

call plug#end()

set foldtext=clean_fold#fold_text_minimal()

" Test Vim Fold {{{
" Colors {{{
set background=dark
" Set term color to 256
set t_CO=256

colorscheme matrix

" pop-punk ANSI colors for vim terminal
let g:terminal_ansi_colors = pop_punk#AnsiColors()

" for the airline theme - note the underscore instead of the hyphen
let g:airline_theme = 'pop_punk'

" just for fun
let g:airline_section_c = '🎸 %F'


let g:terminal_ansi_colors = pop_punk#AnsiColors()
let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.5, 'highlight': 'Comment'} }
hi! fzf_fg ctermfg=14                                                                                                                                                       
hi! fzf_fgp ctermfg=3                                                                                                                                                       
hi! fzf_hl ctermfg=5                                                                                                                                                        
hi! fzf_hlp ctermfg=5                                                                                                                                                       
hi! fzf_info ctermfg=6                                                                                                                                                      
hi! fzf_prompt ctermfg=6                                                                                                                                                    
hi! fzf_spinner ctermfg=6                                                                                                                                                   
hi! fzf_pointer ctermfg=3
let g:fzf_colors = {                                                                                                                                                        
  \ 'fg':      ['fg', 'fzf_fg'],                                                                                                                                            
  \ 'hl':      ['fg', 'fzf_hl'],                                                                                                                                            
  \ 'fg+':     ['fg', 'fzf_fgp'],                                                                                                                                           
  \ 'hl+':     ['fg', 'fzf_hlp'],                                                                                                                                           
  \ 'info':    ['fg', 'fzf_info'],                                                                                                                                          
  \ 'prompt':  ['fg', 'fzf_prompt'],                                                                                                                                        
  \ 'pointer': ['fg', 'fzf_pointer'],                                                                                                                                       
  \ 'spinner': ['fg', 'fzf_spinner'] }
" }}}

" {{ Other
" Enable syntax highlight
syntax on
" Numbers
set nonu rnu
" }}}
" }}}

nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)

nmap <silent><Leader>g :call setbufvar(winbufnr(popup_atcursor(split(system("git log -n 1 -L " . line(".") . ",+1:" . expand("%:p")), "\n"), { "padding": [1,1,1,1], "pos": "botleft", "wrap": 0 })), "&filetype", "git")<CR>

set fdm=marker
