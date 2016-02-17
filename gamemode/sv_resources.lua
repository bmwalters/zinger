local function AddDir(dir)
	local files, folders = file.Find(dir .. "/*", "GAME")

	for _, fname in pairs(files) do
		resource.AddFile(dir .. "/" .. fname)
	end

	for _, dir2 in pairs(folders) do
		AddDir(dir .. "/" .. dir2)
	end
end

AddDir("models/zinger")
AddDir("materials/zinger")
AddDir("sound/zinger")
resource.AddFile("particles/zinger.pcf")
resource.AddFile("resource/fonts/comickbook_simple.ttf")
