-- 
-- Drive distance for vehicles for FS17
-- by Blacky_BPG
-- 
-- Version: 1.9.0.2      |    23.11.2019    correct display for total distance in use with TSX EnhancedVehicle mod, remove decimal for total distance, colorize decimal for trip distance
-- Version: 1.9.0.1      |    11.11.2019    initial version for FS19
-- Version: 1.5.3.1      |    28.03.2018    fixed override function for GUI element 
-- Version: 1.4.4.0 D    |    15.03.2017    fixed multiplayer functionality
-- Version: 1.4.4.0 C    |    13.03.2017    fixed multiplayer functionality
-- Version: 1.4.4.0 B    |    12.03.2017    fixed savegame detection
-- Version: 1.4.4.0 A    |    12.03.2017    fixed variable error
-- Version: 1.4.4.0      |    09.03.2017    initial Version for FS17
-- 


BPG_DriveDistance = {}
BPG_DriveDistance.modDir = g_currentModDirectory

function BPG_DriveDistance.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(Motorized, specializations)
end

function BPG_DriveDistance.registerFunctions(vehicleType)
	SpecializationUtil.registerFunction(vehicleType, "add_DriveDistance", BPG_DriveDistance.add_DriveDistance)
end

function BPG_DriveDistance.registerEventListeners(vehicleType)
	local specFunctions = {	"onPostLoad", "onLoad", "onUpdate", "onUpdateTick", "onDraw", "onReadStream", "onWriteStream", "onReadUpdateStream", "onWriteUpdateStream" }
	
	for _, specFunction in ipairs(specFunctions) do
		SpecializationUtil.registerEventListener(vehicleType, specFunction, BPG_DriveDistance)
	end
end

function BPG_DriveDistance:onPostLoad(savegame)
	local spec = self.spec_BPG_DriveDistance
	spec.textSizeS = g_currentMission.inGameMenu.hud.speedMeter.speedUnitTextSize*0.70
	spec.textSizeL = g_currentMission.inGameMenu.hud.speedMeter.speedUnitTextSize*0.85
	spec.textWidth = getTextWidth(spec.textSizeS, "l")
	if g_gameSettings:getValue("useMiles") == true then
		spec.distanceText = "mi"
		spec.distanceFactor = "62.1371192237334"
	else
		spec.distanceText = "km"
		spec.distanceFactor = "100"
	end

	local distance = spec.driveDistanceOverall
	if savegame ~= nil then
		distance = Utils.getNoNil(getXMLFloat(savegame.xmlFile, savegame.key..".BPG_DriveDistance#drivenDistance"),  distance)
	end
	spec.driveDistanceOverall = distance
	self:add_DriveDistance(0,distance)
end

function BPG_DriveDistance:onLoad(savegame)
	local spec = self.spec_BPG_DriveDistance
	spec.driveDistanceToday = 0
	spec.driveDistanceOverall = 0

	spec.sendTimer = 0
end

function BPG_DriveDistance:saveToXMLFile(xmlFile, key)
	local spec = self.spec_BPG_DriveDistance
	setXMLFloat(xmlFile, key.."#drivenDistance", spec.driveDistanceOverall)
end

function BPG_DriveDistance:onReadStream(streamId, connection)
	local spec = self.spec_BPG_DriveDistance
	spec.driveDistanceToday = streamReadFloat32(streamId)
	spec.driveDistanceOverall = streamReadFloat32(streamId)
	self:add_DriveDistance(spec.driveDistanceToday,spec.driveDistanceOverall)
end

function BPG_DriveDistance:onWriteStream(streamId, connection)
	local spec = self.spec_BPG_DriveDistance
	streamWriteFloat32(streamId, spec.driveDistanceToday)
	streamWriteFloat32(streamId, spec.driveDistanceOverall)
end

function BPG_DriveDistance:onReadUpdateStream(streamId, timestamp, connection)
	if connection.isServer then
		local spec = self.spec_BPG_DriveDistance
		spec.driveDistanceToday = streamReadFloat32(streamId)
		spec.driveDistanceOverall = streamReadFloat32(streamId)
		self:add_DriveDistance(spec.driveDistanceToday,spec.driveDistanceOverall)
	end
end

function BPG_DriveDistance:onWriteUpdateStream(streamId, connection, dirtyMask)
	if not connection.isServer then
		local spec = self.spec_BPG_DriveDistance
		streamWriteFloat32(streamId, spec.driveDistanceToday)
		streamWriteFloat32(streamId, spec.driveDistanceOverall)
	end
end


function BPG_DriveDistance:onUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
	local spec = self.spec_BPG_DriveDistance
	if self:getIsActive() or self:getIsAIActive() then
		local lmD = Utils.getNoNil(self.lastMovedDistance,0)*0.001
		spec.driveDistanceToday = spec.driveDistanceToday + lmD
		spec.driveDistanceOverall = spec.driveDistanceOverall + lmD
		if self:getIsAIActive() then
			if self.lastMovedDistance > 0 then
				g_currentMission:farmStats(self:getOwnerFarmId()):updateStats("traveledDistance", lmD)
			end
		end
	end
