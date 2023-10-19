const s:vital_http = vital#ddgv#import('Web.HTTP')

function! s:toMarkdown(lite) abort
  let l:md = []
  let l:is_snippet = 0
  for l:line in split(a:lite, '\r\n\|\n\|\r')
    let l:l = trim(l:line)
    if match(l:l, "<title>") ==# 0
      let l:title = substitute(l:l, '<[^>]*>', '', 'g')
      if l:title ==# ''
        return []
      else
        call add(l:md, $'# {l:title}')
        continue
      endif
    endif
    if match(l:l, '<a rel="nofollow"') ==# 0
      let l:title = substitute(l:l, '.*>\([^<]*\)<.*', '\1', '')
      let l:href = substitute(l:l, '.*href="\([^"]*\)".*', '\1', '')
      let l:href = substitute(l:href, '.*uddg=\([^&]*\).*', '\1', '')
      let l:href = s:vital_http.decodeURI(l:href)
      if l:title ==# ''
        continue
      endif
      call add(l:md, $'## {l:title}')
      call add(l:md, $'[Link]({l:href})')
      continue
    endif
    if match(l:l, "<td class='result-snippet'>") ==# 0
      let l:is_snippet = 1
      continue
    endif
    if match(l:l, '</td>') ==# 0
      let l:is_snippet = 0
      call add(l:md, '')
      continue
    endif
    if l:is_snippet ==# 1
      call add(l:md, substitute(l:l, '<b>\|</b>', '', 'g'))
    endif
  endfor
  return l:md
endfunction

function! ddgv#Search(query, mods) abort
  let l:res = s:vital_http.get('https://lite.duckduckgo.com/lite/', {'q': a:query})
  if l:res.status !=# 200
    throw $'Error ({l:res.status})'
  endif
  let l:md = s:toMarkdown(l:res.content)
  if len(l:md) ==# 0
    echoh WarningMsg
    echo 'no result or busy.'
    echoh Normal
    return
  endif
  execute $'{a:mods} new' substitute(get(g:, 'ddgv_bufname', '[ddgv]{query}'), '{query}', a:query, '')
  call append(0, l:md)
  normal! gg
  setlocal nomodified
  set filetype=markdown
  call matchadd('Keyword', '\V\c' .. substitute(escape(a:query, '\/'), ' \+', '\\|', 'g'))
endfunction

