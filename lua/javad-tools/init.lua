-- init.lua
local gradleE = require("javad-tools.gradle_integration")

local logger = require("javad-tools.logger").log_to_file

local generator = require('javad-tools.generator')
local lsp_generator = require("javad-tools.jdtlsgenerator")
gradleE.detectGradleProject()
local M = {}
M.executeGradleTask = gradleE.executeGradleTask
M.generator = generator.generate_java_file

return M
