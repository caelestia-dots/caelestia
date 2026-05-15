# Neovim cheatsheet

Day-to-day keybinds for the LazyVim config in [`../nvim/`](../nvim). Leader is **space**. When in doubt, press `<space>` alone — which-key will show the live menu. `<space>sk` fuzzy-finds every binding by description.

## Files & search

| keys | what |
|---|---|
| `<space><space>` | smart find file (project) |
| `<space>ff` | find files in cwd |
| `<space>fr` | recent files |
| `<space>fc` | find a config file |
| `<space>fn` | new file |
| `<space>/` | live grep (project-wide search) |
| `<space>sw` | grep word under cursor |
| `<space>sb` | search inside current buffer |
| `<space>sh` | search help tags |
| `<space>sk` | search keymaps (great for learning) |
| `<space>e` | toggle file explorer (neo-tree) |
| `<space>E` | toggle explorer at git root |

## Buffers (open files shown as tabs in the bufferline)

| keys | what |
|---|---|
| `<S-l>` / `<S-h>` | next / previous buffer |
| `]b` / `[b` | next / previous buffer (alt) |
| `<space>,` | switch buffer via picker |
| `<space>bd` | delete current buffer (keep window) |
| `<space>bo` | delete *other* buffers |
| `<space>bp` | pin buffer |
| `<space>bP` | delete all unpinned |

## Tabs (actual vim tabs — separate workspaces of buffers)

| keys | what |
|---|---|
| `<space><tab><tab>` | new tab |
| `<space><tab>]` / `[` | next / prev tab |
| `<space><tab>d` | close tab |
| `<space><tab>f` / `l` | first / last tab |

## Windows (splits)

| keys | what |
|---|---|
| `<C-h/j/k/l>` | move between splits |
| `<space>-` | horizontal split |
| `<space>\|` | vertical split |
| `<space>wd` | close current split |
| `<C-↑↓←→>` | resize current split |

## LSP (code intelligence)

| keys | what |
|---|---|
| `gd` | go to definition |
| `gr` | references |
| `gI` | implementation |
| `gy` | type definition |
| `K` | hover docs |
| `<space>cr` | rename symbol |
| `<space>ca` | code actions (autofix, quickfix) |
| `<space>cf` | format file |
| `]d` / `[d` | next / prev diagnostic |
| `]e` / `[e` | next / prev error |
| `<space>cd` | show line diagnostic |
| `<space>cs` | document symbols (outline) |

## Git (gitsigns + lazygit if installed)

| keys | what |
|---|---|
| `<space>gg` | open lazygit |
| `<space>gb` | blame current line |
| `<space>gB` | open file on GitHub/GitLab |
| `]h` / `[h` | next / prev hunk |
| `<space>ghs` | stage hunk |
| `<space>ghr` | reset hunk |
| `<space>ghp` | preview hunk |
| `<space>ghu` | undo last stage |

## Reload / restart

| keys | what |
|---|---|
| `:e` | reload current file from disk |
| `:checktime` | reload all buffers if changed externally |
| `<space>cR` | restart LSP for current buffer |
| `<space>l` | open Lazy (`R` inside = restart, `S` = sync) |
| `<space>qq` | quit all |
| `<space>qr` | restore session for current dir |

## UI toggles (`<space>u` namespace)

| keys | what |
|---|---|
| `<space>uw` | toggle word wrap |
| `<space>us` | toggle spell check |
| `<space>ud` | toggle diagnostics |
| `<space>un` | dismiss all notifications |
| `<space>uC` | change colorscheme (picker) |
| `<space>uz` | zen mode |

## Editing essentials (vim core, not LazyVim)

| keys | what |
|---|---|
| `gcc` / `gc{motion}` | toggle comment (line / range) |
| `>>` / `<<` | indent / dedent line |
| `>` / `<` in visual | indent / dedent selection |
| `J` | join line with next |
| `.` | repeat last change |
| `u` / `<C-r>` | undo / redo |
| `*` / `#` | search word under cursor fwd/back |
| `%` | jump to matching bracket |
| `ci"` `ca{` `cit` etc | change inside / around / tag (text objects) |
| `<C-o>` / `<C-i>` | jump back / forward (history) |

## Treesitter textobjects (from `lua/plugins/treesitter.lua`)

All work in visual or operator-pending mode — `d`, `c`, `y`, `v` all accept them.

| keys | selects |
|---|---|
| `vif` / `vaf` | inside / around function |
| `vic` / `vac` | inside / around class |
| `via` / `vaa` | inside / around argument |
| `vio` / `vao` | inside / around conditional (if/else) |
| `vil` / `val` | inside / around loop |
| `vik` / `vak` | inside / around block (curly braces) |
| `vi/` / `va/` | inside / around comment |
| `]f` / `[f` | jump to next/prev function |
| `]c` / `[c` | jump to next/prev class |
| `]a` / `[a` | next/prev argument |
| `<space>sa` / `sA` | swap argument with next/previous |

## What to memorize first

If you only learn 10 things, make it: `<space><space>` (file picker), `<space>/` (grep), `<S-l>`/`<S-h>` (buffer switching), `<space>bd` (close buffer), `gd` (go to definition), `K` (hover), `<space>ca` (code actions), `<space>cr` (rename), `gcc` (comment toggle), and `<space>` alone (which-key — your safety net).

After that, `<space>sk` (search keymaps) lets you fuzzy-find any binding by description.
