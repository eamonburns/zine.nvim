-- Run the script: nvim -l scripts/update.lua

if not vim or vim.version() < vim.version.parse("0.12") then
  print("error: must be run with Neovim >= 0.12")
  if vim then
    -- Run using nvim, but invalid version
    print(("  (Current version: %s)"):format(vim.version()))
  else
    -- Not run using nvim
    print("  (Use `nvim -l scripts/update.lua`)")
  end
  os.exit(1)
end

local script_path = debug.getinfo(1, "S").source:sub(2)
local repo_path = vim.fs.normalize(vim.fs.joinpath(vim.fs.dirname(script_path), ".."))
print("Repository path:", repo_path)

local temp_dir = vim.fs.joinpath(repo_path, ".tmp")
if vim.fn.isdirectory(temp_dir) == 0 then
  print("Creating temporary directory:", temp_dir)
  if vim.fn.mkdir(temp_dir, "p") == 0 then
    print("error: unable to create temporary directory:", temp_dir)
    os.exit(1)
  end
end

local sources_path = vim.fs.joinpath(repo_path, "lua/zine/sources.lua")

---@type { [string]: zine.Source }
local sources = assert(loadfile(sources_path))()

print("=== cloning sources ===")
---@type { [string]: vim.SystemObj }
local clone_tasks = {}
for name, source in pairs(sources) do
  local dest_dir = vim.fs.joinpath(temp_dir, name)
  if vim.fn.isdirectory(dest_dir) == 1 then
    vim.fs.rm(dest_dir, { recursive = true })
  end

  -- stylua: ignore start
  local cmd = {
    "git", "clone",
    "--revision", source.rev,
    "--depth=1",
    source.repo, dest_dir,
  }
  -- stylua: ignore end

  print("cloning", source.repo)
  clone_tasks[name] = vim.system(cmd)
end

-- Wait for all tasks to complete
local should_exit = false
for name, task in pairs(clone_tasks) do
  local result = task:wait()
  local source = sources[name]
  if result.code ~= 0 then
    print("error: unable to clone", source.repo)
    print(result.stderr)
    should_exit = true
  end

  -- Only do the next steps if there haven't been previous errors
  if not should_exit then
    print(("cloned %s"):format(name))
  end
end

if should_exit then
  print("error: there were errors cloning a repository. exiting")
  os.exit(1)
end

local uv = vim.uv

---@param src_path string
---@param dest_path string
local function recursive_copy(src_path, dest_path)
  local src_stat = assert(uv.fs_stat(src_path))
  if src_stat.type == "link" then
    error("src_path is a link")
  elseif src_stat.type ~= "directory" then
    assert(uv.fs_copyfile(src_path, dest_path))
    return
  end
  assert(uv.fs_mkdir(dest_path, src_stat.mode))

  local fd = assert(uv.fs_opendir(src_path, nil, 10000))

  local entries = assert(fd:readdir())
  for _, entry in ipairs(entries) do
    recursive_copy(vim.fs.joinpath(src_path, entry.name), vim.fs.joinpath(dest_path, entry.name))
  end
end

-- Copy queries
local query_paths = {
  -- NOTE: `from` is relative to `.tmp`, `to` is relative to the repository
  { from = "ziggy/tree-sitter-ziggy/queries", to = "queries/ziggy" },
  { from = "ziggy/tree-sitter-ziggy-schema/queries", to = "queries/ziggy_schema" },
  { from = "supermd/editors/neovim/queries/supermd", to = "queries/supermd" },
  { from = "supermd/editors/neovim/queries/supermd_inline", to = "queries/supermd_inline" },
  { from = "superhtml/tree-sitter-superhtml/queries", to = "queries/superhtml" },
}
for _, path in ipairs(query_paths) do
  local from = vim.fs.normalize(vim.fs.joinpath(temp_dir, path.from))
  local to = vim.fs.normalize(vim.fs.joinpath(repo_path, path.to))
  print("Copying query:", from, "->", to)
  vim.fn.mkdir(vim.fs.dirname(to), "p")
  recursive_copy(from, to)
end
