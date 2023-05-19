
test:
	nvim --headless --noplugin \
		-u tests/minimal.vim \
			-c "PlenaryBustedDirectory tests/crepuscule/ {minimal_init = 'tests/minimal.vim'}"
