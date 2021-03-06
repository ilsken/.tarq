"dein Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
endif
filetype plugin indent on

 " initialize default settings
let s:settings = {}
let s:settings.default_indent = 2
let s:settings.max_column = 120
let s:settings.enable_cursorcolumn = 0
if has('gui_running') || exists("neovim_dot_app")
  let s:settings.colorscheme = 'luna'
else 
  let s:settings.colorscheme = 'luna-term'
endif
set background=dark
" detect OS {{{
  let s:is_windows = has('win32') || has('win64')
  let s:is_cygwin = has('win32unix')
  let s:is_macvim = has('gui_macvim')
"}}}

source ~/.tarq/vim/mac.vim
let g:indent_guides_enable_on_vim_startup = 0
let g:indent_guides_auto_colors = 0
"let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 2
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd ctermfg=0 ctermbg=234 guifg=grey15 guibg=grey30
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermfg=0 ctermbg=235 guifg=grey30 guibg=grey1

autocmd FileType sls call SetupIndentGuides()
autocmd FileType yaml call SetupIndentGuides()
autocmd FileType jinja call SetupIndentGuides()
function SetupIndentGuides()
  IndentGuidesEnable
endfunction
" functions {{{
  function! Preserve(command) "{{{
    " preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " do the business:
    execute a:command
    " clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
  endfunction "}}}
  function! StripTrailingWhitespace() "{{{
    call Preserve("%s/\\s\\+$//e")
  endfunction "}}}
  function! EnsureExists(path) "{{{
    if !isdirectory(expand(a:path))
      call mkdir(expand(a:path))
    endif
  endfunction "}}}
  function! CloseWindowOrKillBuffer() "{{{
    let number_of_windows_to_this_buffer = len(filter(range(1, winnr('$')), "winbufnr(v:val) == bufnr('%')"))

    " never bdelete a nerd tree
    if matchstr(expand("%"), 'NERD') == 'NERD'
      wincmd c
      return
    endif

    if number_of_windows_to_this_buffer > 1
      wincmd c
    else
      bdelete
    endif
  endfunction "}}}
"}}}

" base configuration {{{
  set timeoutlen=300                                  "mapping timeout
  set ttimeoutlen=50                                  "keycode timeout

  set mouse=a                                         "enable mouse
  set mousehide                                       "hide when characters are typed
  set history=1000                                    "number of command lines to remember
  set ttyfast                                         "assume fast terminal connection
  set viewoptions=folds,options,cursor,unix,slash     "unix/windows compatibility
  set encoding=utf-8                                  "set encoding for text
  if exists('$TMUX')
    if !has('neovim')
      set ttymouse=xterm2                               " dragging support
    endif
    set clipboard=
  else
    "set clipboard=unnamed                             "sync with OS clipboard
  endif
  set hidden                                          "allow buffer switching without saving
  set autoread                                        "auto reload if file saved externally
  set fileformats+=mac                                "add mac to auto-detection of file format line endings
  set showcmd
  set tags=tags;/
  set showfulltag
  set modeline
  set modelines=5

 " whitespace
  set backspace=indent,eol,start                      "allow backspacing everything in insert mode
  set autoindent                                      "automatically indent to match adjacent lines
  set expandtab                                       "spaces instead of tabs
  set smarttab                                        "use shiftwidth to enter tabs
  let &tabstop=s:settings.default_indent              "number of spaces per tab for display
  let &softtabstop=s:settings.default_indent          "number of spaces per tab in insert mode
  let &shiftwidth=s:settings.default_indent           "number of spaces when indenting
  set list                                            "highlight whitespace
  set listchars=tab:│\ ,trail:•,extends:❯,precedes:❮
  set shiftround
  set linebreak
  let &showbreak='↪ '

  set scrolloff=1                                     "always show content after scroll
  set scrolljump=5                                    "minimum number of lines to scroll
  set display+=lastline
  set wildmenu                                        "show list for autocomplete
  set wildmode=list:full
  set wildignorecase
  set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.idea/*,*/.DS_Store

  set splitbelow
  set splitright
  " searching
  set hlsearch                                        "highlight searches
  set incsearch                                       "incremental searching
  set ignorecase                                      "ignore case for searching
  set smartcase                                       "do case-sensitive if there's a capital letter
  if executable('ack')
    set grepprg=ack\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow\ $*
    set grepformat=%f:%l:%c:%m
  endif
  if executable('ag')
    set grepprg=ag\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow
    set grepformat=%f:%l:%c:%m
  endif

  " vim file/folder management {{{
    " persistent undo
    if exists('+undofile')
      set undofile
      set undodir=~/.vim/.cache/undo
    endif

    " backups
    set backup
    set backupdir=~/.vim/.cache/backup

    " swap files
    set directory=~/.vim/.cache/swap
    set noswapfile

    call EnsureExists('~/.vim/.cache')
    call EnsureExists(&undodir)
    call EnsureExists(&backupdir)
    call EnsureExists(&directory)
    let mapleader = ","
    let g:mapleader = ","
