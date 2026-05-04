return {
  {
    "evanphx/jjsigns.nvim",
    config = function()
      require('jjsigns').setup()
    end
  },
  {
    "nicolasgb/jj.nvim",
    version = "*",
    dependencies = {
      "esmuellert/codediff.nvim",
    },
    config = function()
      require("jj").setup({
        diff = {
            backend = "codediff"
        }
      })
    end,
  }
}
