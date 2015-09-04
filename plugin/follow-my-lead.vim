let g:fml_all_sources=0

function! FMLGetAllSources()
  let all_maps = ""
  redir => all_maps
  silent execute "scriptnames"
  redir END
  let lines = split(all_maps, "\n")
  return map(lines, 'get(split(v:val, ": "), 1, "")')
endfunction

function! FMLGetLeaderMappings(src)
  let src_lines = readfile(glob(a:src))
  let lines_with_index = map(deepcopy(src_lines), '[v:key, v:val]') 
  let leader_parsed_lines = []
  for [idx, line] in lines_with_index
    if(line =~ '^\a*map.*<leader>.*')
      let prev_line = src_lines[idx - 1]
      let comment = matchlist(prev_line, '^"\s*\(.*\)')
      let desc = get(comment, 1, "")
      let parsed = FMLParseMapping(line)
      let parsed['desc'] = desc
      let leader_parsed_lines = add(leader_parsed_lines, parsed)
    endif
  endfor
  return leader_parsed_lines
endfunction

function! FMLParseMapping(mapping_line)
  let groups = matchlist(a:mapping_line, '\(\a\)\?\(nore\)\?map.\+<leader>\(\S\+\)\s\+\(.\+\)')
  return { 'mode': groups[1], 'lhs': groups[3], 'rhs': groups[4] }
endfunction

function! FMLFormatMappings(mappings)
  let formatted = map(a:mappings, 'printf(" %1s | %-5s | %s", v:val.mode, v:val.lhs, v:val.desc)')
  return join(formatted, "\n")
endfunction

function! FMLShow()

  let mappings = []

  if(g:fml_all_sources)
    for src in FMLGetAllSources()
      let mappings = mappings + FMLGetLeaderMappings(src)
    endfor
  else
      let mappings = FMLGetLeaderMappings($MYVIMRC)
  endif

  new
  nnoremap <buffer> <silent> q :bdelete!<cr>
  put =FMLFormatMappings(mappings)

endfunction

" Open Leader mapping in VSplit
nnoremap <Leader>fml :call FMLShow()<CR>


