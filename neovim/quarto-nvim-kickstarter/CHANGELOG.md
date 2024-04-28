# Changelog

## [3.7.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v3.6.0...v3.7.0) (2024-04-15)


### Features

* tabularize plugin ([d63759b](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/d63759b3552dcc509de705cae0e1c6ff88be5139))


### Bug Fixes

* lazy.nvim colorscheme ([b3893cd](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/b3893cd0a57179cd937c5417d75dbe43f948c287))

## [3.6.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v3.5.0...v3.6.0) (2024-04-13)


### Features

* preview image under cursor with &lt;leader&gt;io ([a89dc45](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/a89dc45106d687213031c7df3851ed79f1324324))

## [3.5.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v3.4.0...v3.5.0) (2024-04-12)


### Features

* disable eob fill chars for better png previews ([12363f0](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/12363f0555845b1d5b5ba4549b58a96a2fa93e8c))


### Bug Fixes

* don't prompt for ipython or R exit/save ([a213e66](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/a213e66fbadfaa43b9fc2f011185498ba95d409e))
* **keymap:** toggle dark/light ([21d554e](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/21d554e3f9599ab40be3d702a49f7a441b9bbb26))


### Performance Improvements

* **startup:** only load image.nvim for certain ft ([8377fd8](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/8377fd8833c293bf2ed6583db99a7932bb1fef9a))

## [3.4.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v3.3.0...v3.4.0) (2024-04-11)


### Features

