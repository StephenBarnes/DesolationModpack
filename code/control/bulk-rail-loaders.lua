-- This file is for calling remote interfaces of the Bulk Rail Loader mod, in order to allow loading additional items.

-- List of items that should be allowed in bulk rail loaders/unloaders.
-- Also allowing containers of all of these items.
local extraBulkItemsAndContainers = {
	"carbon-crushed",
	"copper-crushed",
}
local extraBulkItems = {
	"ic-container", -- empty container
}

local function onInitOrLoad()
	if remote.interfaces["railloader"] then
		for _, itemName in pairs(extraBulkItemsAndContainers) do
			remote.call("railloader", "add_bulk_item", itemName)
			remote.call("railloader", "add_bulk_item", "ic-container-"..itemName)
		end
		for _, itemName in pairs(extraBulkItems) do
			remote.call("railloader", "add_bulk_item", itemName)
		end
	end
end

return {
	onInit = onInitOrLoad,
	onLoad = onInitOrLoad,
}

-- To print allowed items:
-- No console command, bc it's stored as a local in the mod.
-- Could edit the mod to log it, but rather don't.