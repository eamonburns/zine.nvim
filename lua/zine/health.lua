local M = {}

local executable_versions = {
  zine = vim.version.parse("0.13.0"),
  superhtml = vim.version.parse("0.7.0"),
  ziggy = vim.version.parse("0.2.0"),
}

local function check_exe(exe_name, expected_version)
  if vim.fn.executable(exe_name) == 0 then
    vim.health.error(("`%s`: not executable"):format(exe_name))
    return
  end

  local version_result = vim.system({ exe_name, "version" }, { text = true }):wait()

  if version_result.code ~= 0 then
    vim.health.error(("`%s`: unable to get version: %s"):format(exe_name, version_result.stderr))
    return
  end
  local version_string = vim.trim(version_result.stderr)

  local actual_version = vim.version.parse(version_string)
  if not actual_version then
    vim.health.error(("`%s`: invalid version number from `%s version`: '%s'"):format(exe_name, exe_name, version_string))
    return
  end

  if actual_version < expected_version then
    vim.health.error(("`%s`: expected version %s, but got %s"):format(exe_name, expected_version, actual_version))
  elseif actual_version > expected_version then
    vim.health.info(("`%s`: installed version (%s) is greater than expected (%s)"):format(exe_name, actual_version, expected_version))
  else
    vim.health.ok(("`%s`: version %s is installed and executable"):format(exe_name, actual_version))
  end
end

M.check = function()
  vim.health.start("zine.nvim report")

  for exe_name, expected_version in pairs(executable_versions) do
    check_exe(exe_name, expected_version)
  end
end

return M
