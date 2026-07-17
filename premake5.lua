require "vendor.premake.customization.dependencies"
require "vendor.premake.customization.clean"

workspace "WORKSPACE"
	architecture "x64"
	staticruntime "On"
	systemversion "latest"

	startproject "APP"

	configurations
	{
		"Debug",
		"Release"
	}

	-- buildoptions { "/utf-8" }

targetdir(".bin/%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}/%{prj.name}")
objdir(".bin-int/%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}/%{prj.name}")

filter "configurations:Debug"
	symbols "On"
	runtime "Debug"

filter "configurations:Release"
	optimize "Speed"
	runtime "Release"

filter {}

include "CORE"
include "APP"
