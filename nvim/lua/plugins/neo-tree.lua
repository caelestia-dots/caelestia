return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      -- When you run `nvim .`, open the directory in the current window
      -- instead of as a permanent sidebar. The sidebar still opens on <leader>e.
      filesystem = {
        hijack_netrw_behavior = "open_current",
      },
    },
  },
}
