local M = {}

local function setup_nvim_treesitter()
  vim.api.nvim_create_autocmd("User", {
    pattern = "TSUpdate",
    callback = function()
      local sources = require("zine.sources")

      ---@type zine.Source
      local ziggy_src = sources.ziggy
      require("nvim-treesitter.parsers").ziggy = {
        install_info = {
          url = ziggy_src.repo,
          revision = ziggy_src.rev,
          location = "tree-sitter-ziggy",
          generate = false,
          generate_from_json = false,
          queries = "tree-sitter-ziggy/queries",
        },
      }

      require("nvim-treesitter.parsers").ziggy_schema = {
        install_info = {
          url = ziggy_src.repo,
          revision = ziggy_src.rev,
          location = "tree-sitter-ziggy-schema",
          generate = false,
          generate_from_json = false,
          queries = "tree-sitter-ziggy-schema/queries",
        },
      }

      ---@type zine.Source
      local supermd_src = sources.supermd
      require("nvim-treesitter.parsers").supermd = {
        install_info = {
          url = supermd_src.repo,
          revision = supermd_src.rev,
          location = "tree-sitter/supermd",
          generate = false,
          generate_from_json = false,
          queries = "editors/neovim/queries/supermd",
        },
      }

      require("nvim-treesitter.parsers").supermd_inline = {
        install_info = {
          url = supermd_src.repo,
          revision = supermd_src.rev,
          location = "tree-sitter/supermd-inline",
          generate = false,
          generate_from_json = false,
          queries = "editors/neovim/queries/supermd_inline",
        },
      }

      ---@type zine.Source
      local superhtml_source = sources.superhtml
      require("nvim-treesitter.parsers").superhtml = {
        install_info = {
          url = superhtml_source.repo,
          revision = superhtml_source.rev,
          location = "tree-sitter-superhtml",
          generate = false,
          generate_from_json = false,
          queries = "tree-sitter-superhtml/queries",
        },
      }
    end,
  })
end

---@class zine.IntegrationOpts
---@field nvim_treesitter? boolean # Register TreeSitter parsers with nvim-treesitter/nvim-treesitter (default: true)

---@class zine.LspOpts
---@field enable? boolean

---@class zine.SetupOpts
---@field integrations? zine.IntegrationOpts
---@field lsp? zine.LspOpts

---@param opts? zine.SetupOpts
function M.setup(opts)
  opts = opts or {}

  vim.filetype.add {
    extension = {
      smd = "supermd",
      shtml = "superhtml",
      ziggy = "ziggy",
      ["ziggy-schema"] = "ziggy_schema",
    },
  }

  local integrations = opts.integrations or {}
  if integrations.nvim_treesitter ~= false then
    setup_nvim_treesitter()
  end

  local lsp_opts = opts.lsp or {}
  if lsp_opts.enable ~= false then
    vim.lsp.enable { "superhtml", "ziggy", "ziggy_schema" }
  end
end

return M
