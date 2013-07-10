"==============================================================================
 "        << 判断操作系统是 Windows 还是 Linux 和判断是终端还是 Gvim >>
 "==============================================================================
 
 "------------------------------------------------------------------------------
 "  < 判断操作系统是否是 Windows 还是 Linux >
 "------------------------------------------------------------------------------
 if(has("win32") || has("win64") || has("win95") || has("win16"))
     let g:iswindows = 1
 else
     let g:iswindows = 0
 endif
 
 "------------------------------------------------------------------------------
 "  < 判断是终端还是 Gvim >
 "------------------------------------------------------------------------------
 if has("gui_running")
     let g:isGUI = 1
 else
     let g:isGUI = 0
 endif
 
 
 "==============================================================================
 "                          << 以下为软件默认配置 >>
 "==============================================================================
 
 "------------------------------------------------------------------------------
 "  < Windows Gvim 默认配置> 做了一点修改
 "------------------------------------------------------------------------------
 if (g:iswindows && g:isGUI)
     source $VIMRUNTIME/vimrc_example.vim
     source $VIMRUNTIME/mswin.vim
     behave mswin
     set diffexpr=MyDiff()
 
     function MyDiff()
         let opt = '-a --binary '
         if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
         if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
         let arg1 = v:fname_in
         if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
         let arg2 = v:fname_new
         if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
         let arg3 = v:fname_out
         if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
         let eq = ''
         if $VIMRUNTIME =~ ' '
             if &sh =~ '\<cmd'
                 let cmd = '""' . $VIMRUNTIME . '\diff"'
                 let eq = '"'
             else
                 let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
             endif
         else
             let cmd = $VIMRUNTIME . '\diff'
         endif
         silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
     endfunction
 endif
 
 "------------------------------------------------------------------------------
 "  < Linux Gvim/Vim 默认配置> 做了一点修改
 "------------------------------------------------------------------------------
 if !g:iswindows
     set hlsearch        "高亮搜索
     set incsearch       "在输入要搜索的文字时，实时匹配
 
     " Uncomment the following to have Vim jump to the last position when
     " reopening a file
     if has("autocmd")
         au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
     endif
 
     if g:isGUI
         " Source a global configuration file if available
         if filereadable("/etc/vim/gvimrc.local")
             source /etc/vim/gvimrc.local
         endif
     else
         " This line should not be removed as it ensures that various options are
         " properly set to work with the Vim-related packages available in Debian.
         runtime! debian.vim
 
         " Vim5 and later versions support syntax highlighting. Uncommenting the next
         " line enables syntax highlighting by default.
         if has("syntax")
             syntax on
         endif
 
         set mouse=a                    " 在任何模式下启用鼠标
         set t_Co=256                   " 在终端启用256色
         set backspace=2                " 设置退格键可用
 
         " Source a global configuration file if available
         if filereadable("/etc/vim/vimrc.local")
             source /etc/vim/vimrc.local
         endif
     endif
 endif
 
 
 "==============================================================================
 "                          << 以下为用户自定义配置 >>
 "==============================================================================
 
 "------------------------------------------------------------------------------
 "  < 编码配置 >
 "------------------------------------------------------------------------------
 "注：使用utf-8格式后，软件与程序源码、文件路径不能有中文，否则报错
 set encoding=utf-8                                    "gvim内部编码
 set fileencoding=utf-8                                "当前文件编码
 set fileencodings=ucs-bom,utf-8,gbk,cp936,latin-1     "支持打开文件的编码
 
 " 文件格式，默认 ffs=dos,unix
 set fileformat=unix
 set fileformats=unix,dos,mac
 
 if (g:iswindows && g:isGUI)
     "解决菜单乱码
     source $VIMRUNTIME/delmenu.vim
     source $VIMRUNTIME/menu.vim
 
     "解决consle输出乱码
     language messages zh_CN.utf-8
 endif
 
 "------------------------------------------------------------------------------
 "  < 编写文件时的配置 >
 "------------------------------------------------------------------------------
 set nocompatible                                      "关闭 Vi 兼容模式
 filetype on                                           "启用文件类型侦测
 filetype plugin on                                    "针对不同的文件类型加载对应的插件
 filetype plugin indent on                             "启用缩进
 set smartindent                                       "启用智能对齐方式
 set expandtab                                         "将tab键转换为空格
 set tabstop=4                                         "设置tab键的宽度
 set shiftwidth=4                                      "换行时自动缩进4个空格
 set smarttab                                          "指定按一次backspace就删除4个空格
 set foldenable                                        "启用折叠
 set foldmethod=indent                                 "indent 折叠方式
