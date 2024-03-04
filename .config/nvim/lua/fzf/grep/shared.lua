local core = require("fzf.core")
local utils = require("utils")
local fzf_misc = require("fzf.misc")
local helpers = require("fzf.helpers")

local Layout = require("nui.layout")
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

local M = {}

-- TODO: cleanup

---@return NuiLayout, { main: NuiPopup, nvim_preview: NuiPopup, replace: NuiPopup }, fun(): string get_replacement, fun(content: string[]): nil set_preview_content
function M.create_layout()
  local main_popup = helpers.generate_main_popup()

  local nvim_preview_popup = Popup({
    enter = false,
    focusable = true,
    border = {
      style = "rounded",
      text = {
        top = " Preview ",
      },
    },
    buf_options = {
      modifiable = true,
    },
    win_options = {
      winblend = 0,
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      number = true,
      cursorline = true,
    },
  })

  local replace_popup = Popup({
    enter = false,
    focusable = true,
    border = {
      style = "rounded",
      text = {
        top = " Replacement ",
      },
    },
    buf_options = {
      modifiable = true,
    },
    win_options = {
      winblend = 0,
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      number = true,
    },
  })

  local popups = {
    main = main_popup,
    nvim_preview = nvim_preview_popup,
    replace = replace_popup,
  }

  local layout = Layout(
    {
      position = "50%",
      relative = "editor",
      size = {
        width = "90%",
        height = "90%",
      },
    },
    Layout.Box({
      Layout.Box(main_popup, { size = "50%" }),
      Layout.Box({
        Layout.Box(replace_popup, { size = "20%" }),
        Layout.Box(nvim_preview_popup, { grow = 1 }),
      }, { size = "50%", dir = "col" }),
    }, { dir = "row" })
  )

  local function get_replacement()
    return table.concat(
      -- Retrieve all lines (possibly modified)
      vim.fn.getbufline(popups.replace.bufnr, 1, "$"), ---@diagnostic disable-line: param-type-mismatch
      "\r"
    )
  end

  local function set_preview_content(content)
    vim.api.nvim_buf_set_lines(popups.nvim_preview.bufnr, 0, -1, false, content)

    local current_win = vim.api.nvim_get_current_win()

    -- Switch to preview window and back in order to refresh scrollbar
    -- TODO: Remove this once scrollbar plugin support remote refresh
    vim.api.nvim_set_current_win(popups.nvim_preview.winid)
    vim.api.nvim_set_current_win(current_win)
  end

  return layout, popups, get_replacement, set_preview_content
end

return M
