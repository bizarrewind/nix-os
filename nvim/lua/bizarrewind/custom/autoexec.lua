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

local function get_command()
	local filetype = vim.bo.filetype
	local filepath = vim.api.nvim_buf_get_name(0)
	if filepath == "" then
		print("No file path found. Save the file first.")
		return
	end
	local command = nil
	if filetype == "c" then
		--	command = string.format("gcc %s -o %s && ./%s", filepath, "output", "output")
		command = string.format("gcc %s   && ./a.out", filepath)
	elseif filetype == "java" then
		command = string.format("java %s", filepath)
	else
		print("Invalid File type")
		return nil
	end
	return command
end

local function autoexec()
	local command = get_command()
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
--
vim.keymap.set("n", "<leader>ex", function()
	autoexec()
end)

vim.keymap.set("t", "GG", "<cmd>q<CR>", { noremap = true })
--
vim.keymap.set("n", "<leader>gg", function()
	if vim.bo.buftype == "terminal" then
		vim.cmd("q")
		job_id = 0
		print("Successfully set job_id to 0")
	else
		print("Not in a terminal buffer")
	end
end, { noremap = true })
--
--
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
