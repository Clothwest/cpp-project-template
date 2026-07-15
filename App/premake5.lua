project "@APP@"
	kind "ConsoleApp"
	language "C++"
	cppdialect "C++20"

	files { "src/**.hpp", "src/**.cpp" }

	includedirs { "src" }

	uses { "@Core@" }
