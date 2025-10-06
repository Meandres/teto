{ pkgs, ... } : {
	programs.nixvim = {
		enable = true;
		defaultEditor = true;
		colorschemes.kanagawa.enable = true;
		colorschemes.kanagawa.settings.theme = "dragon";
    plugins.web-devicons.enable = true;
		vimAlias = true;
		plugins = {
			airline.enable = true;
			barbar = {
				enable = true;
				settings = {
					auto_hide = 1;
					clickable = true;
				};
			};
			gitgutter.enable = true;
		};
		
		extraConfigVim = ''
			set expandtab
			set ignorecase
			set number
			set shiftwidth=2
			set tabstop=2
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

			if has('termguicolors')
    		set termguicolors
			endif

		'';
		#set background=dark
	};
}
