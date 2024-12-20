local log_file_path = vim.fn.stdpath('data') .. "/javad-tools.txt"

local pack = {}

local function log_to_file(message)
	local file = io.open(log_file_path,"a")
	if file then
		file:write(os.date("%Y-%m-%d %H:%M:%S") .." ".. message .. "\n")
		file:close()
	else
		vim.notify("can't log data for javad-tools")
	end
end

pack.log_to_file = log_to_file
return pack
