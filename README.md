# nvim-tabletops

Tabletop Simulator editor package for NeoVim.

Currently only supports editing Lua scripts. At this point, it does not support:

- Running lua commands
- Editing UI XML
- `onExternalMessage` and `sendExternalMessage`

# Installation

This plugin can be installed using most plugin managers. You can directly use the master branch - there are no special 'stable' or 'release' branches.

e.g.
```vim
Plug 'ralismark/nvim-tabletops'
```

# Usage

- `:TtsStart` starts the editor server. This must be run before Vim can be used to edit scripts.
- `:TtsStop` stops the editor server. You do not need to call this before exiting Vim.
