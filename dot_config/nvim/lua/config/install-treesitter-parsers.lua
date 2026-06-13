local parsers = {
  -- Core Neovim
  "lua", "vim", "vimdoc", "markdown", "markdown_inline", "query",
  -- Web
  "html", "css", "javascript", "typescript", "tsx", "svelte", "astro",
  -- Go
  "go", "gomod", "gowork", "gosum",
  -- Python
  "python",
  -- Infrastructure
  "dockerfile", "terraform", "yaml",
  -- Data
  "json", "json5", "toml",
  -- SQL
  "sql",
  -- Script / Utils
  "bash", "regex", "luap", "luadoc", "printf",
  -- Oils (YSH)
  "ysh",
  -- System
  "c",
  -- Git
  "git_config", "git_rebase", "gitignore", "gitattributes", "gitcommit", "diff",
}

-- Register custom parsers
local parser_configs = require("nvim-treesitter.parsers")
parser_configs.ysh = {
  install_info = {
    url = "https://github.com/danyspin97/tree-sitter-ysh",
    files = { "src/parser.c", "src/scanner.c" },
    branch = "main",
  },
  filetype = "ysh",
}

print("Installing Treesitter parsers: " .. table.concat(parsers, ", "))
local ok, err = pcall(function()
  require('nvim-treesitter').install(parsers):wait(300000)
end)
if not ok then
  print("ERROR: " .. tostring(err))
  vim.cmd("cquit 1")
end
print("Done.")
