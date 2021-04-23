# alpaca_github.vim

Easily open github link of current file from Vim.

## Install

**Note:** alpaca\_github.vim requires [open-browser.vim](https://github.com/tyru/open-browser.vim)

Please install [open-browser.vim](https://github.com/tyru/open-browser.vim).

For vim-plug

```viml
Plug 'alpaca-tc/alpaca_github.vim'
Plug 'tyru/open-browser.vim'
```

For dein.vim

```viml
call dein#add('alpaca-tc/alpaca_github.vim', { 'depends': ['open-browser.vim'] })
call dein#add('tyru/open-browser.vim')
```

## Configuration

```vim
" Disable vimproc.
" let g:alpaca_github#use_vimproc = 0

" Change github host of remote
" let g:alpaca_github#host = 'github.com'

" Open current file on github
nmap gO :GhFile<CR>

" Open pull request of last commit on github
nmap gP :GhPullRequestCurrentLine<CR>
```
