-- generator.lua
local M = {}

-- Helper: Convert a string to PascalCase and validate it
local function is_pascal_case(str)
    return str:match("^[A-Z][a-zA-Z0-9]*$") ~= nil
end

local function getSubPath(path)
    local dir_pattern = path .. '/*'
    local dir_list = vim.fn.glob(dir_pattern, 0, 1)
    if dir_list == nil or next(dir_list) == nil then
        return path
    end

    for _, dir in ipairs(dir_list) do
        if vim.fn.isdirectory(dir) == 1 then
            return getSubPath(dir)
        end
    end

    return path
end

-- Detect the base path for the project (src/main/java)
local function detect_base_path()
    -- Case 1: Check if inside `src/main/java`
    local current_path = vim.fn.getcwd()
    -- Get the current file's directory
    if current_path:match("src/main/java") then
        return current_path:match("(.*/src/main/java)")  -- Return the base path
    end

    -- Case 2: Check if current working directory contains `src/main/java`
    local root_path = vim.fn.getcwd()  -- Get current working directory
    if vim.fn.isdirectory(root_path .. "/src/main/java") == 1 then
        return root_path .. "/src/main/java"  -- Return the base path
    end

    -- Case 3: No valid base path found, prompt to create one
    local create = vim.fn.confirm(
        "No 'src/main/java' directory found. Create one?",
        "&Yes\n&No"
    )

    if create == 1 then
        local new_path = root_path .. "/src/main/java"
        vim.fn.mkdir(new_path, "p")  -- Create the directory
        print("Created " .. new_path)
        return new_path  -- Return the newly created base path
    else
        print("Aborted: No valid base path.")
        return nil  -- Return nil if the user chooses not to create the directory
    end
end

local  function get_base_path()
	detect_base_path()
	local expectedPath = '/src/main/java'
	local path = vim.fn.expand("%:p:h")
	local index = string.find(path,expectedPath)
	if index ~= nil then
		local base_start = index + string.len(expectedPath)
	end

	local isD = vim.fn.isdirectory(path .. '/src/main/java/')
	if isD then 
		local path = getSubPath(vim.fn.getcwd())
		if path ~= nil then

			local parsed = string.find(path,expectedPath)
			return path:sub(parsed+15):gsub('/','.')
		end
	end
	return nil
end

-- Helper: Split input by the last dot to extract package and class name
local function extract_package_and_class(input)
    local last_dot = input:match(".*()%.")
    if not last_dot then
        print("Error: Input must be in 'com.example.ClassName' format.")
        return nil, nil
    end

    local package_name = input:sub(1, last_dot - 1)
    local class_name = input:sub(last_dot + 1)

    if not is_pascal_case(class_name) then
        print("Error: Class name must be in PascalCase (e.g., 'MainClass').")
        return nil, nil
    end

    return package_name, class_name
end

-- Create directories for the package if they don't exist
local function ensure_directories_exist(base_path, package_name)
    local path = base_path .. "/" .. package_name:gsub("%.", "/")
    if vim.fn.isdirectory(path) == 0 then
        vim.fn.mkdir(path, "p")
    end
    return path
end

-- Prompt for Java file type
local function select_type(on_confirm)
    local types = { "class", "interface", "enum" }
    vim.ui.select(types, { prompt = "Select Java File Type:" }, function(choice)
        if choice then on_confirm(choice) end
    end)
end

-- Main function to generate Java file
function M.generate_java_file()
    -- Detect package automatically
    local detected_package = get_base_path()
    local input_text = ""
    if detected_package ~= nil then
        input_text = detected_package .. "."
    end

    select_type(function(file_type)
        -- Prompt for package and class input with pre-filled package
        vim.ui.input({
            prompt = "Enter Package and Class (e.g., com.example.Main): ",
            default = input_text
        }, function(input)
            if not input or input == "" then
                print("Error: Input cannot be empty.")
                return
            end

            local package_name, class_name = extract_package_and_class(input)
            if not package_name or not class_name then return end

            -- Detect base path or prompt for creation
            local base_path = detect_base_path()
            if not base_path then return end

            local target_path = ensure_directories_exist(base_path, package_name)

            -- Generate content
            local package_line = "package " .. package_name .. ";\n\n"
            local templates = {
                class = "public class " .. class_name .. " {\n\n}",
                interface = "public interface " .. class_name .. " {\n\n}",
                enum = "public enum " .. class_name .. " {\n\n}",
            }

            local content = package_line .. templates[file_type]
            local file_path = target_path .. "/" .. class_name .. ".java"

            -- Write content to file
            local file = io.open(file_path, "w")
            if not file then
                print("Error: Could not create file.")
                return
            end
            file:write(content)
            file:close()

            print("Created " .. file_path)
            vim.cmd("edit " .. file_path)
        end)
    end)
end

return M
