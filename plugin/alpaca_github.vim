if get(g:, 'loaded_alpaca_github', 0) || &cp
  finish
endif

let g:loaded_alpaca_github = 1

let s:save_cpo = &cpo
set cpo&vim

function! s:error(msg) abort
  echohl ErrorMsg
  echomsg a:msg
  echohl None
endfunction

if !executable('git')
  call s:error('Please install git in your PATH.')
  finish
endif

command! -range=0 -bar -nargs=* -complete=file
      \   GhFile
      \   call alpaca_github#open_file([<f-args>], <count>, <line1>, <line2>)

command! -range=0 -bar -nargs=* -complete=file
      \   GhPullRequest
      \   call alpaca_github#open_pull_request([<f-args>], <count>, <line1>, <line2>)

command! -range -bar -nargs=* -complete=file
      \   GhPullRequestCurrentLine
      \   call alpaca_github#open_pull_request([<f-args>], <count>, <line1>, <line2>)

let &cpo = s:save_cpo

if globpath(&rtp, 'plugin/openbrowser.vim') ==# ''
  call s:error('open-browser-github.vim depends on open-browser.vim. Please install open-browser.vim')
endif
