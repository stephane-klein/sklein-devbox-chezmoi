return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local ok, configs = pcall(require, "nvim-treesitter.configs")
    if ok then
      configs.setup({
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      })
    end
  end,
}
