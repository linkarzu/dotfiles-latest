-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/config/modules/daily_note.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/config/modules/daily_note.lua
--
-- Where daily notes live, shared by the gt keymap and the task picker

local M = {}

M.personal_dir = vim.fn.expand("~/github/notes/250-daily")

local function normalize_path(path)
  if type(path) ~= "string" or path == "" then
    return nil
  end
  local expanded = vim.fn.expand(path)
  local resolved = vim.uv.fs_realpath(expanded)
  return (resolved or vim.fs.normalize(expanded)):gsub("/$", "")
end

local function read_work_env_path(name)
  if not name:match("^WORK_[A-Z0-9_]+$") then
    return nil
  end

  local work_env_file = vim.fn.expand("~/github/dotfiles-private/work/work-env.sh")
  if vim.fn.filereadable(work_env_file) == 0 then
    return nil
  end

  local command =
    string.format("source %s >/dev/null 2>&1 && print -r -- ${%s}", vim.fn.shellescape(work_env_file), name)
  local output = vim.fn.systemlist({ "/bin/zsh", "-lc", command })
  if vim.v.shell_error ~= 0 or not output[1] or output[1] == "" then
    return nil
  end

  return normalize_path(output[1])
end

local function is_inside_path(path, root)
  local normalized_path = normalize_path(path)
  local normalized_root = normalize_path(root)
  if not normalized_path or not normalized_root then
    return false
  end
  return normalized_path == normalized_root or vim.startswith(normalized_path, normalized_root .. "/")
end

-- Work daily notes when the cwd is inside the work notes, personal otherwise
function M.dir_for_cwd()
  local work_daily_note_dir = read_work_env_path("WORK_DAILY_NOTE_DIR")
  local work_main_dir = read_work_env_path("WORK_MAIN_DIR")
  local cwd = vim.fn.getcwd()
  if work_daily_note_dir and (is_inside_path(cwd, work_daily_note_dir) or is_inside_path(cwd, work_main_dir)) then
    return work_daily_note_dir
  end
  return M.personal_dir
end

-- Path of today's daily note, like 250-daily/2026/10-Oct/2026-10-07-Wednesday.md
function M.today_path(daily_note_dir)
  return string.format(
    "%s/%s/%s.md",
    daily_note_dir or M.personal_dir,
    os.date("%Y/%m-%b"),
    os.date("%Y-%m-%d-%A")
  )
end

-- Create the daily note with the same skeleton gt uses if it does not exist
function M.ensure(path)
  if vim.fn.filereadable(path) == 1 then
    return true
  end
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  local file = io.open(path, "w")
  if not file then
    return false
  end
  file:write(string.format("# %s\n\n## Daily Note\n\n", vim.fn.fnamemodify(path, ":t:r")))
  file:close()
  return true
end

return M