end

function BPG_DriveDistance:onUpdateTick(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
	local spec = self.spec_BPG_DriveDistance
	if self:getIsActive() or self:getIsAIActive() then
		if self.lastMovedDistance ~= nil and self.lastMovedDistance > 0 then
			self:add_DriveDistance(spec.driveDistanceToday, spec.driveDistanceOverall)
		end
	end
end

function BPG_DriveDistance:onDraw(isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
	local spec = self.spec_BPG_DriveDistance
	if self.spec_enterable.isEntered then
		local offsetX = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX
		local totalOffsetY = g_currentMission.inGameMenu.hud.speedMeter.origY + g_currentMission.inGameMenu.hud.speedMeter.speedTextOffsetY + g_currentMission.inGameMenu.hud.speedMeter.speedTextSize + (g_currentMission.inGameMenu.hud.speedMeter.speedTextSize/7.5)

		local tripFront = math.floor(spec.driveDistanceToday)
		local tripBack = math.floor((spec.driveDistanceToday-tripFront)*100)
		if tripBack < 10 then
			tripBack = "0"..tripBack
		end
		tripFront = "Trip "..tostring(tripFront).."."
		tripBack = tripBack.." "..spec.distanceText
		local tripWidth = getTextWidth(spec.textSizeL, tripFront..tripBack) / 2

		setTextAlignment(RenderText.ALIGN_LEFT)
		renderText(offsetX-tripWidth,0.014775,spec.textSizeL,tripFront)
		setTextAlignment(RenderText.ALIGN_RIGHT)
		setTextColor(0.9,0.35,0.35,1)
		renderText(offsetX+tripWidth,0.014775,spec.textSizeL,tripBack)
		setTextColor(1,1,1,1)
		renderText(offsetX+tripWidth,0.014775,spec.textSizeL,spec.distanceText)
		setTextBold(true)
		setTextAlignment(RenderText.ALIGN_CENTER)
		if g_modIsLoaded.TSX_EnhancedVehicle ~= nil then
			renderText(offsetX+spec.textWidth,totalOffsetY,spec.textSizeS,string.format("%.0f", tostring(math.floor(spec.driveDistanceOverall*spec.distanceFactor)/100)).." "..spec.distanceText)
		else
			renderText(offsetX,totalOffsetY,spec.textSizeL,string.format("%.0f", tostring(math.floor(spec.driveDistanceOverall*spec.distanceFactor)/100)).." "..spec.distanceText)
		end
		setTextBold(false)
	end
end

function BPG_DriveDistance:add_DriveDistance(today, overall, noEventSend)
	local spec = self.spec_BPG_DriveDistance
	if today == nil then today = spec.driveDistanceToday end
	if overall == nil then overall = spec.driveDistanceOverall end
	if spec.sendTimer == 0 then
		spec.sendTimer = math.random(115,130)
		BPG_DriveDistanceEvent.sendEvent(self, today, overall, noEventSend)
	else
		spec.sendTimer = spec.sendTimer - 1
	end
end

-----------------------------------------------------------------------

BPG_DriveDistanceEvent = {}
BPG_DriveDistanceEvent_mt = Class(BPG_DriveDistanceEvent, Event)

InitEventClass(BPG_DriveDistanceEvent, "BPG_DriveDistanceEvent")

function BPG_DriveDistanceEvent:emptyNew()
    local self = Event:new(BPG_DriveDistanceEvent_mt)
    self.className="BPG_DriveDistanceEvent"
    return self
end

function BPG_DriveDistanceEvent:new(vehicle, today, overall)
	local self = BPG_DriveDistanceEvent:emptyNew()
	self.vehicle = vehicle
	self.today = today
	self.overall = overall
	return self
end

function BPG_DriveDistanceEvent:readStream(streamId, connection)
	self.vehicle = NetworkUtil.readNodeObject(streamId)
	self.today = streamReadFloat32(streamId)
	self.overall = streamReadFloat32(streamId)
	self:run(connection)
end

function BPG_DriveDistanceEvent:writeStream(streamId, connection)
	NetworkUtil.writeNodeObject(streamId, self.vehicle)
	streamWriteFloat32(streamId, self.today)
	streamWriteFloat32(streamId, self.overall)
end

function BPG_DriveDistanceEvent:run(connection)
	if self.vehicle ~= nil then
		if self.vehicle.add_DriveDistance ~= nil then
			self.vehicle:add_DriveDistance(self.today, self.overall, true)
		end
		if not connection:getIsServer() then
			g_server:broadcastEvent(BPG_DriveDistanceEvent:new(self.vehicle, self.today, self.overall), nil, connection, self.vehicle)
		end
	end
end

function BPG_DriveDistanceEvent.sendEvent(vehicle, today, overall, noEventSend)
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(BPG_DriveDistanceEvent:new(vehicle, today, overall), nil, nil, vehicle)
		else
			g_client:getServerConnection():sendEvent(BPG_DriveDistanceEvent:new(vehicle, today, overall))
		end
	end
end