" }}}
" ui configuration {{{
  set showmatch                                       "automatically highlight matching braces/brackets/etc.
  set matchtime=2                                     "tens of a second to show matching parentheses
  set number
  set lazyredraw
  set laststatus=2
  set noshowmode
  set foldenable                                      "enable folds by default
  set foldmethod=syntax                               "fold via syntax of files
  set foldlevelstart=99                               "open all folds by default
  let g:xml_syntax_folding=1                          "enable xml folding

  set cursorline
  autocmd WinLeave * setlocal nocursorline
  autocmd WinEnter * setlocal cursorline
  if has('conceal')
    set conceallevel=2
    set listchars+=conceal:Δ
  endif
  if has('gui_running')
    " open maximized
    "set lines=999 columns=9999
    if s:is_windows
      autocmd GUIEnter * simalt ~x
    endif

    set guioptions+=t                                 "tear off menu items
    set guioptions-=T                                 "toolbar icons

    if s:is_macvim
      "set gfn=monoOne:h12
      set transparency=2
    endif

    if s:is_windows
      set gfn=Ubuntu_Mono:h10
    endif

    if has('gui_gtk')
      set gfn=Ubuntu\ Mono\ 11
    endif
  else
    if $COLORTERM == 'gnome-terminal'
      set t_Co=256 "why you no tell me correct colors?!?!
    endif
    if $TERM_PROGRAM == 'iTerm.app'
      " different cursors for insert vs normal mode
      if exists('$TMUX')
        let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]1337;CursorShape=1\x7\<Esc>\\"
        let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]1337;CursorShape=0\x7\<Esc>\\"
      else
        let &t_SI = "\<Esc>]1337;CursorShape=1\x7"
        let &t_EI = "\<Esc>]1337;CursorShape=0\x7"
      endif
    endif
  endif
" }}}
" window killer
nnoremap <silent> Q :call CloseWindowOrKillBuffer()<cr>
autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \  exe 'normal! g`"zvzz' |
  \ endif
autocmd FileType vim setlocal fdm=indent keywordprg=:help
autocmd FileType python setlocal foldmethod=indent
autocmd FileType markdown setlocal nolist
autocmd BufRead,BufNewFile *.md set filetype=markdown

" screen line scroll
nnoremap <silent> j gj
nnoremap <silent> k gk

" auto center {{{
  nnoremap <silent> n nzz
  nnoremap <silent> N Nzz
  nnoremap <silent> * *zz
  nnoremap <silent> # #zz
  nnoremap <silent> g* g*zz
  nnoremap <silent> g# g#zz
  nnoremap <silent> <C-o> <C-o>zz
  nnoremap <silent> <C-i> <C-i>zz
"}}}

" reselect visual block after indent
vnoremap < <gv
vnoremap > >gv

let g:deoplete#enable_at_startup = 0
let g:deoplete#omni#functions = {}
let g:deoplete#omni#functions.php = [ 'phpcomplete#CompletePHP' ]
let g:deoplete#omni#functions.javascript = [
  \ 'tern#Complete',
  \ 'jspc#omni'
  \] 
