let s:use_vimproc = get(g:, 'alpaca_github#use_vimproc', 1) && globpath(&rtp, 'autoload/vimproc.vim') !=# ''

function! s:trim(str) abort
  let str = a:str
  let str = substitute(str, '^[ \t\n]\+', '', 'g')
  let str = substitute(str, '[ \t\n]\+$', '', 'g')

  return str
endfunction

function! alpaca_github#util#git(...) abort
  if s:use_vimproc
    return s:trim(vimproc#system(['git'] + a:000))
  else
    return s:trim(system(join(['git'] + a:000, ' ')))
  endif
endfunction

function! alpaca_github#util#hub(...) abort
  if s:use_vimproc
    return s:trim(vimproc#system(['hub'] + a:000))
  else
    return s:trim(system(join(['hub'] + a:000, ' ')))
  endif
endfunction

function! alpaca_github#util#open_url(url)
  call openbrowser#open(a:url)
endfunction

function! alpaca_github#util#select_candidates(message, candidates) abort
  if len(a:candidates) == 1
    return a:candidates[0]
  elseif len(a:candidates) == 0
    throw "candidates are empty"
  endif

  let messages = []

  let CANDIDATE_FORMAT = "%d. %s"
  let last_index = len(a:candidates)

  for index in range(1, last_index)
    let candidate = a:candidates[index - 1]
    call add(messages, printf(CANDIDATE_FORMAT, string(index), candidate))
  endfor

  call add(messages, printf(CANDIDATE_FORMAT, string(last_index) + 1, "None"))

  echo join(messages, "\n")

  let number = input(a:message)

  if number =~ '^\d\+$' && str2nr(number) <= last_index
    let candidate = a:candidates[str2nr(number) - 1]
    return candidate
  else
    return ''
  endif
endfunction

function! alpaca_github#util#uniq(list)
  let map = {}

  for val in a:list
    let map[val] = 1
  endfor

  return keys(map)
endfunction
