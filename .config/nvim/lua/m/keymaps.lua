local M = {}

local config = require("m.config")
local utils = require("m.utils")
local safe_require = function(module)
  return utils.safe_require(module, {
    notify = false,
    log_level = vim.log.levels.ERROR,
  })
end

local vim_keymap = vim.api.nvim_set_keymap
local opts = { silent = false, noremap = true }
local opts_can_remap = { silent = false, noremap = false }
local opts_expr = { silent = false, expr = true, noremap = true }

local lua_keymap = function(mode, lhs, rhs, opts)
  if rhs ~= nil then vim.keymap.set(mode, lhs, rhs, opts) end
end

M.setup = function()
  -- Pageup/down
  vim_keymap("n", "<PageUp>", "<C-u><C-u>", opts)
  vim_keymap("n", "<PageDown>", "<C-d><C-d>", opts)
  vim_keymap("v", "<PageUp>", "<C-u><C-u>", opts)
  vim_keymap("v", "<PageDown>", "<C-d><C-d>", opts)
  vim_keymap("i", "<PageUp>", "<C-o><C-u><C-o><C-u>", opts) -- Execute <C-u> twice in normal mode
  vim_keymap("i", "<PageDown>", "<C-o><C-d><C-o><C-d>", opts)

  -- Find and replace (local)
  vim_keymap("n", "rw", "*N:%s///g<left><left>", opts) -- Select next occurrence of word under cursor then go back to current instance
  vim_keymap("n", "rr", ":%s//g<left><left>", opts)
  vim_keymap("v", "rr", ":s//g<left><left>", opts)
  vim_keymap("v", "r.", ":&gc<CR>", opts) -- Reset flags & add flags
  vim_keymap("v", "ry", [["ry]], opts) -- Yank it into register "r" for later use with "rp"
  local function rp_rhs(whole_file) -- Use register "r" as the replacement rather than the subject
    return function() return ((whole_file and ":%s" or ":s") .. [[//<C-r>r/gc<left><left><left>]] .. string.rep("<left>", utils.get_register_length("r")) .. "<left>") end
  end
  lua_keymap("n", "rp", rp_rhs(true), opts_expr)
  lua_keymap("v", "rp", rp_rhs(false), opts_expr)
  vim_keymap("v", "ra", [["ry:%s/<C-r>r//gc<left><left><left>]], opts) -- Paste selection into register "y" and paste it into command line with <C-r>
  vim_keymap("v", "ri", [["rygv*N:s/<C-r>r//g<left><left>]], opts) -- "ra" but backward direction only. Because ":s///c" doesn't support backward direction, rely on user pressing "N" and "r."
  vim_keymap("v", "rk", [["ry:.,$s/<C-r>r//gc<left><left><left>]], opts) -- "ra" but forward direction only

  -- Find and replace (global)

  -- Move by word
  vim_keymap("n", "<C-Left>", "b", opts)
  vim_keymap("n", "<C-S-Left>", "B", opts)
  vim_keymap("n", "<C-Right>", "w", opts)
  vim_keymap("n", "<C-S-Right>", "W", opts)

  -- Delete word
  vim_keymap("i", "<C-BS>", "<C-W>", opts)
  vim_keymap("i", "<C-BS>", "<C-W>", opts)

  -- Move/swap line/selection up/down
  local auto_indent = false
  vim_keymap("n", "<C-up>", "<cmd>m .-2<CR>" .. (auto_indent and "==" or ""), opts)
  vim_keymap("n", "<C-down>", "<cmd>m .+1<CR>" .. (auto_indent and "==" or ""), opts)
  vim_keymap("v", "<C-up>", ":m .-2<CR>gv" .. (auto_indent and "=gv" or ""), opts)
  vim_keymap("v", "<C-down>", ":m '>+1<CR>gv" .. (auto_indent and "=gv" or ""), opts)

  -- Delete line
  vim_keymap("n", "<M-y>", "dd", opts_can_remap)
  vim_keymap("i", "<M-y>", "<C-o><M-y>", opts_can_remap)
  vim_keymap("v", "<M-y>", ":d<CR>", opts)

  -- Duplicate line/selection
  vim_keymap("n", "<M-g>", "<cmd>t .<CR>", opts)
  vim_keymap("i", "<M-g>", "<C-o><M-g>", opts_can_remap)
  vim_keymap("v", "<M-g>", ":t '><CR>", opts)

  -- Matching pair
  vim_keymap("n", "m", "%", opts)
  vim_keymap("v", "m", "%", opts)

  -- Macro
  local macro_keymaps = false
  if macro_keymaps then
    vim_keymap("n", ",", "@", opts) -- replay macro x
    vim_keymap("n", "<", "Q", opts) -- replay last macro
  end

  -- Clear search highlights
  vim_keymap("n", "<Space>/", "<cmd>noh<CR>", opts)

  -- Redo
  vim_keymap("n", "U", "<C-R>", opts)

  -- New line
  vim_keymap("n", "o", "o<Esc>", opts)
  vim_keymap("n", "O", "O<Esc>", opts)

  -- Fold
  vim_keymap("n", "zl", "zo", opts)
  vim_keymap("n", "zj", "zc", opts)
  vim_keymap("n", "zp", "za", opts)

  -- Insert/append swap
  vim_keymap("n", "i", "a", opts)
  vim_keymap("n", "a", "i", opts)
  vim_keymap("n", "I", "A", opts)
  vim_keymap("n", "A", "I", opts)
  vim_keymap("v", "I", "A", opts)
  vim_keymap("v", "A", "I", opts)

  -- Home
  vim_keymap("n", "<Home>", "^", opts)
  vim_keymap("v", "<Home>", "^", opts)
  vim_keymap("i", "<Home>", "<C-o>^", opts) -- Execute ^ in normal mode

  -- Indent
  vim_keymap("n", "<Tab>", ">>", opts)
  vim_keymap("n", "<S-Tab>", "<<", opts)
  vim_keymap("v", "<Tab>", ">gv", opts) -- keep selection after
  vim_keymap("v", "<S-Tab>", "<gv", opts)

  -- Yank
  vim_keymap("v", "y", "ygv<Esc>", opts) -- Stay at cursor after yank

  -- Paste
  vim_keymap("v", "p", '"pdP', opts) -- Don't keep the overwritten text in register "+". Instead, keep it in "p"

  -- Fold
  vim_keymap("n", "z.", "zo", opts)
  vim_keymap("n", "z,", "zc", opts)
  vim_keymap("n", "z>", "zr", opts)
  vim_keymap("n", "z<", "zm", opts)

  -- Screen movement
  vim_keymap("n", "<S-Up>", "5<C-Y>", opts)
  vim_keymap("v", "<S-Up>", "5<C-Y>", opts)
  vim_keymap("i", "<S-Up>", "<C-o>5<C-Y>", opts)
  vim_keymap("n", "<S-Down>", "5<C-E>", opts)
  vim_keymap("v", "<S-Down>", "5<C-E>", opts)
  vim_keymap("i", "<S-Down>", "<C-o>5<C-E>", opts)
  vim_keymap("n", "<S-Left>", "2<ScrollWheelLeft>", opts)
  vim_keymap("v", "<S-Left>", "2<ScrollWheelLeft>", opts)
  vim_keymap("i", "<S-Left>", "<C-o>2<ScrollWheelLeft>", opts)
  vim_keymap("n", "<S-Right>", "2<ScrollWheelRight>", opts)
  vim_keymap("v", "<S-Right>", "2<ScrollWheelRight>", opts)
  vim_keymap("i", "<S-Right>", "<C-o>2<ScrollWheelRight>", opts)

  -- Window (pane)
  vim_keymap("n", "wi", "<cmd>wincmd k<CR>", opts)
  vim_keymap("n", "wk", "<cmd>wincmd j<CR>", opts)
  vim_keymap("n", "wj", "<cmd>wincmd h<CR>", opts)
  vim_keymap("n", "wl", "<cmd>wincmd l<CR>", opts)
  vim_keymap("n", "<C-e>", "<cmd>wincmd k<CR>", opts)
  vim_keymap("n", "<C-d>", "<cmd>wincmd j<CR>", opts)
  vim_keymap("n", "<C-s>", "<cmd>wincmd h<CR>", opts)
  vim_keymap("n", "<C-f>", "<cmd>wincmd l<CR>", opts)

  vim_keymap("n", "<C-S-->", "10<C-w>-", opts) -- Decrease height
  vim_keymap("n", "<C-S-=>", "10<C-w>+", opts) -- Increase height
  vim_keymap("n", "<C-S-.>", "20<C-w>>", opts) -- Increase width
  vim_keymap("n", "<C-S-,>", "20<C-w><", opts) -- Decrease width

  vim_keymap("n", "ww", "<cmd>clo<CR>", opts)

  vim_keymap("n", "wd", "<cmd>split<CR>", opts)
  vim_keymap("n", "wf", "<cmd>vsplit<CR>", opts)
  vim_keymap("n", "we", "<cmd>split<CR>", opts)
  vim_keymap("n", "ws", "<cmd>vsplit<CR>", opts)

  vim_keymap("n", "wt", "<cmd>wincmd T<CR>", opts) -- Move to new tab

  local maximize_plugin = config.maximize_plugin

  if maximize_plugin then
    lua_keymap("n", "wz", safe_require("maximize").toggle, {})
  else
    vim_keymap("n", "wz", "<C-W>_<C-W>|", opts) -- Maximise both horizontally and vertically
    vim_keymap("n", "wx", "<C-W>=", opts)
  end

  -- Tab
  vim_keymap("n", "tj", "<cmd>tabp<CR>", opts)
  vim_keymap("n", "tl", "<cmd>tabn<CR>", opts)
  vim_keymap("n", "tt", "<cmd>tabnew<CR>", opts)
  local close_tab_and_left = function()
    local is_last_tab = vim.fn.tabpagenr("$") == vim.api.nvim_tabpage_get_number(0)
    vim.cmd([[tabclose]])
    if not is_last_tab and vim.fn.tabpagenr() > 1 then vim.cmd([[tabprevious]]) end
  end
  lua_keymap("n", "tw", close_tab_and_left, {})
  vim_keymap("n", "<C-j>", "<cmd>tabp<CR>", opts)
  vim_keymap("n", "<C-l>", "<cmd>tabn<CR>", opts)

  vim_keymap("n", "tu", "<cmd>tabm -1<CR>", opts)
  vim_keymap("n", "to", "<cmd>tabm +1<CR>", opts)
  vim_keymap("n", "<C-S-j>", "<cmd>tabm -1<CR>", opts)
  vim_keymap("n", "<C-S-l>", "<cmd>tabm +1<CR>", opts)

  -- Delete & cut
  vim_keymap("n", "d", '"dd', opts) -- Put in d register, in case if needed
  vim_keymap("v", "d", '"dd', opts)
  vim_keymap("n", "x", "d", opts)
  vim_keymap("v", "x", "d", opts)
  vim_keymap("n", "xx", "dd", opts)
  vim_keymap("n", "X", "D", opts)

  -- Change (add to register 'd')
  vim_keymap("n", "c", '"dc', opts)
  vim_keymap("n", "C", '"dC', opts)
  vim_keymap("v", "c", '"dc', opts)
  vim_keymap("v", "C", '"dC', opts)

  -- Jump (jumplist)
  vim_keymap("n", "<C-u>", "<C-o>", opts)
  vim_keymap("n", "<C-o>", "<C-i>", opts)

  -- Telescope / FzfLua
  local fuzzy_finder_keymaps = {
    [{ mode = "n", lhs = "<f1>" }] = {
      telescope = safe_require("telescope.builtin").builtin,
      fzflua = safe_require("fzf-lua").builtin,
    },
    [{ mode = "n", lhs = "<f3><f3>" }] = {
      telescope = safe_require("telescope.builtin").find_files,
      fzflua = safe_require("fzf-lua").git_files,
    },
    [{ mode = "n", lhs = "<f3><f5>" }] = {
      telescope = nil,
      fzflua = safe_require("fzf-lua").files,
    },
    [{ mode = "n", lhs = "<f3><f2>" }] = {
      telescope = safe_require("telescope.builtin").buffers,
      fzflua = safe_require("fzf-lua").buffers,
    },
    [{ mode = "n", lhs = "<f3><f1>" }] = {
      telescope = nil,
      fzflua = safe_require("fzf-lua").tabs,
    },
    [{ mode = "n", lhs = "<f5><f5>" }] = {
      telescope = safe_require("telescope.builtin").live_grep,
      fzflua = safe_require("fzf-lua").live_grep,
    },
    [{ mode = "n", lhs = "<f11><f5>" }] = {
      telescope = safe_require("telescope.builtin").git_commits,
      fzflua = safe_require("fzf-lua").git_commits,
    },
    [{ mode = "n", lhs = "<f11><f4>" }] = {
      telescope = safe_require("telescope.builtin").git_bcommits,
      fzflua = safe_require("fzf-lua").git_bcommits,
    },
    [{ mode = "n", lhs = "<f11><f3>" }] = {
      telescope = safe_require("telescope.builtin").git_status,
      fzflua = safe_require("fzf-lua").git_status,
    },
    [{ mode = "n", lhs = "li" }] = {
      telescope = safe_require("telescope.builtin").lsp_definitions,
      fzflua = safe_require("fzf-lua").lsp_definitions,
    },
    [{ mode = "n", lhs = "lr" }] = {
      telescope = safe_require("telescope.builtin").lsp_references,
      fzflua = safe_require("fzf-lua").lsp_references,
    },
    [{ mode = "n", lhs = "<f4><f4>" }] = {
      telescope = safe_require("telescope.builtin").lsp_document_symbols,
      fzflua = safe_require("fzf-lua").lsp_document_symbols,
    },
    [{ mode = "n", lhs = "<f4><f5>" }] = {
      telescope = safe_require("telescope.builtin").lsp_workspace_symbols,
      fzflua = safe_require("fzf-lua").lsp_workspace_symbols,
    },
    [{ mode = "n", lhs = "ld" }] = {
      telescope = safe_require("telescope.builtin").lsp_document_diagnostics,
      fzflua = safe_require("fzf-lua").lsp_document_diagnostics,
    },
    [{ mode = "n", lhs = "lD" }] = {
      telescope = safe_require("telescope.builtin").lsp_workspace_diagnostics,
      fzflua = safe_require("fzf-lua").lsp_workspace_diagnostics,
    },
    [{ mode = "n", lhs = "la" }] = {
      telescope = nil,
      fzflua = safe_require("fzf-lua").lsp_code_actions,
    },
    [{ mode = "n", lhs = "<f5><f4>" }] = {
      telescope = nil,
      fzflua = safe_require("fzf-lua").blines,
    },
    [{ mode = "n", lhs = "<space>u" }] = {
      telescope = nil,
      fzflua = safe_require("m.fzflua-custom").undo_tree,
    },
    [{ mode = "n", lhs = "<space>m" }] = {
      telescope = nil,
      fzflua = safe_require("m.fzflua-custom").notifications,
    },
    [{ mode = "n", lhs = "<f11><f11>" }] = {
      telescope = nil,
      fzflua = safe_require("m.fzflua-custom").git_reflog,
    },
  }

  for k, v in pairs(fuzzy_finder_keymaps) do
    if v.telescope ~= nil then lua_keymap(k.mode, k.lhs, v.telescope, {}) end
    if v.fzflua ~= nil then lua_keymap(k.mode, k.lhs, v.fzflua, {}) end
  end

  -- LSP
  vim_keymap("n", "lu", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  vim_keymap("n", "lj", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  vim_keymap("n", "lI", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  vim_keymap("i", "<C-p>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  vim_keymap("n", "le", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  vim_keymap("n", "lR", "<cmd>LspRestart<CR>", opts)
  vim_keymap("n", "<space>l", "<cmd>LspInfo<CR>", opts)

  lua_keymap("n", "ll", utils.run_and_notify(vim.lsp.buf.format, "Formatted"), {})

  local lsp_pick_formatter = function()
    local clients = vim.lsp.get_active_clients({
      bufnr = 0, -- current buffer
    })

    local format_providers = {}
    for _, c in ipairs(clients) do
      if c.server_capabilities.documentFormattingProvider then table.insert(format_providers, c.name) end
    end

    vim.ui.select(format_providers, {
      prompt = "Select format providers:",
      format_item = function(provider_name) return provider_name end,
    }, function(provider_name)
      vim.lsp.buf.format({
        filter = function(client) return client.name == provider_name end,
      })
    end)
  end
  lua_keymap("n", "lL", lsp_pick_formatter, {})

  -- Terminal
  if config.terminal_plugin == "floaterm" then
    vim_keymap("n", "<f12>", "<cmd>FloatermToggle<CR>", opts)
    vim_keymap("t", "<f12>", "<cmd>FloatermToggle<CR>", opts)
  end

  -- Comment
  vim_keymap("n", "<C-/>", "<Plug>(comment_toggle_linewise_current)", opts)
  vim_keymap("v", "<C-/>", "<Plug>(comment_toggle_linewise_visual)gv", opts) -- Re-select the last block
  local comment_api = safe_require("Comment.api")
  if not vim.tbl_isempty(comment_api) then lua_keymap("i", "<C-/>", comment_api.toggle.linewise.current, {}) end

  -- GitSigns
  vim_keymap("n", "su", "<cmd>Gitsigns preview_hunk_inline<CR>", opts)
  vim_keymap("n", "si", "<cmd>Gitsigns prev_hunk<CR>", opts)
  vim_keymap("n", "sk", "<cmd>Gitsigns next_hunk<CR>", opts)
  vim_keymap("n", "sb", "<cmd>Gitsigns blame_line<CR>", opts)
  vim_keymap("n", "sj", "<cmd>Gitsigns stage_hunk<CR>", opts)
  vim_keymap("n", "sl", "<cmd>Gitsigns undo_stage_hunk<CR>", opts)
  vim_keymap("n", "s;", "<cmd>Gitsigns reset_hunk<CR>", opts)

  -- :qa, :q!, :wq
  vim_keymap("n", "<space>q", ":q<cr>", opts)
  vim_keymap("n", "<space>w", ":w<cr>", opts)
  vim_keymap("n", "<space><BS>", ":q!<cr>", opts)
  vim_keymap("n", "<space>s", ":w!<cr>", opts)
  vim_keymap("n", "<space>a", ":qa<cr>", opts)
  vim_keymap("n", "<space>e", ":e<cr>", opts)
  vim_keymap("n", "<space><delete>", ":qa!<cr>", opts)

  -- Command line window
  vim_keymap("n", "<space>;", "q:", opts)

  -- Session restore
  lua_keymap("n", "<Space>r", utils.run_and_notify(safe_require("persistence").load, "Reloaded session"), {})

  -- Colorizer
  lua_keymap("n", "<leader>c", utils.run_and_notify(function() vim.cmd([[ColorizerToggle]]) end, "Colorizer toggled"), {})
  lua_keymap("n", "<leader>C", utils.run_and_notify(function() vim.cmd([[ColorizerReloadAllBuffers]]) end, "Colorizer reloaded"), {})

  -- Nvim Cmp
  lua_keymap("i", "<M-r>", function()
    local cmp = require("cmp")

    if cmp.visible() then cmp.confirm({ select = true }) end
  end, {})

  -- Copilot
  if config.copilot_plugin == "vim" then
    vim_keymap("n", "<leader>p", "<cmd>Copilot setup<CR>", opts)
  elseif config.copilot_plugin == "lua" then
    lua_keymap("i", "<M-a>", safe_require("copilot.suggestion").accept, {})
    lua_keymap("i", "<M-w>", safe_require("copilot.suggestion").accept_line, {})
    lua_keymap("i", "<M-d>", safe_require("copilot.suggestion").next, {})
    lua_keymap("i", "<M-e>", safe_require("copilot.suggestion").prev, {})
    lua_keymap("i", "<M-q>", safe_require("copilot.panel").open, {})
    lua_keymap("n", "<M-e>", safe_require("copilot.panel").jump_prev, {})
    lua_keymap("n", "<M-d>", safe_require("copilot.panel").jump_next, {})
    lua_keymap("n", "<M-a>", safe_require("copilot.panel").accept, {})
  end

  if config.ssr_plugin then lua_keymap({ "n", "v" }, "<leader>f", safe_require("ssr").open, {}) end

  -- Diffview
  if config.diffview_plugin then
    vim_keymap("n", "<f11><f1>", "<cmd>DiffviewOpen<cr>", opts)
    vim_keymap("n", "<f11><f2>", "<cmd>DiffviewFileHistory %<cr>", opts) -- See current file git history
    vim_keymap("v", "<f11><f2>", ":DiffviewFileHistory %<cr>", opts) -- See current selection git history
  end

  -- File tree
  if config.filetree_plugin == "nvimtree" then vim_keymap("n", "<f2><f1>", "<cmd>NvimTreeFindFile<cr>", opts) end

  -- File managers
  if config.lf_plugin == "vim" then
    vim_keymap("n", "<f2><f2>", "<cmd>LfWorkingDirectory<cr>", opts)
    vim_keymap("n", "<f2><f3>", "<cmd>LfCurrentFile<cr>", opts)
  elseif config.lf_plugin == "custom" then
    lua_keymap("n", "<f2><f2>", safe_require("m.lf").lf, {})
    lua_keymap("n", "<f2><f3>", function() safe_require("m.lf").lf({ path = vim.fn.expand("%:p:h") }) end, {})
  end
end

return M