
test:
	nvim --headless --noplugin \
		-u tests/minimal_init.vim \
			-c "PlenaryBustedDirectory tests/crepuscule/ {minimal_init = 'tests/minimal_init.vim'}"