" set foldmethod=marker                                "marker 折叠方式
 set guifont=Monospace\ 11                             "设置字体和大小
 "用空格键来开关折叠
 nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>
 
 "当文件在外部被修改，自动更新该文件
 set autoread
 
 "常规模式下输入 cs 清除行尾空格
 nmap cs :%s/\s\+$//g<cr>:noh<cr>
 
 "常规模式下输入 cm 清除行尾 ^M 符号
 nmap cm :%s/\r$//g<cr>:noh<cr>
 
 set ignorecase                                        "搜索模式里忽略大小写
 set smartcase                                         "如果搜索模式包含大写字符，不使用 'ignorecase' 选项，只有在输入搜索模式并且打开 'ignorecase' 选项时才会使用
 "set noincsearch                                       "在输入要搜索的文字时，取消实时匹配
 
 " Ctrl + K 插入模式下光标向上移动
 imap <c-k> <Up>
 
 " Ctrl + J 插入模式下光标向下移动
 imap <c-j> <Down>
 
 " Ctrl + H 插入模式下光标向左移动
 imap <c-h> <Left>
 
 " Ctrl + L 插入模式下光标向右移动
 imap <c-l> <Right>
 
 "每行超过80个的字符用下划线标示
 "au BufWinEnter * let w:m2=matchadd('Underlined', '\%>' . 80 . 'v.\+', -1)
 
 "------------------------------------------------------------------------------
 "  < 界面配置 >
 "------------------------------------------------------------------------------
 set number                                            "显示行号
 set laststatus=2                                      "开启状态栏信息
 set cmdheight=1                                       "设置命令行的高度为2，默认为1
 set cursorline                                        "突出显示当前行
 "set guifont=DejaVu_Sans_Mono:h10                      "设置字体:字号（字体名称空格用下划线代替）
 set nowrap                                            "设置不自动换行
 set shortmess=atI                                     "去掉欢迎界面
 "au GUIEnter * simalt ~x                              "窗口启动时自动最大化
 winpos 100 20                                         "指定窗口出现的位置，坐标原点在屏幕左上角
 set lines=45 columns=120                              "指定窗口大小，lines为高度，columns为宽度
 
 "设置代码配色方案
 if g:isGUI
     colorscheme desert               "Gvim配色方案
 else
     colorscheme desert "终端配色方案
 endif


 "自动补全窗口的配色，Pmenu 是所有项的配色，PmenuSel 是选中项的配色，guibg 和 guifg 分别对应背景色和前景色。
 "highlight Pmenu    guibg=darkgrey  guifg=black 
 "highlight PmenuSel guibg=lightgrey guifg=black
 
 "个性化状态栏（这里提供两种方式，要使用其中一种去掉注释即可，不使用反之）
 let &statusline=' %t %{&mod?(&ro?"*":"+"):(&ro?"=":" ")} %1*|%* %{&ft==""?"any":&ft} %1*|%* %{&ff} %1*|%* %{(&fenc=="")?&enc:&fenc}%{(&bomb?",BOM":"")} %1*|%* %=%1*|%* 0x%B %1*|%* (%l,%c%V) %1*|%* %L %1*|%* %P'
 "set statusline=%t\ %1*%m%*\ %1*%r%*\ %2*%h%*%w%=%l%3*/%L(%p%%)%*,%c%V]\ [%b:0x%B]\ [%{&ft==''?'TEXT':toupper(&ft)},%{toupper(&ff)},%{toupper(&fenc!=''?&fenc:&enc)}%{&bomb?',BOM':''}%{&eol?'':',NOEOL'}]
 
 "显示/隐藏菜单栏、工具栏、滚动条，可用 Ctrl + F11 切换
 if g:isGUI
     map <silent> <c-F11> :if &guioptions =~# 'm' <Bar>
         \set guioptions-=m <Bar>
         \set guioptions-=T <Bar>
         \set guioptions-=r <Bar>
         \set guioptions-=L <Bar>
     \else <Bar>
         \set guioptions+=m <Bar>
         \set guioptions+=T <Bar>
         \set guioptions+=r <Bar>
         \set guioptions+=L <Bar>
     \endif<CR>
 endif
 
 "------------------------------------------------------------------------------
 "  < 编译、连接、运行配置 >
 "------------------------------------------------------------------------------
 " F9 一键保存、编译、连接存并运行
 map <F9> :call Run()<CR>
 imap <F9> <ESC>:call Run()<CR>
 
 " Ctrl + F9 一键保存并编译
 map <c-F9> :call Compile()<CR>
 imap <c-F9> <ESC>:call Compile()<CR>
 
 " Ctrl + F10 一键保存并连接
 map <c-F10> :call Link()<CR>
 imap <c-F10> <ESC>:call Link()<CR>
 
 let s:LastShellReturn_C = 0
 let s:LastShellReturn_L = 0
 let s:ShowWarning = 1
 let s:Obj_Extension = '.o'
 let s:Exe_Extension = '.exe'
 let s:Sou_Error = 0
 
 let s:windows_CFlags = 'gcc\ -fexec-charset=gbk\ -Wall\ -g\ -O0\ -c\ %\ -o\ %<.o'
 let s:linux_CFlags = 'gcc\ -Wall\ -g\ -O0\ -c\ %\ -o\ %<.o'
 
 let s:windows_CPPFlags = 'g++\ -fexec-charset=gbk\ -Wall\ -g\ -O0\ -c\ %\ -o\ %<.o'
 let s:linux_CPPFlags = 'g++\ -Wall\ -g\ -O0\ -c\ %\ -o\ %<.o'
 
 func! Compile()
     exe ":ccl"
     exe ":update"
     if expand("%:e") == "c" || expand("%:e") == "cpp" || expand("%:e") == "cxx"
         let s:Sou_Error = 0
         let s:LastShellReturn_C = 0
         let Sou = expand("%:p")
         let Obj = expand("%:p:r").s:Obj_Extension
         let Obj_Name = expand("%:p:t:r").s:Obj_Extension
         let v:statusmsg = ''
         if !filereadable(Obj) || (filereadable(Obj) && (getftime(Obj) < getftime(Sou)))
             redraw!
             if expand("%:e") == "c"
                 if g:iswindows
                     exe ":setlocal makeprg=".s:windows_CFlags
                 else
                     exe ":setlocal makeprg=".s:linux_CFlags
                 endif
                 echohl WarningMsg | echo " compiling..."
                 silent make
             elseif expand("%:e") == "cpp" || expand("%:e") == "cxx"
                 if g:iswindows
                     exe ":setlocal makeprg=".s:windows_CPPFlags
                 else
                     exe ":setlocal makeprg=".s:linux_CPPFlags
                 endif
                 echohl WarningMsg | echo " compiling..."
                 silent make
             endif
             redraw!
             if v:shell_error != 0
                 let s:LastShellReturn_C = v:shell_error
             endif
             if g:iswindows
                 if s:LastShellReturn_C != 0
                     exe ":bo cope"
                     echohl WarningMsg | echo " compilation failed"
                 else
                     if s:ShowWarning
                         exe ":bo cw"
                     endif
                     echohl WarningMsg | echo " compilation successful"
                 endif
             else
                 if empty(v:statusmsg)
                     echohl WarningMsg | echo " compilation successful"
                 else
                     exe ":bo cope"
                 endif
             endif
         else
             echohl WarningMsg | echo ""Obj_Name"is up to date"
         endif
     else
         let s:Sou_Error = 1
         echohl WarningMsg | echo " please choose the correct source file"
     endif
     exe ":setlocal makeprg=make"
 endfunc
 
 func! Link()
     call Compile()
     if s:Sou_Error || s:LastShellReturn_C != 0
         return
     endif
     let s:LastShellReturn_L = 0
     let Sou = expand("%:p")
     let Obj = expand("%:p:r").s:Obj_Extension
     if g:iswindows
         let Exe = expand("%:p:r").s:Exe_Extension
         let Exe_Name = expand("%:p:t:r").s:Exe_Extension
     else
         let Exe = expand("%:p:r")
         let Exe_Name = expand("%:p:t:r")
     endif
     let v:statusmsg = ''
  if filereadable(Obj) && (getftime(Obj) >= getftime(Sou))
         redraw!
         if !executable(Exe) || (executable(Exe) && getftime(Exe) < getftime(Obj))
             if expand("%:e") == "c"
                 setlocal makeprg=gcc\ -o\ %<\ %<.o
                 echohl WarningMsg | echo " linking..."
                 silent make
             elseif expand("%:e") == "cpp" || expand("%:e") == "cxx"
                 setlocal makeprg=g++\ -o\ %<\ %<.o
                 echohl WarningMsg | echo " linking..."
                 silent make
             endif
             redraw!
             if v:shell_error != 0
                 let s:LastShellReturn_L = v:shell_error
             endif
             if g:iswindows
                 if s:LastShellReturn_L != 0
                     exe ":bo cope"
                     echohl WarningMsg | echo " linking failed"
                 else
                     if s:ShowWarning
                         exe ":bo cw"
                     endif
                     echohl WarningMsg | echo " linking successful"
                 endif
             else
                 if empty(v:statusmsg)
                     echohl WarningMsg | echo " linking successful"
                 else
                     exe ":bo cope"
                 endif
             endif
         else
             echohl WarningMsg | echo ""Exe_Name"is up to date"
         endif
     endif
     setlocal makeprg=make
 endfunc
 
 func! Run()
     let s:ShowWarning = 0
     call Link()
     let s:ShowWarning = 1
     if s:Sou_Error || s:LastShellReturn_C != 0 || s:LastShellReturn_L != 0
         return
     endif
     let Sou = expand("%:p")
     let Obj = expand("%:p:r").s:Obj_Extension
     if g:iswindows
         let Exe = expand("%:p:r").s:Exe_Extension
     else
         let Exe = expand("%:p:r")
     endif
     if executable(Exe) && getftime(Exe) >= getftime(Obj) && getftime(Obj) >= getftime(Sou)
         redraw!
         echohl WarningMsg | echo " running..."
         if g:iswindows
             exe ":!%<.exe"
         else
             if g:isGUI
                 exe ":!gnome-terminal -e ./%<"
             else
                 exe ":!./%<"
             endif
         endif
         redraw!
         echohl WarningMsg | echo " running finish"
     endif
 endfunc
 
 "------------------------------------------------------------------------------
 "  < 其它配置 >
 "------------------------------------------------------------------------------
 set writebackup                             "保存文件前建立备份，保存成功后删除该备份
 set nobackup                                "设置无备份文件
 "set noswapfile                              "设置无临时文件
 set vb t_vb=                                "关闭提示音
 "自动补全括号
