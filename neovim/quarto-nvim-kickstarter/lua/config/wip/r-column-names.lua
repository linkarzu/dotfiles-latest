-- WIP features

local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local ts_utils = require 'nvim-treesitter.ts_utils'

local otter = require 'otter'

local function find_identifier_at_pipe_start()
  local result = 'hello'

  local node = vim.treesitter.get_node { ignore_injections = false }

  -- found first pipe up from cursor
  while node:parent() ~= nil and node:type() ~= 'pipe' do
    node = node:parent()
  end
  -- go to earliest pipe
  while node:parent() ~= nil and node:type() == 'pipe' do
    node = node:parent()
  end

  print(node)
  print(node:child(0))
  print(node:child(1))
  print(node:child(2))
end

local function get_r_colnames()
  -- local cword = vim.fn.expand('<cword>')
  local cword = find_identifier_at_pipe_start()

  local r_cmd = 'names(' .. cword .. ')\n'
  local id = vim.g.slime_last_channel

  local info = vim.api.nvim_get_chan_info(id)
  local bufnr = info.buffer
  local tick = vim.api.nvim_buf_get_changedtick(bufnr)

  vim.api.nvim_chan_send(id, r_cmd)

  if tick == vim.api.nvim_buf_get_changedtick(bufnr) then
    vim.wait(100, function()
      return tick ~= vim.api.nvim_buf_get_changedtick(bufnr)
    end, 100)
  end

  -- look through lines backwards until we find the line with
  -- the prompt
  local i = vim.api.nvim_buf_line_count(bufnr) - 1
  local max_search = 80
  local lines = {}
  while i > 0 and max_search > 0 do
    local line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1]
    if line:find '^>' then
      break
    end
    table.insert(lines, line)
    i = i - 1
    max_search = max_search - 1
  end

  local items = {}
  for _, item in ipairs(lines) do
    for word in item:gmatch '"([^"]+)"' do
      table.insert(items, word)
    end
  end

  -- Telescope
  local opts = {}
  pickers
    .new(opts, {
      prompt_title = 'Names',
      finder = finders.new_table {
        results = items,
      },
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.cmd.normal 'ea$'
          vim.api.nvim_put({ selection[1] }, '', true, true)
        end)
        return true
      end,
    })
    :find()
end

vim.keymap.set('n', '<leader>x', reload, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>r', find_identifier_at_pipe_start, { noremap = true, silent = true })
