if exists('b:current_syntax') && b:current_syntax == 'json.portkey'
  finish
end

" external portkeys include
syn keyword portkeyInclude portkeys contained

" app/models/*.foo style pattern
syn match portkeyPattern '.*\*[^"]*' contained
syn match portkeyPatternPlaceholder '*' containedin=portkeyPattern

" template %s style modifiers
syn match portkeyModifier '\v\%[a-zA-Z]' contained

" template %{source|foo} placeholders
syn region portkeyPlaceholder matchgroup=portkeyPlaceholderDelimiter start='%{' end='}' skip='\\' skipwhite contains=jsonString

" extend json.vim strings to include above items
syn region  jsonString oneline matchgroup=jsonQuote start=/"/  skip=/\\\\\|\\"/  end=/"/ contains=jsonEscape,portkeyModifier,portkeyPatternPlaceholder,portkeyInclude,portkeyPlaceholder,portkeyPattern

" keywords
" MUST be after jsonString
syn match portkeyKeyword '\v"%(type|command|affinity|alternate|related|test|template|compiler|keywords|scope|mapping)":'

" highlighting
hi def link portkeyInclude Include
hi def link portkeyPatternPlaceholder Special
hi def link portkeyPattern Statement
hi def link portkeyKeyword Identifier
hi def link portkeyModifier Special
hi def link portkeyPlaceholderDelimiter Delimiter
hi def link portkeyPlaceholder Special

" default styles
if !exists('g:portkey_json_no_default_styles')
  hi portkeyPattern gui=bold term=bold cterm=bold
end

if !exists('g:portkey_json_no_expensive')
  syn sync fromstart
end

let b:current_syntax = 'json.portkey'
