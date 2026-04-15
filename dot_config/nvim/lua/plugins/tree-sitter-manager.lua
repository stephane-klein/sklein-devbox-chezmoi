return {
  "romus204/tree-sitter-manager.nvim",
  dependencies = {},
  cmd = { "TSManager", "TSInstallSync" },
  opts = {
    ensure_installed = {}, -- No installation on startup
    auto_install = false,  -- Managed manually
    highlight = true,
  },
  config = function(_, opts)
    local ts_manager = require("tree-sitter-manager")
    ts_manager.setup(opts)

    -- Command for synchronous headless installation with dependency management
    vim.api.nvim_create_user_command("TSInstallSync", function()
      local repos = require("tree-sitter-manager.repos")
      local parser_dir = vim.fn.stdpath("data") .. "/site/parser"
      local query_dir = vim.fn.stdpath("data") .. "/site/queries"

      -- Complete list of parsers to install
      local parsers = {
        -- Core Neovim
        "lua", "vim", "vimdoc", "markdown", "markdown_inline", "query",
        -- Web (extras astro, tailwind, typescript)
        "html", "css", "javascript", "typescript", "tsx", "svelte", "astro",
        -- Go (extras go)
        "go", "gomod", "gowork", "gosum",
        -- Python (extras python)
        "python",
        -- Infrastructure (extras docker, terraform)
        "dockerfile", "terraform", "yaml",
        -- Data (extras json, toml)
        "json", "json5", "toml",
        -- SQL (extras sql)
        "sql",
        -- Git (extras git)
        "git_config", "git_rebase", "gitignore", "gitattributes", "gitcommit", "diff",
        -- Script / Utils
        "bash", "regex", "luap", "luadoc", "printf",
        -- System
        "c",
      }

      -- Check if a parser is installed
      local function is_installed(lang)
        local ext = ".so"
        local sys = vim.uv.os_uname().sysname
        if sys:match("Windows") then
          ext = ".dll"
        elseif sys:match("Darwin") then
          ext = ".dylib"
        end
        
        local parser_file = parser_dir .. "/" .. lang .. ext
        
        -- For query-only parsers (without .so)
        local repo_info = repos[lang]
        if repo_info and not repo_info.install_info then
          local query_file = query_dir .. "/" .. lang .. "/highlights.scm"
          return vim.fn.filereadable(query_file) == 1
        end
        
        return vim.fn.filereadable(parser_file) == 1
      end

      -- Get dependencies of a parser
      local function get_dependencies(lang)
        local repo_info = repos[lang]
        if repo_info and repo_info.requires then
          return repo_info.requires
        end
        return {}
      end

      -- Synchronous installation of a parser (with timeout)
      local function install_single_sync(lang)
        -- Check if parser exists in repos
        if not repos[lang] then
          print("ERROR: Parser '" .. lang .. "' not found in repositories")
          return false, nil
        end

        -- Start timer
        local start_time = vim.uv.hrtime()

        local done = false
        local success = false

        -- Use internal installation function
        local ok, err = pcall(function()
          ts_manager._install_single(lang, function(ok)
            success = ok
            done = true
          end)
        end)

        if not ok then
          print("ERROR: Failed to start installation of '" .. lang .. "': " .. tostring(err))
          return false, nil
        end

        -- Wait with timeout (2 minutes = 120000ms)
        local timeout = 120000
        local elapsed = 0
        local check_interval = 100

        while not done and elapsed < timeout do
          vim.wait(check_interval)
          elapsed = elapsed + check_interval
        end

        -- Calculate duration
        local end_time = vim.uv.hrtime()
        local duration_ms = (end_time - start_time) / 1000000
        local duration_str
        if duration_ms < 1000 then
          duration_str = string.format("%.0fms", duration_ms)
        else
          duration_str = string.format("%.1fs", duration_ms / 1000)
        end

        if not done then
          print("FAILED (timeout after 120s)")
          return false, duration_str
        end

        return success, duration_str
      end

      -- Installation with dependencies (recursive)
      local install_with_deps_sync
      install_with_deps_sync = function(lang, visited)
        visited = visited or {}

        -- Avoid infinite loops
        if visited[lang] then
          return true, nil
        end
        visited[lang] = true

        -- Check if already installed
        if is_installed(lang) then
          return true, nil
        end

        -- Get and install dependencies first
        local deps = get_dependencies(lang)

        for _, dep in ipairs(deps) do
          local dep_success, _ = install_with_deps_sync(dep, visited)
          if not dep_success then
            print("ERROR: Failed to install dependency '" .. dep .. "' for '" .. lang .. "'")
            return false, nil
          end
        end

        -- Install the parser
        io.write(lang .. ": installing... ")
        io.flush()

        local success, duration = install_single_sync(lang)

        if success then
          print("success (" .. duration .. ")")
          return true, duration
        else
          print("FAILED")
          return false, duration
        end
      end

      -- Main entry point
      print("=== Tree-sitter Parser Installation ===")
      print("Total parsers to check: " .. #parsers)
      print("")

      local installed = 0
      local skipped = 0
      local failed = 0
      local failed_parsers = {}

      -- Install sequentially
      for i, lang in ipairs(parsers) do
        print("[" .. i .. "/" .. #parsers .. "] Processing '" .. lang .. "'...")
        
        if is_installed(lang) then
          print(lang .. ": already installed")
          skipped = skipped + 1
        else
          local success, _ = install_with_deps_sync(lang)

          if success then
            installed = installed + 1
          else
            failed = failed + 1
            table.insert(failed_parsers, lang)
            -- Stop immediately on error (option A)
            print("")
            print("=== INSTALLATION ABORTED ===")
            print("Failed to install: " .. lang)
            print("This parser is required (strict mode).")
            print("")
            print("You can try:")
            print("1. Check your internet connection")
            print("2. Verify tree-sitter CLI is installed: tree-sitter --version")
            print("3. Check the parser repository exists: https://github.com/tree-sitter/tree-sitter-" .. lang)
            print("")
            vim.cmd("cquit 1") -- Exit with error code
            return
          end
        end
        
        print("")
      end

      -- Final summary
      print("=== Installation Complete ===")
      print("Installed: " .. installed)
      print("Skipped (already present): " .. skipped)
      print("Failed: " .. failed)
      print("Total: " .. #parsers)
      
      if failed > 0 then
        print("")
        print("Failed parsers:")
        for _, lang in ipairs(failed_parsers) do
          print("  - " .. lang)
        end
        vim.cmd("cquit 1")
      else
        print("")
        print("✓ All parsers installed successfully!")
      end
    end, { 
      desc = "Install all tree-sitter parsers synchronously with dependency resolution (headless)",
      nargs = 0,
    })
  end,
}
