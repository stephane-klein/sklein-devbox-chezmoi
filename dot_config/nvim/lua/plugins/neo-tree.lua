return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = true,
    cmd = "Neotree",
    keys = {
      {
        "<leader>.",
        function()
          require("neo-tree.command").execute({
            position = "current",
            toggle = true,
            dir = vim.fn.expand('%:p:h')
          })
        end,
        desc = "Explorer float NeoTree"
      },
      {
        "<leader>fE",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
      {
        "<leader>e",
        function()
          require("neo-tree.command").execute({ action = "focus" })
        end,
        desc = "Focus Neo-tree",
      },
      {
        "<leader>fec",
        function()
          require("neo-tree.command").execute({ action = "close" })
        end,
        desc = "Close NeoTree",
      }
    },
    deactivate = function()
      vim.cmd([[Neotree close]])
    end,
    init = function()
      -- FIX: use `autocmd` for lazy-loading neo-tree instead of directly requiring it,
      -- because `cwd` is not set up properly.
      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
        desc = "Start Neo-tree with directory",
        once = true,
        callback = function()
          if package.loaded["neo-tree"] then
            return
          else
            local stats = vim.uv.fs_stat(vim.fn.argv(0) --[[@as string]])
            if stats and stats.type == "directory" then
              require("neo-tree")
            end
          end
        end,
      })
    end,
    opts = {
      sources = { "filesystem" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
      hijack_netrw_behavior = "open_default",
      filesystem = {
        auto_expand_width = true,
        bind_to_cwd = true,
        follow_current_file = {
          enabled = true,
          leave_dirs_open = true
        },
        use_libuv_file_watcher = true,
        window = {
          mappings = {
            ["."] = {
              function(state)
                local node = state.tree:get_node()
                local path = node:get_id()
                -- Get the directory path
                if node.type ~= "directory" then
                  path = vim.fn.fnamemodify(path, ":h")
                end
                vim.cmd("cd " .. vim.fn.fnameescape(path))
              end,
              desc = "Set root and change global pwd",
            },
            ["e"] = {
              "toggle_auto_expand_width",
              desc = "Toggle auto expand width",
            },
            ["<leader>/"] = {
              function(state)
                local node = state.tree:get_node()
                local path = node:get_id()
                -- Get the directory path
                if node.type ~= "directory" then
                  path = vim.fn.fnamemodify(path, ":h")
                end
                require("snacks").picker.grep({ cwd = path })
              end,
              desc = "Grep in directory",
            },
          },
        },
      },
      window = {
        mappings = {
          ["h"] = "close_node",
          ["<space>"] = "none",
          ["Y"] = {
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.fn.setreg("+", path, "c")
            end,
            desc = "Copy Path to Clipboard",
          },
          ["P"] = { "toggle_preview", config = { use_float = true } },
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        git_status = {
          symbols = {
            unstaged = "󰄱",
            staged = "󰱒",
          },
        },
      },
    },
    config = function(_, opts)
      local function on_move(data)
        Snacks.rename.on_rename_file(data.source, data.destination)
      end

      local events = require("neo-tree.events")
      opts.event_handlers = opts.event_handlers or {}
      vim.list_extend(opts.event_handlers, {
        { event = events.FILE_MOVED,   handler = on_move },
        { event = events.FILE_RENAMED, handler = on_move },
      })
      require("neo-tree").setup(opts)
      vim.api.nvim_create_autocmd("TermClose", {
        pattern = "*lazygit",
        callback = function()
          if package.loaded["neo-tree.sources.git_status"] then
            require("neo-tree.sources.git_status").refresh()
          end
        end,
      })
    end,
  },
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neo-tree/neo-tree.nvim", -- makes sure that this loads after Neo-tree.
    },
    config = function()
      require("lsp-file-operations").setup()
    end,
  },
  {
    "s1n7ax/nvim-window-picker",
    version = "2.*",
    config = function()
      require("window-picker").setup({
        hint = "floating-big-letter",
        filter_rules = {
          include_current_win = false,
          autoselect_one = true,
          -- filter using buffer options
          bo = {
            -- if the file type is one of following, the window will be ignored
            filetype = { "neo-tree", "neo-tree-popup", "notify" },
            -- if the buffer type is one of following, the window will be ignored
            buftype = { "terminal", "quickfix" },
          },
        },
      })
    end,
  },
  {
    "stephane-klein/neo-tree-session.nvim",
    dependencies = {
      "nvim-neo-tree/neo-tree.nvim",
      "folke/persistence.nvim"
    },
    opts = {
    }
  }
}