" Use deoplete.
  let g:tern_request_timeout = 1
  let g:tern_show_signature_in_pum = '0'  " This do disable full signature type on autocomplete
  
  "Add extra filetypes
  let g:tern#filetypes = [
                  \ 'jsx',
                  \ 'javascript.jsx',
                  \ 'vue',
                  \ ]

let g:racer_cmd = "~/.cargo/bin/racer"
set hidden
au FileType rust nmap gd <Plug>(rust-def)
au FileType rust nmap gs <Plug>(rust-def-split)
au FileType rust nmap gx <Plug>(rust-def-vertical)
au FileType rust nmap <leader>gd <Plug>(rust-doc)
au FileType rust setlocal expandtab

let g:sql_type_default = 'mysql'
autocmd FileType eoz
  \ setlocal
    \ expandtab
    \ foldmethod=syntax
    \ shiftwidth=4
    \ smarttab
    \ softtabstop=0
    \ tabstop=4


autocmd Bufread,BufNewFile *.cfm,*.cfc set filetype=eoz noexpandtab
autocmd BufRead,BufNewFile ~/.ssh/conf.d/*.conf set ft=sshconfig


" Required:
set runtimepath+=~/.tarq/vim/dein.vim

" Required:
if dein#load_state(expand('~/.tarq/vim/plugins'))
  call dein#begin(expand('~/.tarq/vim/plugins'))

  " Let dein manage dein
  " Required:
  call dein#add('Shougo/dein.vim')
  call dein#add('floobits/floobits-neovim')
  call dein#add('dag/vim-fish')
  call dein#add('saltstack/salt-vim')
  call dein#add('Glench/Vim-Jinja2-Syntax')
  call dein#add('chr4/nginx.vim')
  " Add or remove your plugins here:
  "call dein#add('Shougo/neosnippet.vim')
  "call dein#add('Shougo/neosnippet-snippets')
  call dein#add("nathanaelkane/vim-indent-guides")

  " You can specify revision/branch/tag.
  " call dein#add('Shougo/vimshell', { 'rev': '3787e5' })
  " call dein#add('Shougo/vimshell')
  call dein#add('scrooloose/nerdtree')
  call dein#add('Xuyuanp/nerdtree-git-plugin')
  call dein#add('pearofducks/ansible-vim')
  call dein#add('aquach/vim-http-client')
  " unity is dead, long live denite
  call dein#add('Shougo/denite.nvim')
  " AutoSaveToggle
  call dein#add('vim-scripts/vim-auto-save')

  " autocompletion
  call dein#add('Shougo/deoplete.nvim')



  " javascript
  " call dein#add('ternjs/tern_for_vim')
  call dein#add('carlitux/deoplete-ternjs')
  call dein#add('othree/jspc.vim')


  " rust
  call dein#add('racer-rust/vim-racer')
  call dein#add('rust-lang/rust.vim')
  call dein#add('cespare/vim-toml')

  " go
  call dein#add('zchee/deoplete-go')
  " python
  call dein#add('zchee/deoplete-jedi')

  " coldufsion
  call dein#add('ernstvanderlinden/vim-coldfusion')
  
  " other syntaxes
  call dein#add('Shougo/neco-vim')
  call dein#add('Shougo/neco-syntax')
  call dein#add('zchee/deoplete-zsh')
  call dein#add('ponko2/deoplete-fish')
  call dein#add('shawncplus/phpcomplete.vim.git')

  " helpful autocomplete plugins')
  call dein#add('Shougo/context_filetype.vim')
  call dein#add('Shougo/neopairs.vim')
  call dein#add('Shougo/neoinclude.vim')
  call dein#add('Konfekt/FastFold')

  " autocomplete from open tmux panes (dope)
  call dein#add('wellle/tmux-complete.vim') 

  "color 
  "call dein#add("nanotech/jellybeans.vim")
  call dein#add("flazz/vim-colorschemes")
  " Required:
  call dein#end()
  call dein#save_state()
endif
  " denite key bindings
call denite#custom#map(
      \ 'insert',
      \ '<UP>',
      \ '<denite:move_to_previous_line>',
      \ 'noremap'
      \)
call denite#custom#map(
      \ 'insert',
      \ '<DOWN>',
      \ '<denite:move_to_next_line>',
      \ 'noremap'
      \)

call denite#custom#var('file_rec', 'command',
 \ ['rg', '--files', '--glob', '!.git'])
" \ ['ag', '--follow', '--nocolor', '--nogroup', '-g', ''])
call denite#custom#var('grep', 'command', ['rg'])
call denite#custom#var('grep', 'default_opts',
      \ ['--hidden', '--vimgrep', '--no-heading', '-S'])
call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
call denite#custom#var('grep', 'separator', ['--'])
call denite#custom#var('grep', 'final_opts', [])

call denite#custom#map('insert', '<C-s>', '<denite:do_action:vsplit>',
      \'noremap')
call denite#custom#map('normal', '<C-s>', '<denite:do_action:vsplit>',
      \'noremap')
call denite#custom#map('insert', '<M-s>', '<denite:do_action:split>',
      \'noremap')
call denite#custom#map('normal', '<M-s>', '<denite:do_action:split>',
      \'noremap')

exec 'colorscheme '.s:settings.colorscheme
set background=dark
  let g:tmuxcomplete#trigger = ''


  " denite
  nmap <space> [denite]
  nnoremap [denite] <nop>

  " search files and buffers
  nnoremap <silent> [denite]<space> :<C-u>Denite  -auto-resize -auto-resume -buffer-name=mixed file_rec buffer <cr><c-u>
  nnoremap <silent> [denite]b :<C-u>Denite  -auto-resize -auto-resume -buffer-name=mixed buffer <cr><c-u>
  nnoremap <silent> [denite]p :<C-u>DeniteProjectDir  -auto-resume -auto-resize -buffer-name=project file_rec <cr><c-u>

  " grep
  nnoremap <silent> [denite]g :<C-u>Denite -auto-resize -buffer-name=grep grep:.:! <cr><c-u>
  nnoremap <silent> [denite]pg :<C-u>DeniteProjectDir -auto-resize -buffer-name=grep grep:.:! <cr><c-u>
  nnoremap <silent> [denite]bg :<C-u>DeniteBufferDir -auto-resize -buffer-name=grep grep:.:! <cr><c-u>

  " search directories
  nnoremap <silent> [denite]d :<C-u>Denite  -auto-resize -auto-resume -buffer-name=directories directory_rec <cr><c-u>
  nnoremap <silent> [denite]pd :<C-u>DeniteProjectDir  -auto-resize -auto-resume -buffer-name=project directory_rec <cr><c-u>

  " change colorscheme 
  nnoremap <silent> [denite]c :<C-u>Denite  -auto-resize -auto-resume -buffer-name=colorscheme colorscheme <cr><c-u>
  " find in file
  nnoremap <silent> [denite]f :<C-u>Denite  -auto-resize -buffer-name=lines line <cr><c-u>
  nnoremap <silent> [denite]wf :<C-u>DeniteCursorWord  -auto-resize -buffer-name=lines line <cr><c-u>
  nnoremap <silent> [denite]o :<C-u>Denite  -auto-resize -buffer-name=outline outline <cr><c-u>

  " help
  nnoremap <silent> [denite]h :<C-u>Denite  -auto-resize -buffer-name=help help <cr><c-u>

  " registers
  nnoremap <silent> [denite]r :<C-u>Denite  -auto-resize -buffer-name=registers register <cr><c-u>

  " nerd tree
  nnoremap <silent> [denite]t :<C-u>NERDTreeToggle<cr><c-u>
  "map <C-n> 

  nnoremap <silent> [denite]s :<C-u>AutoSaveToggle<cr><c-u>


" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif
"End dein Scripts-------------------------
