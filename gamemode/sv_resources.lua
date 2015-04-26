local AddDir
function AddDir(dir)
	local files, folders = file.Find(dir .. "/*", "GAME")

	for k,v in pairs(files) do
		resource.AddFile(dir.."/"..v)
	end

	for _, fdir in pairs(folders) do
		AddDir(dir.."/"..fdir)
	end
end

AddDir("models/zinger")
AddDir("materials/zinger")
AddDir("sound/zinger")
resource.AddFile("particles/zinger.pcf")
resource.AddFile("resource/fonts/comickbook_simple.ttf")
