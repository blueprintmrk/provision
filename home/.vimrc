" ~/.vimrc

" Vundle stuff
set nocompatible               " be iMproved
filetype off                   " required!
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'
Bundle 'tpope/vim-sensible'
Bundle 'tomasr/molokai'
filetype plugin indent on     " required!

" Colorscheme
colorscheme molokai

" Misc options
set shell=sh
set number
set cursorline
set linebreak
let mapleader = ","
set whichwrap+=b,s,<,>,h,l,[,]
set hlsearch
set incsearch

" Tab options
set smarttab
set tabstop=2
set shiftwidth=2
set autoindent
set expandtab
