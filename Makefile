.PHONY: docgen test clean

TS_DIR := deps/tree-sitter-lua
PLENARY_DIR := deps/plenary.nvim
TELESCOPE_DIR := deps/telescope.nvim

docgen-deps:
	@mkdir -p deps
	@if [ ! -d "$(TS_DIR)" ]; then \
		git clone --depth 1 https://github.com/tjdevries/tree-sitter-lua $(TS_DIR); \
	else \
		git -C "$(TS_DIR)" pull; \
	fi
	cd "$(TS_DIR)" && make dist


test-deps:
	@mkdir -p deps
	@if [ ! -d "$(PLENARY_DIR)" ]; then \
		git clone --depth 1 https://github.com/nvim-lua/plenary.nvim $(PLENARY_DIR); \
	else \
		git -C "$(PLENARY_DIR)" pull; \
	fi

	@if [ ! -d "$(TELESCOPE_DIR)" ]; then \
		git clone --depth 1 https://github.com/nvim-telescope/telescope.nvim $(TELESCOPE_DIR); \
	else \
		git -C "$(TELESCOPE_DIR)" pull; \
	fi

docgen: docgen-deps
	nvim --headless --noplugin -u scripts/minimal_init.vim -c "luafile ./scripts/gendocs.lua" -c 'qa'

test: test-deps
	nvim --headless --noplugin -u scripts/minimal_init.vim -c "PlenaryBustedDirectory lua/tests/ { minimal_init = './scripts/minimal_init.vim' }"

clean:
	rm -rf deps
