project "@Core@"
	kind "StaticLib"
	language "C++"
	cppdialect "C++20"

	files { "src/**.hpp", "src/**.cpp" }

usage "PUBLIC"
	includedirs { "src" }

usage "INTERFACE"
	links "@Core@"
