local otter = require 'otter.keeper'

local main = function()
  local buf = vim.api.nvim_get_current_buf()
  local tsquery = '(left_assignment name: (identifier) @name value: (_) @value)'
  local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
  local lang = 'r'
  local tmp_buf
  local r_buf
  local replacement_start
  local replacement_end

  if ft == 'quarto' then
    local cell_lang, start_row, _, end_row, _ = otter.get_current_language_context(buf)
    if cell_lang ~= 'r' then
      vim.notify_once('[qnk] targets refactoring only works in R files or R cells in quarto files.', vim.log.levels.WARN)
      return
    end
    if start_row == nil or end_row == nil then
      vim.notify_once('[qnk] code cell context not found.', vim.log.levels.WARN)
      return
    end

    tmp_buf = vim.api.nvim_create_buf(false, false)
    local code = vim.api.nvim_buf_get_lines(buf, start_row, end_row + 1, false)
    vim.api.nvim_buf_set_lines(tmp_buf, 0, -1, false, code)
    vim.treesitter.start(tmp_buf, 'r')
    r_buf = tmp_buf
    replacement_start = start_row
    replacement_end = end_row + 1
  else
    r_buf = buf
  end

  local query = vim.treesitter.query.parse(lang, tsquery)
  local parser = vim.treesitter.get_parser(r_buf, 'r')
  local tree = parser:parse({ 0, -1 })[1]
  local root = tree:root()
  local res = {}
  local name_line
  local range
  for id, node, metadata, match in query:iter_captures(root, r_buf) do
    local name = query.captures[id]
    res[name] = vim.treesitter.get_node_text(node, r_buf)
    local line = vim.treesitter.get_range(node, r_buf, metadata)[4]
    if name == 'name' then
      name_line = line
      if ft ~= 'quarto' then
        replacement_start = line
      end
    elseif name == 'value' then
      range = line - name_line
    end
  end
  if res == {} or range == nil then
    vim.notify_once('[qnk] R assignment not found.', vim.log.levels.WARN)
    return
  end
  replacement_end = replacement_start + range + 1
  local target_text = 'tar_target(' .. res['name'] .. ', ' .. res['value'] .. ')'
  local replacement_text = 'tar_load(' .. res['name'] .. ')'
  if ft == 'quarto' then
    vim.api.nvim_buf_delete(tmp_buf, { force = true })
  end
  vim.api.nvim_buf_set_lines(buf, replacement_start, replacement_end, false, { replacement_text })
  vim.fn.setreg('+', target_text, 'l')

  vim.cmd.edit '_targets.R'
end

vim.keymap.set('n', '<leader>rr', main, { desc = '[r]refactor' })
