local toggleTerm = require("toggleterm")
local Job = require("plenary.job")
local M = {}
local data = {}

local pattern = "(%w+)%s%-%s"
function detectGradleProject()
	local gradle_pattern = "gradle*"
	local files = vim.fn.glob(vim.fn.getcwd() .. "/*" ,false, true)
	for _, file in pairs(files) do
		if string.gmatch(file,gradle_pattern) then

			vim.notify("gradle project detected syncing ...",vim.log.levels.INFO)

			local res = vim.fn.system("./gradlew tasks")
			for match in string.gmatch(res, pattern) do
				table.insert(data, match)
			end
			break
		end
	end
end
function executeGradleTask()
	vim.ui.select(data,{prompt="select task to execute"},function(choice)
		vim.notify(choice,vim.log.levels.INFO)
		toggleTerm.exec("./gradlew "..choice)
	end)
end

M.detectGradleProject = Job:new({on_stdout = detectGradleProject}):start
M.executeGradleTask = executeGradleTask
return M
