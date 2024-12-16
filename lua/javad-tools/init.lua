-- init.lua
local generator = require('javad-tools.generator')
local lsp_generator = require("javad-tools.jdtlsgenerator")

local M = {}

M.generator = generator.generate_java_file
M.jdtls_generator = lsp_generator


return M
