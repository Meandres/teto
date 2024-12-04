{ pkgs, ... } : {
	programs.vim = {
		enable = true;
		defaultEditor = true;
		settings = {
			expandtab = true;
			ignorecase = true;
			number = true;
			shiftwidth = 2;
			tabstop = 2;	
		};
		extraConfig = ''
			set nocompatible
			filetype on
			filetype plugin on
			filetype indent on
			syntax enable
			set nobackup
			set ignorecase
			set hlsearch
			set history=1000
			set wildmenu
			set wildmode=list:longest
			set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.odt,*.exe,*.img

			nnoremap <C-t> :NERDTree<CR>
			let g:ycm_autoclose_preview_window_after_insertion=1
			let g:rustfmt_autosave=1

			if has('termguicolors')
    		set termguicolors
			endif

			set background=dark
			let g:everforest_background='hard'
			let g:everforest_better_performance=1

			colorscheme everforest
			let g:airline_theme = 'everforest'
		'';
	plugins = [
		pkgs.vimPlugins.vim-addon-nix
		pkgs.vimPlugins.ale
		pkgs.vimPlugins.vim-polyglot
		pkgs.vimPlugins.everforest
		pkgs.vimPlugins.vim-surround
		pkgs.vimPlugins.vim-airline
		pkgs.vimPlugins.vim-gitgutter
		pkgs.vimPlugins.YouCompleteMe
	];
	};
}
