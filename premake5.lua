workspace "@WORKSPACE@"
	architecture "x64"
	staticruntime "On"
	systemversion "latest"

	startproject "@STARTPROJECT@"

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

include "@Core@"
include "@App@"
		
newaction
{
	trigger = "clean",
	description = "Clean intermediates.",
	onStart = function()
		print("Starting cleaning...")
	end,
	execute = function()
		local cacheDir = ".vs"
		local sln = "*.sln"
		local prj = "**.vcxproj*"

		os.rmdir(cacheDir)
		print("Cleaned", cacheDir)

		os.remove(sln)
		print("Cleaned", sln)

		os.remove(prj)
		print("Cleaned", prj)
	end,
	onEnd = function()
		print("Done.")
	end
}
