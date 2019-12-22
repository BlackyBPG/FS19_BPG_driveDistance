-- 
-- Drive distance Vehicle Specilaization
-- by Blacky_BPG
-- 
-- Version: 1.9.0.3      |    25.11.2019    add dashboard functionality, fix display calculation
-- Version: 1.9.0.2      |    23.11.2019    correct display for total distance in use with TSX EnhancedVehicle mod, remove decimal for total distance, colorize decimal for trip distance
-- Version: 1.9.0.1      |    11.11.2019    initial version for FS19
-- Version: 1.5.3.1      |    28.03.2018    fixed override function for GUI element
-- Version: 1.4.4.0 D    |    15.03.2017    fixed multiplayer functionality
-- Version: 1.4.4.0 C    |    13.03.2017    fixed multiplayer functionality
-- Version: 1.4.4.0 B    |    12.03.2017    fixed savegame detection
-- Version: 1.4.4.0 A    |    12.03.2017    fixed variable error
-- Version: 1.4.4.0      |    09.03.2017    initial Version for FS17
-- 

registerDriveDistance = {}
registerDriveDistance.userDir = getUserProfileAppPath()
registerDriveDistance.version = "1.9.0.3  -  25.11.2019"

if g_specializationManager:getSpecializationByName("BPG_DriveDistance") == nil then
	g_specializationManager:addSpecialization("BPG_DriveDistance", "BPG_DriveDistance", Utils.getFilename("BPG_DriveDistance.lua",  g_currentModDirectory),true , nil)

	local numVehT = 0
	for typeName, typeEntry in pairs(g_vehicleTypeManager:getVehicleTypes()) do
		if SpecializationUtil.hasSpecialization(Motorized, typeEntry.specializations) then
			g_vehicleTypeManager:addSpecialization(typeName, "BPG_DriveDistance")
			numVehT = numVehT + 1
		end
	end
	print(" ++ loading DriveDistance V "..tostring(registerDriveDistance.version).." for "..tostring(numVehT).." motorized Vehicletypes")
end