* exclude quarto docs output dir from telescope grep ([9fc14a9](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/9fc14a91a4ac33d7374ac9109c82f959ba168be2))
* highlight quarto code chunks without plugin ([#103](https://github.com/jmbuhr/quarto-nvim-kickstarter/issues/103)) ([9fc14a9](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/9fc14a91a4ac33d7374ac9109c82f959ba168be2))
* make animals more visible ([9fc14a9](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/9fc14a91a4ac33d7374ac9109c82f959ba168be2))


### Bug Fixes

* colorizer config ([9fc14a9](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/9fc14a91a4ac33d7374ac9109c82f959ba168be2))
* don't show mode in cmd line, already in statusline ([9fc14a9](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/9fc14a91a4ac33d7374ac9109c82f959ba168be2))
* hide more quarto output dirs from search ([9fc14a9](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/9fc14a91a4ac33d7374ac9109c82f959ba168be2))
* lsp examples ([9fc14a9](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/9fc14a91a4ac33d7374ac9109c82f959ba168be2))

## [3.3.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v3.2.2...v3.3.0) (2024-04-07)


### Features

* use new default color scheme on nvim 0.10 ([486de9c](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/486de9ccc4b34364632224c5f0c8a7243d96c558))

## [3.2.2](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v3.2.1...v3.2.2) (2024-04-03)


### Bug Fixes

* don't enable copilot by default ([2aca490](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/2aca49035e8f584b6bd741f818327b1822803a34))
* only enabled dropar.nvim if nvim version &gt;= 0.10 ([c4b4586](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/c4b45864c811d6304ded738a463670537c6690f3))

## [3.2.1](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v3.2.0...v3.2.1) (2024-03-18)


### Bug Fixes

* add unicorn ([42d525b](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/42d525b9c0959dce7928540fec4b6fc7902b96f9))

## [3.2.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v3.1.2...v3.2.0) (2024-03-18)


### Features

* (lazily) enable Octo ([fba5647](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/fba5647410b82b9c624f8c817378ea1d9f82b685))


### Bug Fixes

* statusline add missing mode 's' ([3696640](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/369664060396c8010a7d227b4d2124b47866febf))

## [3.1.2](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v3.1.1...v3.1.2) (2024-03-13)


### Bug Fixes

* set math.randomseed to ensure a different animal in the ([b2c0854](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/b2c085452b6dcc98e3b1554d3192e330ecc5cbc2))

## [3.1.1](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v3.1.0...v3.1.1) (2024-03-07)


### Bug Fixes

* put neodev in the correct place ([1599d69](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/1599d699a53b99dcbd7cdfb48435a0af834b6a54))

## [3.1.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v3.0.2...v3.1.0) (2024-03-06)


### Features

* packadd cfilter ([d5094d3](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/d5094d3aa65c8f320cf11d00035ec1c4b3e3269d))
* random animal in status line ([20784d1](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/20784d1b3a1b98e2bc17b7f7ba0773a746a706b6))
* reticulate treatment for sending visual selection ([ed52007](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/ed520071a97ae749e23321c38b3727577c9f40cc))

## [3.0.2](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v3.0.1...v3.0.2) (2024-03-05)


### Bug Fixes

* put headlines config in config function instead of opts to avoid running treesitter parsing code before init. fixes [#89](https://github.com/jmbuhr/quarto-nvim-kickstarter/issues/89) ([6e4342f](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/6e4342fb0ad9b78b6b4dd7bd1cc383b7f36fb1dd))

## [3.0.1](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v3.0.0...v3.0.1) (2024-03-05)


### Bug Fixes

* call which-key setup. refs [#89](https://github.com/jmbuhr/quarto-nvim-kickstarter/issues/89) ([846324a](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/846324a030e2baf49a686118ac3b3e66d8b40fed))

## [3.0.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v2.5.1...v3.0.0) (2024-03-04)


### ⚠ BREAKING CHANGES

* big spring cleaning ([#87](https://github.com/jmbuhr/quarto-nvim-kickstarter/issues/87))

### Features

* big spring cleaning ([#87](https://github.com/jmbuhr/quarto-nvim-kickstarter/issues/87)) ([22f9c80](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/22f9c80a924382dda9ee29c8c2efda6ae89c826d))

## [2.5.1](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v2.5.0...v2.5.1) (2024-03-03)


### Bug Fixes

* use pyright for whole workspace (might make it slower) ([8a873d4](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/8a873d4a49dedfeb4378bdfd1a528c7d4a070fdf))

## [2.5.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v2.4.0...v2.5.0) (2024-03-02)


### Features

* add preliminary completion for observable js chunks ([a9ee42d](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/a9ee42d81a3d727d500ec86e5c93d2369afadbc6))
* example keybinding to ask R console for interactive table of ([b34cc94](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/b34cc94b8fe51ea3edc1ab504e1c3293c55803aa))
* rust and norg injections ([66c5fbb](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/66c5fbb4c6985be94f0947d40bfcf86600030026))


### Bug Fixes

* automatic r/python switching with reticulate ([bd548bf](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/bd548bfa8f915a0f42109d97143a99654f04cca1))
* set quato_r_mode buffer variable ([cb64ee7](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/cb64ee737a1279ab6a58c6fd2548fb202334063b))
* update img-clip plugin config for new version ([#85](https://github.com/jmbuhr/quarto-nvim-kickstarter/issues/85)) ([d62b8a9](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/d62b8a97574ceb284b1424d02564326945ea4275))


### Performance Improvements

* update instead of write for &lt;c-s&gt; keybinding ([b52207c](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/b52207c5fc9d2d7d0e985cfb9aac500f941e3de3))

## [2.4.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v2.3.0...v2.4.0) (2024-02-12)


### Features

* automatically open and close reticulate python repl in R terminal when R ([23c5536](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/23c5536b0106d4d3cd000bb475c8ba7acf38f9f6))
* new image paste plugin ([8486169](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/84861698bca25d6f181dbba74ded734a7208f75e))

## [2.3.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v2.2.0...v2.3.0) (2023-12-22)


### Features

* add ls for dot graphviz ([205bcc9](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/205bcc98b4286c32334530c06d33a9a8419f314f))
* create new terminals in a vertical split instead of below ([d4bab6c](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/d4bab6c94661fdcc68f688f57448ec5b0e7c360d))

## [2.2.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v2.1.0...v2.2.0) (2023-11-28)


### Features

* configure paste image plugin for quarto and add molten example ([24470a6](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/24470a63bd03745a792f316c98adca79f1cd8951))

## [2.1.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v2.0.1...v2.1.0) (2023-11-21)


### Features

* exempt markdown headings from `]]` `[[` ts textobjects jumps ([c80622d](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/c80622d6a51a1108cfad1fff51ea60fd5e0780c7))

## [2.0.1](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v2.0.0...v2.0.1) (2023-11-16)


### Performance Improvements

* improve pyright performance ([edee5bc](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/edee5bc5b38ac08e5a7893f5a4f57b6f797e41f9))

## [2.0.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v1.0.0...v2.0.0) (2023-11-15)


### ⚠ BREAKING CHANGES

* **python:** back to pyright as the default ls for python

### Features

* **python:** back to pyright as the default ls for python ([2cc48a8](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/2cc48a84855b462d360ea5607237a284ba1d85ba))


### Bug Fixes

* hide quarto magic comments from python linter warnings ([5d11e60](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/5d11e607352f49b02d9f9fb3caddc96dfba6ef4d))
* maybe fix [#69](https://github.com/jmbuhr/quarto-nvim-kickstarter/issues/69) ([1c2e986](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/1c2e9864e995efd5aaa151e8bb60c908a2584570))

## [1.0.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.23.2...v1.0.0) (2023-11-12)


### ⚠ BREAKING CHANGES

* pyright somehow manages to block the editor even when just scrolling and leads to blocking at startup.

### Bug Fixes

* disable indent-blankline due to performance issues ([3d7d1b4](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/3d7d1b4979c5e3432084251862dca6d806ef35ff))


### Performance Improvements

* replace pyright with python-lsp-server and mypy plugin ([9a48780](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/9a48780d43a479c53ad8153e06c6b1c6c9e43540))

## [0.23.2](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.23.1...v0.23.2) (2023-11-03)


### Bug Fixes

* tmux version check ([0a3d522](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/0a3d522f605766f985d565d669a679b5513201c6))

## [0.23.1](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.23.0...v0.23.1) (2023-10-29)


### Bug Fixes

* check nvim version before usage of vim.system. fixes [#63](https://github.com/jmbuhr/quarto-nvim-kickstarter/issues/63) ([524f453](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/524f453000d5393e7bac07a0925bd8ed5c9b5a42))

## [0.23.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.22.4...v0.23.0) (2023-10-28)


### Features

* implement many tweaks from dev and format with stylua ([e903301](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/e90330100606514908c216f40235df247ae7a4f2))
* test image.lua requirements ([f6a6059](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/f6a605973bb6d1eecd98a1e18ae79999f3178f31))


### Bug Fixes

* add example for custom yaml schema ([d2e3d5e](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/d2e3d5e4262e678015c393d7b9a7eeb4d453fa2d))

## [0.22.4](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.22.3...v0.22.4) (2023-10-17)


### Bug Fixes

* remove outdated indent-blankline settings ([8413978](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/8413978ad750b40c599e8f1b6b15a15f964ef01b)), closes [#95](https://github.com/jmbuhr/quarto-nvim-kickstarter/issues/95)

## [0.22.3](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.22.2...v0.22.3) (2023-09-28)


### Bug Fixes

* indent blankline v3 setup ([#59](https://github.com/jmbuhr/quarto-nvim-kickstarter/issues/59)) ([8fd3b54](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/8fd3b54822fb7817acf4613dd1ce6f51b3889d1a))

## [0.22.2](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.22.1...v0.22.2) (2023-09-15)


### Bug Fixes

* make neotest quit keymap buffer local ([fc9b431](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/fc9b43152457174dabcb05ae7b5a1628d8ac246c))

## [0.22.1](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.22.0...v0.22.1) (2023-08-29)


### Bug Fixes

* Update welcome-screen.lua ([#55](https://github.com/jmbuhr/quarto-nvim-kickstarter/issues/55)) ([ce92480](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/ce92480f82228ec0896a1af94794c0116cb38841))

## [0.22.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.21.0...v0.22.0) (2023-08-27)


### Features

* **editing:** wrap markdown by words ([4ae6c9f](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/4ae6c9f2d74e22d84ffc76398b25f104d9005986))
* format code chunk in qmd document ([4ae6c9f](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/4ae6c9f2d74e22d84ffc76398b25f104d9005986))
* preview equations ([4ae6c9f](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/4ae6c9f2d74e22d84ffc76398b25f104d9005986))
* **theme:** add onedark ([4ae6c9f](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/4ae6c9f2d74e22d84ffc76398b25f104d9005986))


### Bug Fixes

* cleanup ([f2bc9af](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/f2bc9afa092a16ef963db9ab9b6e22bec51102e7))

## [0.21.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.20.1...v0.21.0) (2023-07-28)


### Features

* nvim-spectre for global search and replace ([f441014](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/f441014e1ae9d3e268160a408f4281588cb22446))

## [0.20.1](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.20.0...v0.20.1) (2023-07-17)


### Bug Fixes

* fix on_attach ([ba10d9e](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/ba10d9e9463a6c2505ab1d9c9c29e757affc0d70))

## [0.20.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.19.1...v0.20.0) (2023-07-17)


### Features

* move neodev next to lspconfig and enable ([e7d7f2a](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/e7d7f2a1ad2c9593dab4cc755bb52b39e970bea6))
* yamlls ([7edd387](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/7edd387649f912d1315181e7687a1954b57b5331))

## [0.19.1](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.19.0...v0.19.1) (2023-07-11)


### Bug Fixes

* don't use version restriction for now until more widespread ([8367109](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/8367109a8733c0f835b86c0f9d49abfaa3274732))

## [0.19.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.18.3...v0.19.0) (2023-07-05)


### Features

* symbol outline (lazyloaded) ([5e7eb0c](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/5e7eb0c7d45831f5b2b0915740e851c8a7ce7e63))


### Bug Fixes

* disambiguate keybindings for git conflict ([b858124](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/b8581242dc54f857a9a5b9c2231adba54c0ec8dd))
* vim-slime delim for R ([ba01fb4](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/ba01fb4ac1fd05fb0df97605adbe77a859052c8f))

## [0.18.3](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.18.2...v0.18.3) (2023-07-03)


### Bug Fixes

* back to vim.loop instead of vim.uv until nvim v0.10 is released ([1f14aa1](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/1f14aa10775aa9cb828eb1e72efc0326d8482565))

## [0.18.2](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.18.1...v0.18.2) (2023-07-03)


### Bug Fixes

* fix git diffview keybindings ([1c3570f](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/1c3570fd6f1561003bc5ad4368e7507c55cb3b39))
* neogit moved to new user/org ([9b1e426](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/9b1e42612d9606e96aebf2bd322ca0927b4367ff))


### Performance Improvements

* disable scrollview ([0c49ab8](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/0c49ab801cad2a127a78205860248d894c810271))
* faster pyright config ([760feff](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/760feff4838a293e5eb96c642d6fbc6a50d6a16c))

## [0.18.1](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.18.0...v0.18.1) (2023-06-30)


### Bug Fixes

* luasnip package.json ([eaf9688](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/eaf96886724d0a6d6b812e854235da6808c6034d))

## [0.18.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.17.0...v0.18.0) (2023-06-30)


### Features

* highlight code chunks with headlines.nvim ([7eb3d01](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/7eb3d01d2113359820321be064ff0b0a1f378c43))
* **keys:** next/previous quickfix item ([c2f0ae0](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/c2f0ae0ebf0c63b6ab1fb26282ec1446e3f068ee))
* show more of the file path in windowline ([8ee2436](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/8ee2436d785ebeaba0c47b28755d881a15c86d98))

## [0.17.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.16.1...v0.17.0) (2023-06-28)


### Features

* keybindings for qmd document_symbols and type_definition ([c99a52c](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/c99a52c5950b953bccf16f85fe3efc479ec42ce6))

## [0.16.1](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.16.0...v0.16.1) (2023-06-27)


### Bug Fixes

* ts textobjects for plain python/r file code chunks ([24021b8](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/24021b8ca25b569592cf8dc8174a1cc00ab29e30))

## [0.16.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.15.0...v0.16.0) (2023-06-27)


### Features

* re-use [@class](https://github.com/class) textobject for nicer keybindings ([ab63d0d](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/ab63d0d6fff43903c65bf849a86a4999380a9215))

## [0.15.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.14.2...v0.15.0) (2023-06-24)


### Features

* warn if quarto resource path is not found ([c166dd2](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/c166dd2400bea07474f4d514e810ef0f9d83c944)), closes [#36](https://github.com/jmbuhr/quarto-nvim-kickstarter/issues/36)

## [0.14.2](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.14.1...v0.14.2) (2023-06-16)


### Bug Fixes

* delete broken symlink ([ebb15b8](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/ebb15b867119afb9f82df1b25442b76abb1c93cc))
* re-introduce quarto snippets ([6131c25](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/6131c2515509a00df1ccbdd530bcf3cfb2ac441d))

## [0.14.1](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.14.0...v0.14.1) (2023-06-07)


### Bug Fixes

* properly use vim slime ipython pause ([378b376](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/378b3761a74480d6fe05fd5bc83609d38670e49b))

## [0.14.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.13.0...v0.14.0) (2023-06-06)


### Features

* revert to only completing curly code chunks, but also add html ([fa372b6](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/fa372b68dded03e08735a0c7786c62110c6b91a1))

## [0.13.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.12.0...v0.13.0) (2023-06-05)


### Features

* enable completion for all chunks by default ([15023f2](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/15023f25b68930db951e15f478d0082ccfb2ce72))


### Bug Fixes

* remove (deprecated?) vim-slime option ([896c432](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/896c432ba0ad5676bf36c918f050f9193a87586b))
* respect .ignore file for finding files ([1bf09f2](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/1bf09f2e9d16c0c398d7bebb4b5965b15fe2e98c))

## [0.12.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.11.0...v0.12.0) (2023-06-03)


### Features

* add leap.nvim ([ef6fdde](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/ef6fdde2c011d7703bc7e345c4cf1d5f5cf9887d))


### Performance Improvements

* disable slower plugins by default ([7912423](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/7912423229bc360b1673b65e3743397a85200103))

## [0.11.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.10.0...v0.11.0) (2023-05-26)


### Features

* set up keymap for rename and references in qmd ([4ce8272](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/4ce8272e8bd9a6f6dccf96ebf5e09306e5855fda))


### Bug Fixes

* overwrite less markdown queries ([2594395](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/2594395789a7e4080ff8e4381aa6a53de8a79f3e))
* **r:** disable rich documentation (=&gt; pure markdown) ([9ed4a37](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/9ed4a3734ffbaeb17bd9948ff26dc2e2fd1558bf))
* resume showing gitignored files for find files ([102fdf3](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/102fdf3a1140729b382a3b7950604b8270b795e7))

## [0.10.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.9.1...v0.10.0) (2023-05-05)


### Features

* make pyright less hungry ([57b1d7b](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/57b1d7b702ece0a32af2143ced163da31134252f))

## [0.9.1](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.9.0...v0.9.1) (2023-05-01)


### Bug Fixes

* more robust vim-slime cell delimiter detection ([fa7f21c](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/fa7f21c5ccd4ac9b1deb034851a9f7bf7f9115b2))

## [0.9.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.8.1...v0.9.0) (2023-04-24)


### Features

* **opt:** ltex ([e17573d](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/e17573dfbc708918442b9b7b2015d501cff72029))

Thanks to @sondalex for the suggestion!

## [0.8.1](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.8.0...v0.8.1) (2023-04-22)


### Bug Fixes

* add coj keybinding to insert julia code chunk ([64fdafd](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/64fdafde61a438f654f186c38f9f431fb0f778a2))

## [0.8.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.7.0...v0.8.0) (2023-04-20)


### Features

* add &lt;leader&gt;qr keybindings to run code with vim-slime ([8959d0d](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/8959d0d4b468394ee901348d424a7e9d0d8d8e37))
* be less verbose ([9385099](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/93850996bbc58f74e29a276b3293c55fddc5d650))

## [0.7.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.6.0...v0.7.0) (2023-04-20)


### Features

* add keybindings to add different code chunks ([f2cd9d6](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/f2cd9d619b7a6efdcaa04e939382df78f1b73b5c))
* re-introduce codechunk textobjects to jump to ([cb06ff7](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/cb06ff7e16b31ebcf26271905dd0c1e477e4d3f9))


### Bug Fixes

* don't autopair backticks ([5b0ed1f](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/5b0ed1f214fc7f160aaedda85d2bacb03686d990))

## [0.6.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.5.0...v0.6.0) (2023-04-09)


### Features

* add kebinding to mark and switch between terminal targets ([d2492ef](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/d2492efa67779466fee95beb1c61b9ba899ce0d3))
* show optional features ([1487088](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/148708815987bf41e88f918a45eda64247db094b))
* use ipython cpaste when in python code chunk ([0756a76](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/0756a76273420edf78c9919ef9a58c180fd07f54))

## [0.5.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.4.0...v0.5.0) (2023-03-28)


### Features

* spellchecking exceptions for links ([55b62ae](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/55b62ae3a7cff76b30cb1b3243c69aa023a6cb8d))

## [0.4.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.3.1...v0.4.0) (2023-03-16)


### Features

* add bash language server ([96af1a1](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/96af1a13b97881d1b9334d5b3c7791c84c4b73b9))

## [0.3.1](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.3.0...v0.3.1) (2023-03-11)


### Bug Fixes

* also add marksman config example ([126937d](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/126937dbc0770512142a5171c6f711c357adb4f3))

## [0.3.0](https://github.com/jmbuhr/quarto-nvim-kickstarter/compare/v0.2.0...v0.3.0) (2023-03-11)


### Features

* add ci with autorelease ([1d53ef5](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/1d53ef5d86b6dc5b1e9b3482483e9efc00cdaf74))
* add DAP configuration ([eb48da3](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/eb48da3b897b4bf885fa9f2d51fdd173a54ac8f2))
* ignore python .venv folder in telescope search ([071183a](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/071183a0bcdc3f095e7325d6d305e7e7f481f6d1))
* update plugins ([5af0945](https://github.com/jmbuhr/quarto-nvim-kickstarter/commit/5af094561492d0a6ff9cfb6613d9c200148c282c))
