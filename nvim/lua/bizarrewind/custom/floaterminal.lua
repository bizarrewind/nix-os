vim.keymap.set("t", "<esc><esc>", "<C-\\><C-n>")
local state = {

	floating = {
		buf = -1,
		win = -1,
	},
}
local function create_floating_window(opts)
	-- Get the current screen dimensions
	opts = opts or {}
	local width = vim.o.columns
	local height = vim.o.lines

	-- Set the defaults to 80% of the screen size
	local win_width = math.floor((opts and opts.width or 0.8) * width)
	local win_height = math.floor((opts and opts.height or 0.8) * height)

	-- Calculate the centered position
	local row = math.floor((height - win_height) / 2)
	local col = math.floor((width - win_width) / 2)

	-- Define the window configuration
	local win_config = {
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	}

	-- Create a new buffer and set it as a floating window
	local buf = nil
	if vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true)
	end
	local win = vim.api.nvim_open_win(buf, true, win_config)

	return { buf = buf, win = win } -- Return buffer handle for further customization if needed
end

local function toggle_terminal()
	if not vim.api.nvim_win_is_valid(state.floating.win) then
		state.floating = create_floating_window({ buf = state.floating.buf })
		if vim.bo[state.floating.buf].buftype ~= "terminal" then
			vim.cmd.terminal()
		end
	else
		vim.api.nvim_win_hide(state.floating.win)
	end
end

vim.api.nvim_create_user_command("Floaterminal", toggle_terminal, {})
vim.keymap.set({ "n", "t" }, "<space>tt", function()
	toggle_terminal()
	vim.cmd("startinsert")
end)

local function send_to_terminal(job_id, command)
	if job_id == 0 then
		print("No terminal job found")
		return
	end
	vim.fn.chansend(job_id, "clear\r")
	vim.fn.chansend(job_id, command .. "\r")
	vim.cmd("startinsert")
end

local function autoexec2()
	local filepath = vim.api.nvim_buf_get_name(0)
	if filepath == "" then
		print("No file path found. Save the file first.")
		return
	end

	local filetype = vim.bo.filetype
	local command = nil

	if filetype == "c" then
		command = string.format("gcc %s && ./a.out", filepath)
	elseif filetype == "java" then
		command = string.format("java %s", filepath)
	elseif filetype == "python" then
		command = string.format("python3 %s ", filepath)
	else
		print("Unsupported file type")
		return
	end

	if not vim.api.nvim_win_is_valid(state.floating.win) then
		state.floating = create_floating_window({ buf = state.floating.buf })
		if vim.bo[state.floating.buf].buftype ~= "terminal" then
			vim.cmd.terminal()
		end
		send_to_terminal(vim.bo[state.floating.buf].channel, command)
	end
end

vim.keymap.set({ "n", "t" }, "<space>eu", function()
	autoexec2()
end)
