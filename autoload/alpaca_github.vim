function! alpaca_github#open_file(args, rangegiven, firstlnum, lastlnum) abort
  let file = s:resolve(expand(get(a:args, 0, '%:p')))

  let root_and_relative_path = alpaca_github#git#split_repo_path(file)
  let relative_path = root_and_relative_path[1]

  let BLOB_FORMAT = '/blob/%s/%s#%s'

  if a:rangegiven
    let anchor = "L".a:firstlnum."-L".a:lastlnum
  else
    let anchor = ''
  endif

  let current_hash = alpaca_github#git#current_hash()

  let path = printf(BLOB_FORMAT,
        \ current_hash,
        \ relative_path,
        \ anchor)

  let remote_path = s:select_remote()

  if !empty(remote_path)
    let url = "https://" . alpaca_github#git#host() . "/" . remote_path . '/' .path

    call alpaca_github#util#open_url(url)
  endif
endfunction

function! alpaca_github#open_pull_request(args, rangegiven, firstlnum, lastlnum) abort
  let file = s:resolve(expand(get(a:args, 0, '%:p')))

  let root_and_relative_path = alpaca_github#git#split_repo_path(file)
  let relative_path = root_and_relative_path[1]

  let options = ['log', '--pretty=format:"%h"', '--no-patch', '-1']

  let BLOB_FORMAT = '/blob/%s/%s#%s'

  if a:rangegiven
    call add(options, "-L". string(a:firstlnum) . ',' . string(a:firstlnum) . ':' . file)
  else
    call add(options, file)
  endif

  let hash = substitute(call(function('alpaca_github#util#git'), options), '"', "", "g")
  let logs = alpaca_github#util#git('log', '--merges', '--oneline', '--ancestry-path', hash . '...HEAD')

  let matched_logs = []

  for log in split(logs, "\n")
    if log =~ 'Merge pull request \#'
      call add(matched_logs, log)
    endif
  endfor

  let last_log = matched_logs[len(matched_logs) - 1]
  let m = matchlist(last_log, '\(\w\+\)\sMerge pull request #\(\d\+\)\sfrom\(.*\)')

  if empty(m)
    throw "Not found"
  else
    let repo = {
          \ 'hash': m[1],
          \ 'pull_id': m[2],
          \ 'from': m[3]
          \ }

    let remote_path = s:select_remote()

    if !empty(remote_path)
      let url = "https://" . alpaca_github#git#host() . "/" . remote_path . '/pull/' . repo.pull_id
      call alpaca_github#util#open_url(url)
    endif
  endif
endfunction

function! s:select_remote()
  let remotes = map(alpaca_github#git#get_remotes(), 'v:val.user . "/" . v:val.repo')
  let remotes = alpaca_github#util#uniq(remotes)

  return alpaca_github#util#select_candidates("Select organization/reponame number: ", remotes)
endfunction

function! s:resolve(path) abort
  return exists('*resolve') ? resolve(a:path) : a:path
endfunction
