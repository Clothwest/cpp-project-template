local M = {}

local SCOPES = {
	PRIVATE = "PRIVATE",
	PUBLIC = "PUBLIC",
	INTERFACE = "INTERFACE"
}

local registry = {
	targets = {}
}

local function append_value(values, value)
	if value == nil then
		return
	end

	if type(value) == "table" then
		for _, item in ipairs(value) do
			append_value(values, item)
		end
		return
	end

	table.insert(values, tostring(value))
end

local function flatten_values(...)
	local values = {}

	for index = 1, select("#", ...) do
		local value = select(index, ...)
		append_value(values, value)
	end

	return values
end

local function assert_valid_scope(scope)
	if type(scope) ~= "string" or not SCOPES[scope] then
		error("invalid scope '" .. tostring(scope) .. "'", 3)
	end
end

local function get_current_project_name()
	local current = nil

	if premake and premake.api and premake.api.current then
		current = premake.api.current.project
	end

	if not current and type(project) == "function" then
		current = project()
	end

	if not current or not current.name then
		error("include_directories() and link_libraries() must be called inside a project", 3)
	end

	return current.name
end

local function get_calling_script_dir()
	local info = debug.getinfo(3, "S")
	local source = info and info.source or nil

	if source and source:sub(1, 1) == "@" then
		local file = source:sub(2)

		if not path.isabsolute(file) then
			file = path.getabsolute(file, os.getcwd())
		end

		return path.getdirectory(file)
	end

	return os.getcwd()
end

local function get_target(name)
	local target = registry.targets[name]

	if target then
		return target
	end

	target = {
		private_includes = {},
		public_includes = {},
		interface_includes = {},

		private_links = {},
		public_links = {},
		interface_links = {},

		private_linkdirs = {},
		public_linkdirs = {},
		interface_linkdirs = {},

		private_uses = {},
		public_uses = {},
		interface_uses = {}
	}

	registry.targets[name] = target
	return target
end

-- local function is_registered_target(name)
-- 	return registry.targets[name] ~= nil
-- end

local function add_unique(list, value)
	for _, existing in ipairs(list) do
		if existing == value then
			return
		end
	end

	table.insert(list, value)
end

local function to_absolute_paths(values, base_dir)
	local result = {}

	for _, value in ipairs(values) do
		local absolute = value

		if not path.isabsolute(absolute) then
			absolute = path.getabsolute(absolute, base_dir)
		end

		add_unique(result, path.normalize(absolute))
	end

	return result
end

local function to_relative_paths(values, base_dir)
	local result = {}

	for _, value in ipairs(values) do
		add_unique(result, path.normalize(path.getrelative(base_dir, value)))
	end

	return result
end

local function collect_usage(target_name, result, visiting)
	local target = registry.targets[target_name]

	-- if not target then
	-- 	error("unknown dependency target '" .. tostring(target_name) ..
	-- 		"'. Make sure the dependency project is included before it is used.",
	-- 		3)
	-- end

	if not target or visiting[target_name] then
		return
	end

	visiting[target_name] = true

	for _, include_dir in ipairs(target.public_includes) do
		add_unique(result.includes, include_dir)
	end

	for _, include_dir in ipairs(target.interface_includes) do
		add_unique(result.includes, include_dir)
	end

	for _, library in ipairs(target.public_links) do
		add_unique(result.links, library)
		collect_usage(library, result, visiting)
	end

	for _, library in ipairs(target.interface_links) do
		add_unique(result.links, library)
		collect_usage(library, result, visiting)
	end

	for _, linkdir in ipairs(target.public_linkdirs) do
		add_unique(result.linkdirs, linkdir)
	end

	for _, linkdir in ipairs(target.interface_linkdirs) do
		add_unique(result.linkdirs, linkdir)
	end

	for _, library in ipairs(target.public_uses) do
		collect_usage(library, result, visiting)
	end

	for _, library in ipairs(target.interface_uses) do
		collect_usage(library, result, visiting)
	end

	visiting[target_name] = nil
end

