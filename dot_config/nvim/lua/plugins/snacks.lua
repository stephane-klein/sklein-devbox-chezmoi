return {
  "folke/snacks.nvim",
  keys = {
    { "<leader><space>", false }, -- Because I use custom keymap based on <space><space> to split windows
    { "<leader>.",       false }, -- Because I use <leader>. to open floating neo-tree
  },
  ---@type snacks.Config
  opts = {
    animate = {
      enabled = false
    },
    scroll = {
      enabled = false
    },
    picker = {
      layouts = {
        vertical = {
          layout = {
            width = 0.9,
            height = 0.9
          }
        }
      },
      layout = {
        preset = "vertical",
      },
    },
    zen = {
      toggles = {
        dim = false,
      }
    },
    styles = {
      zen = {
        backdrop = { transparent = false, blend = 30 },
        keys = { q = "close" },
      }
    }
  },
}
