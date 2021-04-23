let s:V = vital#of('alpaca_github')
let s:Prelude = s:V.import('Prelude')

function! s:current_git_path(path)
  let git_root = s:Prelude.path2project_directory(a:path)
  return substitute(a:path, git_root."/", "", "g")
endfunction

function! s:get_root_directory(path)
  return s:Prelude.path2project_directory(a:path)
endfunction

function! alpaca_github#git#host()
  return 'github.com'
endfunction

" @return [Array<String, String>] worktree directory and relative path
function! alpaca_github#git#split_repo_path(absolute_path) abort
  let git_root = s:get_root_directory(a:absolute_path)
  let relative_path_from_git_root = substitute(a:absolute_path, git_root . '/', "", "")

  return [git_root, relative_path_from_git_root]
endfunction

function! alpaca_github#git#current_hash()
  return alpaca_github#util#git('rev-parse', 'HEAD')
endfunction

function! alpaca_github#git#get_remotes() abort
  let output = alpaca_github#util#git('remote', '-v')
  let remotes = split(output, '\n', 1)

  let parsed_remotes = []

  for remote in remotes
    let github_host = get(g:, 'alpaca_github#host', 'github.com')
    let result = s:parse_git_remote(github_host, remote)

    if !empty(result)
      call add(parsed_remotes, result)
    endif
  endfor

  return parsed_remotes
endfunction

function! s:parse_git_remote(github_host, url)
  let host_re = escape(a:github_host, '.')
  let gh_host_re = 'github\.com'

  let ssh_re_fmt = 'git@%s[:/]\([^/]\+\)/\([^/]\+\)\s'
  let ssh2_re_fmt = '\s%s[:/]\([^/]\+\)/\([^/]\+\)\s'
  let ssh3_re_fmt = 'ssh://%s/\([^/]\+\)/\([^/]\+\)\s'
  let git_re_fmt = 'git://%s/\([^/]\+\)/\([^/]\+\)\s'
  let https_re_fmt = 'https\?://%s/\([^/]\+\)/\([^/]\+\)\s'

  let ssh_re = printf(ssh_re_fmt, host_re)
  let ssh2_re = printf(ssh2_re_fmt, host_re)
  let ssh3_re = printf(ssh3_re_fmt, host_re)
  let git_re = printf(git_re_fmt, host_re)
  let https_re = printf(https_re_fmt, host_re)

  let gh_ssh_re = printf(ssh_re_fmt, gh_host_re)
  let gh_ssh2_re = printf(ssh2_re_fmt, gh_host_re)
  let gh_ssh3_re = printf(ssh3_re_fmt, gh_host_re)
  let gh_git_re = printf(git_re_fmt, gh_host_re)
  let gh_https_re = printf(https_re_fmt, gh_host_re)

  let re_list = [ssh_re, ssh2_re, ssh3_re, git_re, https_re]

  if a:github_host !=# 'github.com'
    call add(re_list, [gh_ssh_re, gh_ssh2_re, gh_ssh3_re, gh_git_re, gh_https_re])
  endif

  for re in re_list
    let m = matchlist(a:url, re)

    if !empty(m)
      return {
            \ 'user': m[1],
            \ 'repo': substitute(m[2], '\.git$', '', ''),
            \ }
    endif
  endfor
endfunction
