return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
  },
  init = function()
    -- Custom parser: YSH (Oils shell)
    local function register_ysh()
      local parsers = require("nvim-treesitter.parsers")
      parsers.ysh = {
        install_info = {
          url = "https://github.com/danyspin97/tree-sitter-ysh",
          files = { "src/parser.c", "src/scanner.c" },
          branch = "main",
        },
        filetype = "ysh",
      }
    end
    register_ysh()
    vim.api.nvim_create_autocmd("User", {
      pattern = "TSUpdate",
      callback = register_ysh,
    })
  end,
}
