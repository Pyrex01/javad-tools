module("jdtlsgenerator",package.seeall)

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
        print("Error: jdtls is not attached to this buffer.")
        return
    end
    -- Build the parameters for the LSP request
    local params = {
        command = "java.project.getClasspaths",
        arguments = {
            vim.lsp.buf.list_workspace_folders()[1] or vim.fn.getcwd() -- Use workspace folder or fallback to current directory
        }
    }
    -- Make a synchronous request to the server
    local result = vim.lsp.buf_request_sync(0, "workspace/executeCommand", params, 3000)
    -- Handle the result
    if not result then
        print("Error: No response received from the language server.")
        return
    end
    -- Iterate over results to extract classpath
    for client_id, resp in pairs(result) do
        if resp.error then
            print("Error from client " .. client_id .. ": " .. vim.inspect(resp.error))
        elseif resp.result then
            print("Classpath for client " .. client_id .. ":")
            for _, path in ipairs(resp.result) do
                print("  " .. path)
            end
        else
            print("Client " .. client_id .. " returned an unexpected response: " .. vim.inspect(resp))
        end
    end
end

vim.keymap.set('n','<leader>gj',function()
	print("executing generation")
	get_jdtls_classpath()
end)
return get_jdtls_classpath
