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
		buf = vim.api.nvim_create_buf(false, true) -- No file, not listed
		local job_id = vim.bo.channel
		print(job_id)
	end
	local win = vim.api.nvim_open_win(buf, true, win_config)

	return { buf = buf, win = win } -- Return buffer handle for further customization if needed
end
local toggle_terminal = function()
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
	vim.fn.chansend(job_id, command .. "\r\n")
	vim.cmd("startinsert")
end
local function autoexec()
	local filepath = vim.api.nvim_buf_get_name(0)
	if filepath == "" then
		print("No file path found. Save the file first.")
		return
	end

	local filetype = vim.bo.filetype
	local command = nil

	if filetype == "c" then
		command = string.format("gcc %s && ./a", filepath)
	elseif filetype == "java" then
		command = string.format("java %s", filepath)
	else
		print("Unsupported file type")
		return { filepath, command }
	end

	if not vim.api.nvim.nvim_win_is_valid(state.floating.win) then
		toggle_terminal()
	end
	send_to_terminal(vim.bo[state.floating.buf].channel, command)
end

vim.keymap.set({ "n", "t" }, "<space>xe", function()
	autoexec()
end)
--vim.keymap.set({ "n", "t" }, "tt", vim.cmd("Floaterminal"))

-- Example usage
-- create_floating_window({  }) -- 60% width, 70% height
-- create_floating_window() -- Defaults to 80% width and height
local job_id = 0
local function create_terminal()
	vim.cmd.vnew()
	vim.cmd.term()
	vim.cmd.wincmd("L")
	vim.api.nvim_win_set_width(0, 50)
	job_id = vim.bo.channel
end

vim.keymap.set("n", "<leader>st", function()
	create_terminal()
end)

local function autoexec()
	local filepath = vim.api.nvim_buf_get_name(0)
	if filepath == "" then
		print("No file path found. Save the file first.")
		return
	end

	local filetype = vim.bo.filetype
	local command = nil
	if filetype == "c" then
		--	command = string.format("gcc %s -o %s && ./%s", filepath, "output", "output")
		command = string.format("gcc %s   && ./a", filepath)
	elseif filetype == "java" then
		command = string.format("java %s", filepath)
	else
		print("Invalid File type")
		return
	end
	--create a new terminal if it doesnt exist
	if job_id == 0 then
		create_terminal()
		vim.cmd("startinsert")
	end
	if job_id then
		--send command to the terminal
		vim.fn.chansend(job_id, command .. "\r\n")
		vim.cmd("startinsert")
		print("Running:", command)
	else
		print("Couldnt send job no job id")
	end
end

vim.keymap.set("t", "GG", "<cmd>q<CR>", { noremap = true })
vim.keymap.set("n", "<leader>gg", function()
	if vim.bo.buftype == "terminal" then
		vim.cmd("q")
		job_id = 0
		print("Successfully set job_id to 0")
	else
		print("Not in a terminal buffer")
	end
end, { noremap = true })

vim.keymap.set("n", "<leader>ex", function()
	autoexec()
end)
vim.keymap.set("n", "<leader>sgg", function()
	if job_id == 0 then
		print("No Ternimal job")
		return
	end
	vim.fn.chansend(job_id, "exit \r\n")
	vim.cmd("")
	vim.cmd("startinsert")
	job_id = 0
end)
