project "CORE"
	kind "StaticLib"
	language "C++"
	cppdialect "C++20"

	files { "src/**.hpp", "src/**.cpp" }

	include_directories(PUBLIC, "src")