inoremap ( ()<Esc>i
inoremap [ []<Esc>i
inoremap { {<CR>}<Esc>O
autocmd Syntax html,vim inoremap < <lt>><Esc>i| inoremap > <c-r>=ClosePair('>')<CR>
inoremap ) <c-r>=ClosePair(')')<CR>
inoremap ] <c-r>=ClosePair(']')<CR>
inoremap } <c-r>=CloseBracket()<CR>
inoremap " <c-r>=QuoteDelim('"')<CR>
inoremap ' <c-r>=QuoteDelim("'")<CR>


function ClosePair(char)
    if getline('.')[col('.') - 1] == a:char
        return "\<Right>"
    else
        return a:char
    endif
endf


function CloseBracket()
    if match(getline(line('.') + 1), '\s*}') < 0
        return "\<CR>}"
    else
        return "\<Esc>j0f}a"
    endif
endf


function QuoteDelim(char)
    let line = getline('.')
    let col = col('.')
    if line[col - 2] == "\\"
        "Inserting a quoted quotation mark into the string
        return a:char
    elseif line[col - 1] == a:char
        "Escaping out of the string
        return "\<Right>"
    else
        "Starting a string
        return a:char.a:char."\<Esc>i"
    endif
endf 
 
 "==============================================================================
 "                          << 以下为常用插件配置 >>
 "==============================================================================
 "------------------------------------------------------------------------------
 "  < ctags 插件配置 >
 "------------------------------------------------------------------------------
 "对浏览代码非常的方便,可以在函数,变量之间跳转等
 set tags=./tags;                            "向上级目录递归查找tags文件（好像只有在Windows下才有用）
 set tags+=~/code/tags/cpp
  
 "------------------------------------------------------------------------------
 "  < TagList 插件配置 >
 "------------------------------------------------------------------------------
 "高效地浏览源码, 其功能就像vc中的workpace
 "那里面列出了当前文件中的所有宏,全局变量, 函数名等
 
 "常规模式下输入 tl 调用插件，如果有打开 Tagbar 窗口则先将其关闭
 nmap tl :Tlist<cr>
 
 let Tlist_Show_One_File=1                   "只显示当前文件的tags
 "let Tlist_Enable_Fold_Column=0              "使taglist插件不显示左边的折叠行
 let Tlist_Exit_OnlyWindow=1                 "如果Taglist窗口是最后一个窗口则退出Vim
 let Tlist_File_Fold_Auto_Close=1            "自动折叠
 let Tlist_WinWidth=30                       "设置窗口宽度
 " let Tlist_Use_Right_Window=1                "在右侧窗口中显示
 
 "------------------------------------------------------------------------------
 "  < cscope 插件配置 >
 "------------------------------------------------------------------------------
 "用Cscope自己的话说 - "你可以把它当做是超过频的ctags"
 if has("cscope")
     "设定可以使用 quickfix 窗口来查看 cscope 结果
     set cscopequickfix=s-,c-,d-,i-,t-,e-
     "使支持用 Ctrl+]  和 Ctrl+t 快捷键在代码间跳转
     set cscopetag
     "如果你想反向搜索顺序设置为1
     set csto=0
     "在当前目录中添加任何数据库
     if filereadable("cscope.out")
         cs add cscope.out
     "否则添加数据库环境中所指出的
     elseif $CSCOPE_DB != ""
         cs add $CSCOPE_DB
     endif
     set cscopeverbose
     "快捷键设置
     nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
     nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
     nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
     nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
     nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
     nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
     nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
     nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>
 endif


 "------------------------------------------------------------------------------
 "  < WinManager 插件配置 >
 "------------------------------------------------------------------------------
 "管理各个窗口, 或者说整合各个窗口
 
 "常规模式下输入 F3 调用插件
 nmap <F3> :WMToggle<cr>
 
 "这里可以设置为多个窗口, 如'FileExplorer|TagList'
 let g:winManagerWindowLayout='FileExplorer|TagList'
 
 let g:persistentBehaviour=0                 "只剩一个窗口时, 退出vim
 let g:winManagerWidth=30                    "设置窗口宽度

