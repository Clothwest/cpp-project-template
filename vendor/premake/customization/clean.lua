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
