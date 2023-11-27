local utils = require("m.utils")
local config = require("m.config")
local timeago = require('m.timeago')
local actions = require("fzf-lua.actions")
local undo = require("m.undo")

local M = {}

M.test = function()
  require('fzf-lua').fzf_exec(function(fzf_cb)
    coroutine.wrap(function()
      -- See libuv
      -- http://docs.libuv.org/en/v1.x/
      -- :help lua-loop
      -- :h luvref :h lua-loop
      -- https://www.lua.org/pil/9.1.html
      local co = coroutine.running()
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        vim.schedule(function()
          local name = vim.api.nvim_buf_get_name(b)
          name = #name > 0 and name or "[No Name]"
          fzf_cb(b .. ":" .. name, function() coroutine.resume(co) end)
        end)
        coroutine.yield()
      end
      fzf_cb()
    end)()
  end, {
    prompt = 'Test❯ ',
    preview = "echo {}",
    actions = {

    }
  })
end

M.undo_tree = function()
  if false then -- TODO: coroutine
    local undolist = {}
    local i = 1
    local f = function(fzf_cb)
      undo.get_undolist({
        coroutine = true,
        callback = function(undo)
          fzf_cb(string.format("[%d] seq %d (%s)", i, undo.seq, undo.time))
        end
      })
      fzf_cb() -- EOF (close fzf named pipe
    end
  end

  local undolist = undo.get_undolist()
  local current_buf = vim.api.nvim_get_current_buf()
  local get_undo_with_string = function(str)
    local parts = vim.split(str, " ")
    return undolist[tonumber(parts[1])]
  end

  require('fzf-lua').fzf_exec(
    function(fzf_cb)
      for i, undo in ipairs(undolist) do
        fzf_cb(string.format("%d : %s%d (%s)", i, string.rep(" ", undo.alt_level), undo.seq, undo.time))
      end
      fzf_cb() -- EOF (close fzf named pipe)
    end,
    {
      prompt = 'UndoTree❯ ',
      preview = require 'fzf-lua'.shell.raw_preview_action_cmd(function(selected)
        local undo = get_undo_with_string(selected[1])
        local delta_opts = ""
        return string.format([[echo '%s' | delta "%s" %s]], undo.diff:gsub([[']], [['"'"']]), undo.time, delta_opts)
      end),
      actions = {
        ['ctrl-a'] = {
          -- See action reload
          -- https://github.com/ibhagwan/fzf-lua/wiki/Advanced#action-reload
          fn = function(selected, opts)
            local undo = get_undo_with_string(selected[1])
            vim.cmd(string.format("slient undo %s", undo.seq))
            vim.notify(string.format("Undo %s", undo.seq))
          end,
          reload = true,
        },
        ['ctrl-o'] = function(selected, opts)
          local undo = get_undo_with_string(selected[1])
          local before_and_after = undo.get_undo_before_and_after(undo.seq)
          utils.open_diff_in_new_tab(before_and_after[1], before_and_after[2], {
            filetype = vim.api.nvim_buf_get_option(current_buf, "filetype")
          })
        end
      },
      fzf_opts = {
        ["--delimiter"] = "'[\\]:]'", -- In awk, a character set matches either ] or :
        ["--with-nth"]  = "2..",      -- from field 2 onwards
        ["--header"]    = "'Seq Time'",
        ["--no-multi"]  = "",
      }
    })
end

M.notifications = function()
  if not config.notify_backend == "nvim-notify" then
    vim.notify("Feature only supported with nvim-notify backend", vim.log.levels.WARN)
    return
  end

  local notifications = require('notify').history()
  local get_noti_with_string = function(str)
    local parts = vim.split(str, " ")
    return notifications[tonumber(parts[1])]
  end

  require('fzf-lua').fzf_exec(function(fzf_cb)
    for i = #notifications, 1, -1 do
      local noti = notifications[i]
      local brief = vim.trim(noti.message[1])
      local brief_max_length = 30
      brief = #brief > brief_max_length and brief:sub(1, brief_max_length - 3) .. "..." or brief
      fzf_cb(string.format("%d : (%s) %s", i, timeago(noti.time), brief))
    end
    fzf_cb()
  end, {
    prompt = 'Notifications❯ ',

    preview = require 'fzf-lua'.shell.raw_preview_action_cmd(function(selected)
      local noti = get_noti_with_string(selected[1])
      return string.format([[cat <<FZFLUAEOM
%s
FZFLUAEOM]], table.concat(noti.message, "\n"))
    end),
    actions = {
    },
    fzf_opts = {
      ["--delimiter"] = "'[\\]:]'",
      ["--with-nth"]  = "2..",
      ["--header"]    = "'Time Brief'",
      ["--no-multi"]  = "",
    }
  })
end

return M