local function apply_usage(libraries, caller_dir)
	local usage = {
		includes = {},
		links = {},
		linkdirs = {}
	}

	for _, library in ipairs(libraries) do
		collect_usage(library, usage, {})
	end

	if #usage.includes > 0 then
		includedirs(to_relative_paths(usage.includes, caller_dir))
	end

	if #usage.links > 0 then
		links(usage.links)
	end

	if #usage.linkdirs > 0 then
		libdirs(to_relative_paths(usage.linkdirs, caller_dir))
	end
end

function M.include_directories(scope, ...)
	assert_valid_scope(scope)

	local project_name = get_current_project_name()
	local target = get_target(project_name)

	local caller_dir = get_calling_script_dir()

	local values = flatten_values(...)
	local absolute_paths = to_absolute_paths(values, caller_dir)

	if scope == SCOPES.PRIVATE then
		for _, include_dir in ipairs(absolute_paths) do
			add_unique(target.private_includes, include_dir)
		end

		includedirs(values)
		return
	end

	if scope == SCOPES.PUBLIC then
		for _, include_dir in ipairs(absolute_paths) do
			add_unique(target.public_includes, include_dir)
		end

		includedirs(values)
		return
	end

	if scope == SCOPES.INTERFACE then
		for _, include_dir in ipairs(absolute_paths) do
			add_unique(target.interface_includes, include_dir)
		end
		return
	end
end

function M.link_libraries(scope, ...)
	assert_valid_scope(scope)

	local project_name = get_current_project_name()
	local target = get_target(project_name)

	local caller_dir = get_calling_script_dir()

	local libraries = flatten_values(...)

	if scope == SCOPES.PRIVATE then
		for _, library in ipairs(libraries) do
			add_unique(target.private_links, library)
		end

		links(libraries)
		apply_usage(libraries, caller_dir)
		return
	end

	if scope == SCOPES.PUBLIC then
		for _, library in ipairs(libraries) do
			add_unique(target.public_links, library)
		end

		links(libraries)
		apply_usage(libraries, caller_dir)
		return
	end

	if scope == SCOPES.INTERFACE then
		for _, library in ipairs(libraries) do
			add_unique(target.interface_links, library)
		end
		return
	end
end

function M.link_directories(scope, ...)
	assert_valid_scope(scope)

	local project_name = get_current_project_name()
	local target = get_target(project_name)

	local caller_dir = get_calling_script_dir()

	local directories = flatten_values(...)
	local absolute_paths = to_absolute_paths(directories, caller_dir)

	if scope == SCOPES.PRIVATE then
		for _, directory in ipairs(absolute_paths) do
			add_unique(target.private_linkdirs, directory)
		end

		libdirs(directories)
		return
	end

	if scope == SCOPES.PUBLIC then
		for _, directory in ipairs(absolute_paths) do
			add_unique(target.public_linkdirs, directory)
		end

		libdirs(directories)
		return
	end

	if scope == SCOPES.INTERFACE then
		for _, directory in ipairs(absolute_paths) do
			add_unique(target.interface_linkdirs, directory)
		end
		return
	end
end

function M.use_libraries(scope, ...)
	assert_valid_scope(scope)

	local project_name = get_current_project_name()
	local target = get_target(project_name)

	local call_dir = get_calling_script_dir()

	local libraries = flatten_values(...)

	if scope == SCOPES.PRIVATE then
		for _, library in ipairs(libraries) do
			add_unique(target.private_uses, library)
		end

		apply_usage(libraries, call_dir)
		return
	end

	if scope == SCOPES.PUBLIC then
		for _, library in ipairs(libraries) do
			add_unique(target.public_uses, library)
		end

		apply_usage(libraries, call_dir)
		return
	end

	if scope == SCOPES.INTERFACE then
		for _, library in ipairs(libraries) do
			add_unique(target.interface_uses, library)
		end
		return
	end
end

M._registry = registry
M._scopes = SCOPES

include_directories = M.include_directories
link_libraries = M.link_libraries
link_directories = M.link_directories
use_libraries = M.use_libraries

PRIVATE = SCOPES.PRIVATE
PUBLIC = SCOPES.PUBLIC
INTERFACE = SCOPES.INTERFACE

-- Dependency projects must be included before they are linked if their usage
-- requirements should be propagated. Unknown libraries are treated as external
-- linker inputs and do not provide usage requirements.

return M
