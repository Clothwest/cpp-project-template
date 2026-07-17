project "APP"
	kind "ConsoleApp"
	language "C++"
	cppdialect "C++20"

	files { "src/**.hpp", "src/**.cpp" }

	include_directories(PRIVATE, "src")
	link_libraries(PRIVATE, "CORE")
