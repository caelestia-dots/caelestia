return {
  -- Extend LazyVim's parser list with langs you actually use
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "fish", "go", "rust", "cpp", "qmljs",
      })
    end,
  },

  -- Treesitter-powered textobjects (main branch — new API).
  -- Gives you:
  --   v[a|i]f → function · v[a|i]c → class · v[a|i]a → argument
  --   v[a|i]o → conditional · v[a|i]l → loop · v[a|i]k → block · v[a|i]/ → comment
  --   ]f / [f → jump between functions · ]c / [c → between classes
  --   ]a / [a → between arguments · ]o / [o → between conditionals · ]l / [l → between loops
  --   <leader>sa / sA → swap argument with next/previous
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true, include_surrounding_whitespace = false },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")

      local pairs_to_query = {
        f = "@function",
        c = "@class",
        a = "@parameter",
        o = "@conditional",
        l = "@loop",
        k = "@block",
        ["/"] = "@comment",
      }

      for key, capture in pairs(pairs_to_query) do
        vim.keymap.set({ "x", "o" }, "a" .. key, function()
          select.select_textobject(capture .. ".outer", "textobjects")
        end, { desc = "around " .. capture:sub(2) })
        vim.keymap.set({ "x", "o" }, "i" .. key, function()
          select.select_textobject(capture .. ".inner", "textobjects")
        end, { desc = "inside " .. capture:sub(2) })
      end

      local move_pairs = { f = "@function.outer", c = "@class.outer",
        a = "@parameter.inner", o = "@conditional.outer", l = "@loop.outer" }
      for key, capture in pairs(move_pairs) do
        vim.keymap.set({ "n", "x", "o" }, "]" .. key, function()
          move.goto_next_start(capture, "textobjects")
        end, { desc = "next " .. capture })
        vim.keymap.set({ "n", "x", "o" }, "[" .. key, function()
          move.goto_previous_start(capture, "textobjects")
        end, { desc = "prev " .. capture })
      end

      vim.keymap.set("n", "<leader>sa", function() swap.swap_next("@parameter.inner") end,
        { desc = "Swap arg with next" })
      vim.keymap.set("n", "<leader>sA", function() swap.swap_previous("@parameter.inner") end,
        { desc = "Swap arg with previous" })
    end,
  },
}
