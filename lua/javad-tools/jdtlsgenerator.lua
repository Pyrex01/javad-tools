local logger = require("javad-tools.logger").log_to_file
local pack = {}
local function get_jdtls_classpath()
	-- Check if a client is attached
	local clients = vim.lsp.get_active_clients()
	local jdtls_attached = false
	-- Verify that the jdtls client is attached
	for _, client in pairs(clients) do
		if client.name == "jdtls" then
			jdtls_attached = true
			break
		end
	end
	if not jdtls_attached then
		logger("Error: jdtls is not attached to this buffer.")
		return
	end
	-- Build the parameters for the LSP request
	local params = {
		command = "java.projectConfiguration.update",
		arguments = {
			vim.fn.getcwd() -- Use workspace folder or fallback to current directory
		}
	}
	-- Make a synchronous request to the server
	local result = vim.lsp.buf_request_sync(0, "workspace/executeCommand", params, 3000)
	-- Handle the result
	if not result then
		logger("Error: No response received from the language server.")
		return
	end
	-- Iterate over results to extract classpath
	for client_id, resp in pairs(result) do
		if resp.error then
			logger("Error from client " .. client_id .. ": " .. vim.inspect(resp.error))
		elseif resp.result then
			logger("Classpath for client " .. client_id .. ":")
			for _, path in ipairs(resp.result) do
				logger("  " .. path)
			end
		else
			logger("Client " .. client_id .. " returned an unexpected response: " .. vim.inspect(resp))
		end
	end
end

pack.get_jdtls_classpath = get_jdtls_classpath
return pack
