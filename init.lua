-- init.lua
local generator = require('generator')

-- Register the :NewJavaFile command
vim.api.nvim_create_user_command('NewJavaFile', function()
    generator.generate_java_file()
end, {})
vim.keymap.set('n', '<leader>jn', ':NewJavaFile<CR>')
