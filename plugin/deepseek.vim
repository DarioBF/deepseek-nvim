" deepseek.vim

if exists('g:loaded_deepseek_nvim')
  finish
endif
let g:loaded_deepseek_nvim = 1

" Comando para activar DeepSeek Coder
command! DeepSeekSuggest lua require('deepseek').suggest()

" Mapeo de teclas para activar DeepSeek Coder
nnoremap <leader>ds :DeepSeekSuggest<CR>