"------------------------------------------------------------------------------
 "  < MiniBufExplorer 插件配置 >
 "------------------------------------------------------------------------------
 "快速浏览和操作Buffer
 "主要用于同时打开多个文件并相与切换
 
 "let g:miniBufExplMapWindowNavArrows = 1     "用Ctrl加方向键切换到上下左右的窗口中去
 let g:miniBufExplMapWindowNavVim = 1        "用<C-k,j,h,l>切换到上下左右的窗口中去
 let g:miniBufExplMapCTabSwitchBufs = 1      "功能增强（不过好像只有在Windows中才有用）
 "                                            <C-Tab> 向前循环切换到每个buffer上,并在但前窗口打开
 "                                            <C-S-Tab> 向后循环切换到每个buffer上,并在当前窗口打开

 
 "------------------------------------------------------------------------------
 "  < omnicppcomplete 插件配置 >
 "------------------------------------------------------------------------------
 "用于C/C++代码补全，这种补全主要针对命名空间、类、结构、共同体等进行补全，详细
 "说明可以参考帮助或网络教程等
 "使用前先执行如下 ctags 命令
 "ctags -R --c++-kinds=+p --fields=+iaS --extra=+q
 "我使用上面的参数生成标签后，对函数使用跳转时会出现多个选择
 "所以我就将--c++-kinds=+p参数给去掉了，如果大侠有什么其它解决方法希望不要保留呀
 set completeopt=menu                        "关闭预览窗口


 "------------------------------------------------------------------------------
 "  < supertab 插件配置 >
 "------------------------------------------------------------------------------
 "我主要用于配合 omnicppcomplete 插件，在按 Tab 键时自动补全效果更好更快

