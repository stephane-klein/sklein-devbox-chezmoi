local GIT_INIT =
  vim.fn.stdpath("data") .. "/lazy/neo-tree.nvim/lua/neo-tree/git/init.lua"
local FS_SCAN = vim.fn.stdpath("data")
  .. "/lazy/neo-tree.nvim/lua/neo-tree/sources/filesystem/lib/fs_scan.lua"

local patches = {
  {
    file = GIT_INIT,
    old = "  M.worktrees[existing_worktree] = nil",
    new = "  M.worktrees[worktree_root] = nil",
    description = "fix delete_worktree key (value → worktree_root)",
  },
  {
    file = GIT_INIT,
    old = [[  if status_progress then
    for k, v in pairs(status_progress) do
      worktree.status_progress[k] = worktree.status_progress[k] or v]],
    new = [[  if status_progress then
    worktree.status_progress = worktree.status_progress or {}
    for k, v in pairs(status_progress) do
      worktree.status_progress[k] = worktree.status_progress[k] or v]],
    description = "guard nil status_progress in change_worktree_git_status",
  },
  {
    file = FS_SCAN,
    old = "        { worktree_root, worktree.status_progress.ignored and worktree.status or nil }",
    new = "        { worktree_root, (worktree.status_progress or {}).ignored and worktree.status or nil }",
    description = "guard nil status_progress in mark_gitignored",
  },
}

local function apply()
  for _, p in ipairs(patches) do
    local lines = vim.fn.readfile(p.file)
    local content = table.concat(lines, "\n")
    if content:find(p.old, 1, true) then
      content = content:gsub(vim.pesc(p.old), p.new, 1)
      vim.fn.writefile(vim.fn.split(content, "\n"), p.file)
    else
      if not vim.g.neo_tree_patch_warned then
        vim.g.neo_tree_patch_warned = true
        vim.notify(
          "[patch-neo-tree] upstream code changed, patch target not found: "
            .. p.description,
          vim.log.levels.WARN,
          { title = "neo-tree.nvim patch" }
        )
      end
    end
  end
end

return apply
