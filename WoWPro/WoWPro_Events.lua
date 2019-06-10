--------------------------
--  WoWPro_Events.lua   --
--------------------------

local L = WoWPro_Locale

-- Are we ready to roll?
function WoWPro.Ready(who)
	if not WoWProDB.char.currentguide then
	    WoWPro:dbp("%s not Ready. No current guide!",(who or "Someone"))
	    return false
	end
	if not WoWPro.Guides[WoWProDB.char.currentguide] then
	    WoWPro:dbp("%s not Ready. Current guide invalid!",(who or "Someone"))
	    return false
	end
	if not WoWPro.GuideLoaded then
	    WoWPro:dbp("%s not Ready. Guide %s is not loaded yet!",(who or "Someone"), tostring(WoWProDB.char.currentguide))
        return false
	end
	return true
end

-- Remeber Taxi Locations
function WoWPro:RecordTaxiLocations(...)
    local _event = ...
    local index = WoWPro.rows[1].index
    for i = 1, NumTaxiNodes() do
        local nomen = TaxiNodeName(i)
        local typo = TaxiNodeGetType(i)
        local location,zone = string.split(",",nomen)
        if (typo ~= "NONE" and typo ~= "DISTANT") and not WoWProCharDB.Taxi[location] then
            WoWProCharDB.Taxi[location] = true
            WoWPro:Print("Discovered Flight Point: [%s]",location )
        end
---        if WoWProCharDB.Taxi[location] and typo == "DISTANT" then
---            WoWProCharDB.Taxi[location] = nil
---            WoWPro:Print("Removed Unlearned Flight Point: [%s]",location)
---        end
    end
	WoWPro:dbp("RecordTaxiLocations(%s): Step %s/%d [%s]?", tostring(_event), tostring(WoWPro.action[index]), index, tostring(WoWPro.step[index]))
	if (WoWPro.action[index] == 'f') and WoWProCharDB.Taxi[WoWPro.step[index]] then
		WoWPro.CompleteStep(index, "RecordTaxiLocations")
	end
end

-- Auto-Complete: Use flight point --
function WoWPro.TakeTaxi(index,destination)
    -- As of 8.1.0.28833, we need to know where we are to know where we can go.
    local x,y,mapId = WoWPro:GetPlayerZonePosition()
    if not mapId then
        WoWPro:Warning("Unable to find flight point to: [%s]. Where am I?",destination)
        return
    end

    local taxiNodes = C_TaxiMap.GetAllTaxiNodes(mapId)
    for i, taxiNodeData in ipairs(taxiNodes) do
        -- nodeID=1613, slotIndex=1, type=3, x=0.34, y=0.53, name="Azurewing Repose, Azuna"
        local location,zone = string.split(",", taxiNodeData.name)
        if strfind(location, destination,1,true) or (taxiNodeData.name == destination) then
            if taxiNodeData.state ~= Enum.FlightPathState.Reachable then
                WoWPro:Warning("Flight point [%s] is not reachable (%d)", location, taxiNodeData.state)
                return
            end
            WoWPro:Print("Taking flight to: [%s]",location)
            if IsMounted() then
                Dismount()
            end
            TakeTaxiNode(taxiNodeData.slotIndex)
            -- wait till we see PLAYER_CONTROL_LOST and UnitOnTaxi("player") to complete this step.
            return
        end
    end
    WoWPro:Warning("Unable to find flight point to: [%s]",destination)
end

-- Auto-Complete: Get flight point --
function WoWPro:AutoCompleteGetFP(...)
    local _event, _idx, msg = ...
	local index = WoWPro.rows[1].index
	WoWPro:dbp("AutoCompleteGetFP(%s,%s,%s): Step %s/%d [%s]?", tostring(_event), tostring(_idx), msg, tostring(WoWPro.action[index]), index, tostring(WoWPro.step[index]))
	if msg == ERR_NEWTAXIPATH and WoWPro.action[index] == "f"
	and not WoWProCharDB.Guide[WoWProDB.char.currentguide].completion[index] then
		WoWPro.CompleteStep(index, "AutoCompleteGetFP")
	end
end

function WoWPro:CheckPlayerForBuffs(buffs)
	local buffies = {}
    local buffIdx
    for buffIdx = 1, select("#",string.split(";",buffs)) do
        local buff = select(buffIdx,string.split(";",buffs))
        buffies[buffIdx] = tonumber(buff)
    end
    local BuffIndex = 1
    local BuffName, _, _, _, _, _, _, _, _, BuffSpellId = UnitBuff("player",BuffIndex)
    while BuffName do
        for buffIdx = 1, #buffies do
            if BuffSpellId == buffies[buffIdx] then
                return BuffSpellId
            end
        end
        BuffIndex = BuffIndex + 1
        BuffName, _, _, _, _, _, _, _, _, BuffSpellId = UnitBuff("player",BuffIndex)
    end
    return nil
end

-- Auto-Complete: Do we have a buff? --
function WoWPro.AutoCompleteBuff(unit,...)
    if unit ~= "player" then return end
	for i = 1,15 do
		local index = WoWPro.rows[i].index
		if WoWPro.buff and WoWPro.buff[index] and  WoWPro:CheckPlayerForBuffs(WoWPro.buff[index]) then
		    -- Log only the usefull ones!
		    WoWPro:LogEvent("UNIT_AURA", unit, ...)
		    WoWPro.CompleteStep(index, "AutoCompleteBuff")
		end
	end
end


-- Update Item Tracking --
function WoWPro.GetLootTrackingInfo(lootitem,lootqty)
--[[Purpose: Creates a string containing:
	- tracked item's name
	- how many the user has
	- how many the user needs
	- a complete symbol if the ammount the user has is equal to the ammount they need
]]
	if not GetItemInfo(lootitem) then return "" end
	local track = "" 												--If the function did have a track string, adds a newline
	track = track.." - "..GetItemInfo(lootitem)..": " 	--Adds the item's name to the string
	numinbag = GetItemCount(lootitem)		--Finds the number in the bag, and adds a count if supplied
	track = track..numinbag										--Adds the number in bag to the string
	track = track.."/"..lootqty								--Adds the total number needed to the string
	if lootqty == numinbag then
		track = track.." (C)"									--If the user has the requisite number of items, adds a complete marker
	end
	return track													--Returns the track string to the calling function
end

-- Auto-Complete: Loot based --
function WoWPro.AutoCompleteLoot()
	for i = 1,1+WoWPro.ActiveStickyCount do
	    local lootqtyi
		local index = WoWPro.rows[i].index
		if WoWPro.lootitem[index] then
    		if tonumber(WoWPro.lootqty[index]) ~= nil then lootqtyi = tonumber(WoWPro.lootqty[index]) else lootqtyi = 1 end
    		if WoWProDB.profile.track then
    			local track = WoWPro.GetLootTrackingInfo(WoWPro.lootitem[index],lootqtyi)
    			WoWPro.rows[i].track:SetText(strtrim(track))
    			WoWPro:dbp("AutoCompleteLoot: Update tracking text to %s",track)
    		end
    		local itemCount = GetItemCount(WoWPro.lootitem[index])
    		if itemCount >= lootqtyi and not WoWProCharDB.Guide[WoWProDB.char.currentguide].completion[index] then
    		    WoWPro:dbp("AutoCompleteLoot: Time to complete step.")
    			WoWPro.CompleteStep(index,"AutoCompleteLoot")
    		else
    			WoWPro:dbp("AutoCompleteLoot: Not enough yet!")
    		end
    	end
	end
	WoWPro:UpdateGuide("WoWPro.AutoCompleteLoot")
end

-- Save Garrison Building Locations for the BUILDING tag
function WoWPro.SaveGarrisonBuildings()
    local zone, mapId = WoWPro.GetZoneText()
    -- NOTE:  This wont work right on non EnUS clients!  Use mapIds.
    if (zone == 'Lunarfall') or (zone == 'Frostwall') then
        WoWProCharDB.BuildingLocations = WoWProCharDB.BuildingLocations or {}
        -- We just moved into the zone
        local numPOIs = GetNumMapLandmarks();
        for i=2, numPOIs do
            local landmarkType, name, description, textureIndex, x, y, mapLinkID, inBattleMap, graveyardID, areaID, poiID, isObjectIcon, atlasIcon
            if WoWPro.WOL then
                landmarkType, name, description, textureIndex, x, y, mapLinkID, inBattleMap, graveyardID, areaID, poiID, isObjectIcon, atlasIcon = GetMapLandmarkInfo(i)
            else
                name, description, textureIndex, x, y, mapLinkID, inBattleMap, graveyardID, areaID, poiID, isObjectIcon, atlasIcon = GetMapLandmarkInfo(i)
            end
            WoWProCharDB.BuildingLocations[name] = {x=(100*x), y=(100*y)}
            WoWPro:dbp("Building %s @ %g,%g", name, 100*x, 100*y)
        end
    end
end


-- Auto-Complete: Quest Update --
function WoWPro:AutoCompleteQuestUpdate(questComplete)
	local GID = WoWProDB.char.currentguide
	if not GID or not WoWPro.Guides[GID] then return end
	if not WoWProCharDB.Guide then return end
	if not WoWProCharDB.Guide[GID] then return end
	if not WoWProCharDB.Guide[GID].completion then return end

    WoWPro:dbp("Running: AutoCompleteQuestUpdate(questComplete=%s)",tostring(questComplete))

	for i=1,#WoWPro.action do
		local action = WoWPro.action[i]
		local completion = WoWProCharDB.Guide[GID].completion[i]

		if WoWPro.QID[i] then
			local numQIDs = select("#", string.split("^&", WoWPro.QID[i]))
			for j=1,numQIDs do
				local QID = select(numQIDs-j+1, string.split("^&", WoWPro.QID[i]))
				if not tonumber(QID) then
				    WoWPro:Error("Bad QID [%s] in Guide %s", WoWPro.QID[i], GID)
				    return
				end
				QID = tonumber(QID)

		        -- Quest Turn-Ins --
		        if WoWPro.CompletingQuest and action == "T" and not completion and WoWPro.missingQuest == QID then
			        WoWPro.CompleteStep(i,"AutoCompleteQuestUpdate: quest turn-in.")
			        WoWProCharDB.completedQIDs[QID] = true
			        WoWPro.CompletingQuest = false
			        WoWPro.missingQuest = nil  -- We got it, dont let the recorder get it!
		        end
		
		        -- Abandoned Quests --
		        if not WoWPro.CompletingQuest and ( action == "A" or action == "C" ) 
		        and completion and WoWPro.missingQuest == QID then
			        WoWProCharDB.Guide[GID].completion[i] = nil
			        WoWPro:UpdateGuide("ACQU: Abandoned Quest")
		        end
		
                -- Quest AutoComplete --
                if questComplete and (action == "A" or action == "C" or action == "T" or action == "N") and QID == questComplete then
                    WoWPro.CompleteStep(i, "AutoCompleteQuestUpdate: AutoComplete")
                end
		        -- Quest Accepts --
		        if WoWPro.newQuest == QID and action == "A" and not completion then
			        WoWPro.CompleteStep(i, "AutoCompleteQuestUpdate: Accept")
			        WoWPro.newQuest = nil -- We got it, dont let the recorder get it!
		        end
		
		        -- Quest Completion via QuestLog--
		        if WoWPro.QuestLog[QID] and action == "C" and not completion and WoWPro.QuestLog[QID].complete then
			        WoWPro.CompleteStep(i, "AutoCompleteQuestUpdate: via QuestLog")
			        WoWPro.oldQuests[QID] = WoWPro.oldQuests[QID] or {}
			        WoWPro.oldQuests[QID].complete = true -- We got it, dont let the recorder get it!
		        end
		
		        -- Partial Completion --
		        if WoWPro.QuestLog[QID] and WoWPro.QuestLog[QID].leaderBoard and WoWPro.questtext[i] 
		        and not WoWProCharDB.Guide[GID].completion[i] then 
			        local numquesttext = select("#", string.split(";", WoWPro.questtext[i]))
			        local complete = true
			        for l=1,numquesttext do
				        local lquesttext = select(numquesttext-l+1, string.split(";", WoWPro.questtext[i]))
				        local lcomplete = false
				        if WoWPro.ValidObjective(lquesttext) then
				            lcomplete = WoWPro.QuestObjectiveStatus(qid, lquesttext)
    				    end
				        if not lcomplete then complete = false end --if one of the listed objectives isn't complete, then the step is not complete.
			        end
			        if complete then
			            --if the step has been found to be complete, run the completion function
			            WoWPro.CompleteStep(i, "AutoCompleteQuestUpdate: complete")
			        end 
		        end
		    end
		end		
	end
	
	-- First Map Point --
	if WoWPro.FirstMapCall then
		WoWPro:MapPoint()
		WoWPro.FirstMapCall = false
	end
	
end

			
-- Auto-Complete: Set hearth --
function WoWPro:AutoCompleteSetHearth(...)
	local msg = ...
	local _, _, loc = msg:find(L["(.*) is now your home."])
	if loc then
		WoWProCharDB.Guide.hearth = loc
		for i = 1,15 do
			local index = WoWPro.rows[i].index
			if WoWPro.action[index] == "h" and WoWPro.step[index] == loc 
			and not WoWProCharDB.Guide[WoWProDB.char.currentguide].completion[index] then
				WoWPro.CompleteStep(index, "AutoCompleteSetHearth")
			end
		end
	end	
end

-- Auto-Complete: Zone based --
function WoWPro.AutoCompleteZone()
	WoWPro.ActiveStickyCount = WoWPro.ActiveStickyCount or 0
	local currentindex = WoWPro.rows[1+WoWPro.ActiveStickyCount].index
	local action = WoWPro.action[currentindex] or "?"
	local step = WoWPro.step[currentindex] or "?"
	local targetzone = WoWPro.targetzone[currentindex] or "!"
	local zonetext, subzonetext = GetZoneText(), string.trim(GetSubZoneText())
	WoWPro:dbp("AutoCompleteZone: [%s] or [%s] .vs. %s [%s]", zonetext, subzonetext, action, step)
	if action == "F" or action == "H" or action == "b" or action == "P" or action == "R" then
		if ((step == zonetext) or (step == subzonetext) or (targetzone == zonetext) or (targetzone == subzonetext))
		and not WoWProCharDB.Guide[WoWProDB.char.currentguide].completion[currentindex] then
			WoWPro.CompleteStep(currentindex,"AutoCompleteZone")
		end
	end
end

-- Auto-Complete: Criteria Change from RegisterBucketEvent(CRITERIA_UPDATE)
function WoWPro.AutoCompleteCriteria()
    if not WoWProDB.char.currentguide then return end

	local qidx = WoWPro.rows[WoWPro.ActiveStickyCount+1].index
	local GID = WoWProDB.char.currentguide
	if WoWPro.QID[qidx] and WoWPro:IsQuestFlaggedCompleted(WoWPro.QID[qidx],true) then
	    WoWPro.CompleteStep(qidx,"AutoCompleteCriteria-Quest")
	else
	    WoWPro:UpdateGuide("WoWPro.AutoCompleteCriteria?")
	end
end

-- Auto-Complete: Chest Loot, for the silly timeless isle chests
function WoWPro.AutoCompleteChest()
    if not WoWProDB.char.currentguide then return end
    local zone, map = WoWPro.GetZoneText()
    if zone == "Timeless Isle" then
	local qidx = WoWPro.rows[WoWPro.ActiveStickyCount+1].index
	local GID = WoWProDB.char.currentguide
	if WoWPro.QID[qidx] and WoWPro:IsQuestFlaggedCompleted(WoWPro.QID[qidx],true) then
	        WoWPro.CompleteStep(qidx,"AutoCompleteChest")
	end
    end
end

-- Auto-Complete: Level based --
function WoWPro:AutoCompleteLevel(...)
	local newlevel = ... or UnitLevel("player")
	if WoWProCharDB.Guide then
		local GID = WoWProDB.char.currentguide
		if not WoWProCharDB.Guide[GID] then return end
		for i=1,WoWPro.stepcount do
			if not WoWProCharDB.Guide[GID].completion[i]
				and WoWPro.level[i]
				and tonumber(WoWPro.level[i]) <= newlevel then
					WoWPro.CompleteStep(i,"AutoCompleteLevel")
			end
		end
	end
end

WoWPro.InitLockdownEvents = {}
WoWPro.InitLockdownEvents["ADDON_ACTION_FORBIDDEN"] = true
WoWPro.InitLockdownEvents["ADDON_ACTION_BLOCKED"] = true
WoWPro.InitLockdownEvents["PLAYER_ENTERING_WORLD"] = true
WoWPro.InitLockdownEvents["PLAYER_LEAVING_WORLD"] = true

function WoWPro.RegisterEventHandler(event, handler)
	WoWPro.EventTable[event] = true
	WoWPro[event] = handler
end

function WoWPro.RegisterModernEventHandler(event, handler)
    if WoWPro.CLASSIC then return end
	WoWPro.EventTable[event] = true
	WoWPro[event] = handler
end


WoWPro.RegisterEventHandler("UNIT_AURA", function (event, ...)
    if not WoWPro.MaybeCombatLockdown() then
        WoWPro.AutoCompleteBuff(...)
    end
    end)

WoWPro.RegisterModernEventHandler("UNIT_AURA", function (event, ...)
    if not WoWPro.MaybeCombatLockdown() then
        WoWPro.AutoCompleteBuff(...)
    end
    end)

-- Naughty People!
WoWPro.RegisterEventHandler("ADDON_ACTION_FORBIDDEN", function (event,...)
    -- Its has been logged by LogEvent, so just return
    return
    end)
WoWPro.RegisterEventHandler("ADDON_ACTION_BLOCKED", WoWPro.ADDON_ACTION_FORBIDDEN)
WoWPro.RegisterEventHandler("SAVED_VARIABLES_TOO_LARGE", function (event) return; end)
WoWPro.RegisterEventHandler("ADDON_LOADED", function (event) return; end)
WoWPro.RegisterEventHandler("SPELLS_CHANGED", function (event) return; end)
WoWPro.RegisterEventHandler("PLAYER_LOGIN", function (event) return; end)
WoWPro.RegisterEventHandler("VARIABLES_LOADED", function (event) return; end)

-- Unlocking event processing after things get settled --
WoWPro.RegisterEventHandler("PLAYER_ENTERING_WORLD", function (event,...)
    WoWPro:print("Setting Timer PEW")
    WoWPro.InitLockdown = true
    WoWPro.LockdownCounter = 5  -- times until release and give up to wait for other addons
    WoWPro.LockdownTimer = 1.5
    -- WoWPro.ZONE_CHANGED_NEW_AREA("ZONE_CHANGED_NEW_AREA")
    if WoWPro.Hidden == "PLAYER_ENTERING_BATTLEGROUND" then
        WoWPro:Print("|cff33ff33Battleground Exit Auto Show|r: %s Module", guidetype)
		WoWPro.MainFrame:Show()
		WoWPro.Titlebar:Show()
		WoWPro.Hidden = nil
	end
	WoWPro:UpdateTradeSkills()
    end)

-- Locking event processong till after things get settled --
WoWPro.RegisterEventHandler("PLAYER_LEAVING_WORLD", function (event,...)
    WoWPro:print("Locking Down PLW")
    WoWPro.InitLockdown = true
    end)

-- Check to see if the current zone is mapped properly.
WoWPro.RegisterEventHandler("ZONE_CHANGED", function (event,...)
    WoWPro.CheckHBDData()
    WoWPro.SaveGarrisonBuildings()
    -- Noticing if we have entered a Dungeon!
	if event == "ZONE_CHANGED_NEW_AREA" and WoWProCharDB.AutoHideInsideInstances == true then
	    local qidx = WoWPro.rows[WoWPro.ActiveStickyCount+1].index
	    local guidetype = "WoWPro"
	    if WoWProDB.char.currentguide and WoWPro.Guides[WoWProDB.char.currentguide] then
	        guidetype = WoWPro.Guides[WoWProDB.char.currentguide].guidetype
	    end
	    if WoWPro.zone[qidx] and (WoWPro:IsInstanceZone(WoWPro.zone[qidx]) or WoWPro.sobjective[qidx]) and IsInInstance() then
	        WoWPro:Print("|cff33ff33 Suppressing Instance Auto Hide, turn it on after you are done with this guide.|r")
	        WoWProCharDB.AutoHideWorldEventsInsideInstances = false
	        return
	    end
		if IsInInstance() then
			WoWPro:Print("|cff33ff33Instance Auto Hide|r: %s Module",guidetype)
			WoWPro.MainFrame:Hide()
			WoWPro.Titlebar:Hide()
			WoWPro.Hidden = event
			return
		elseif WoWPro.Hidden == true then
			WoWPro:Print("|cff33ff33Instance Exit Auto Show|r: %s Module",guidetype)
			WoWPro.MainFrame:Show()
			WoWPro.Titlebar:Show()
			WoWPro.Hidden = nil
		end
	end
	if WoWPro.Ready(event) then
        WoWPro.AutoCompleteZone(...)
    end
    end)

WoWPro.RegisterEventHandler("ZONE_CHANGED_INDOORS", WoWPro.ZONE_CHANGED)
WoWPro.RegisterEventHandler("ZONE_CHANGED_NEW_AREA", WoWPro.ZONE_CHANGED)

-- Scenario Tracking
WoWPro.RegisterModernEventHandler("SCENARIO_UPDATE", function (event,...)
    WoWPro.ProcessScenarioStage(...)
    WoWPro:UpdateGuide(event)
    end)

WoWPro.RegisterModernEventHandler("SCENARIO_CRITERIA_UPDATE", function (event,...)
    WoWPro.ProcessScenarioCriteria(false)
    WoWPro:UpdateGuide(event)
    end)

WoWPro.RegisterModernEventHandler("CRITERIA_COMPLETE",WoWPro.SCENARIO_CRITERIA_UPDATE)


-- Noticing if we are doing a pet battle!
WoWPro.RegisterModernEventHandler("PET_BATTLE_OPENING_START", function (event,...)
	local guidetype = "WoWPro"
	local battleHide = false

	if WoWProDB.char.currentguide and WoWPro.Guides[WoWProDB.char.currentguide] and WoWPro.Guides[WoWProDB.char.currentguide].guidetype then
	    guidetype = WoWPro.Guides[WoWProDB.char.currentguide].guidetype
	    battleHide = not WoWPro.Guides[WoWProDB.char.currentguide].PetBattle
	end

    WoWPro.LastPetBattleWinner = nil
    if (not WoWPro.Hidden) and battleHide then
        WoWPro.MainFrame:Hide()
        WoWPro.Titlebar:Hide()
        WoWPro.Hidden = event
    end
	WoWPro.PetBattleActive = true
--	WoWPro.RegisterAllEvents()
    end)

WoWPro.RegisterModernEventHandler("PET_BATTLE_PET_ROUND_RESULTS", function (event,...)
    WoWPro:UpdateGuide(event)
    end)

WoWPro.RegisterModernEventHandler("PET_BATTLE_PET_CHANGED", function (event,team)
    local qidx = WoWPro.rows[WoWPro.ActiveStickyCount+1].index
    if team == 1 and WoWPro.switch and WoWPro.switch[qidx] == 0 then
        -- Waiting for forced swap.
        WoWPro.CompleteStep(qidx,"Forced Swap")
    end
    end)


WoWPro.RegisterModernEventHandler("PET_BATTLE_FINAL_ROUND", function (event,...)
    local qidx = WoWPro.rows[WoWPro.ActiveStickyCount+1].index
    local winner = ...
    WoWPro.ProcessFinalRound(winner, qidx)
    end)

WoWPro.RegisterModernEventHandler("PET_BATTLE_OVER", function (event,...) return; end)

WoWPro.RegisterModernEventHandler("PET_BATTLE_CLOSE", function (event,...)
    if WoWPro.Hidden then
		WoWPro.MainFrame:Show()
		WoWPro.Titlebar:Show()
		WoWPro.Hidden = nil
	end

	if not C_PetBattles.IsInBattle() then
	    WoWPro.PetBattleActive = false
	    WoWPro:dbp("C_PetBattles.IsInBattle() = false")
	else
	    WoWPro:dbp("C_PetBattles.IsInBattle() = true")
	    return
	end
	if WoWPro.current_strategy == false then
	    WoWPro.current_strategy = nil
	    WoWPro:dbp("WoWPro.current_strategy = nil")
	end
	WoWPro:UpdateGuide(event)
--	WoWPro.UnregisterAllEvents()
--	WoWPro:RegisterEvents()
    end)


WoWPro.RegisterEventHandler("PLAYER_ENTERING_BATTLEGROUND", function (event,...)
    WoWPro:Print("|cff33ff33Battleground Auto Hide|r: %s Module",guidetype)
    WoWPro.MainFrame:Hide()
    WoWPro.Titlebar:Hide()
    WoWPro.Hidden = event
    end)

WoWPro.RegisterEventHandler("PLAYER_REGEN_DISABLED", function (event,...)
    -- Combat lockdown begins after this event
    if WoWProCharDB.AutoHideInCombat then
        WoWPro.MainFrame:Hide()
        WoWPro.Titlebar:Hide()
        WoWPro.Hidden = event
    end
    -- Last ditch update!
	if not WoWPro.MaybeCombatLockdown() then
		WoWPro:UpdateGuide(event)
	end
    end)

WoWPro.RegisterEventHandler("PLAYER_REGEN_ENABLED", function (event,...)
    -- Combat lockdown ends before this event fires
    if WoWPro.Hidden then
		WoWPro.MainFrame:Show()
		WoWPro.Titlebar:Show()
	end

	WoWPro:UpdateGuide(event)
    end)

WoWPro.RegisterEventHandler("UPDATE_BINDINGS", WoWPro.PLAYER_REGEN_ENABLED)
-- WoWPro.RegisterEventHandler("PARTY_MEMBERS_CHANGED", WoWPro.PLAYER_REGEN_ENABLED)

-- Merchant?
WoWPro.RegisterEventHandler("MERCHANT_SHOW" , function (event,...)
    local qidx = WoWPro.rows[WoWPro.ActiveStickyCount+1].index
    if CanMerchantRepair() and WoWPro.action[qidx] == "r" then
        WoWPro.CompleteStep(qidx,"Talked to Repairing Merchant")
    end
    end)

-- Lets see what quests the NPC has:
WoWPro.RegisterEventHandler("GOSSIP_SHOW" , function (event,...)
    if not WoWPro.QuestDialogActive then
        WoWPro.RegisterAllEvents()
        WoWPro.QuestCount = 0
        WoWPro.QuestDialogActive = event
        C_Timer.After(WoWProDB.global.QuestEngineDelay, function() WoWPro.GOSSIP_SHOW_PUNTED(event.."PUNTED"); end)
    else
        WoWPro:print("GOSSIP_SHOW while %s was active: suppressed.", WoWPro.QuestDialogActive)
    end
    end)

function WoWPro.GOSSIP_SHOW_PUNTED(event,...)
    WoWPro.GossipText = strupper(GetGossipText())
    WoWPro:print("GetGossipText: %s",WoWPro.GossipText)

    local qidx = WoWPro.rows[WoWPro.ActiveStickyCount+1].index
    local myNPC = WoWPro:TargetNpcId()

    if not qidx then
        WoWPro:print("%s: No active step.", event)
        return
    end

    local npcCount = GetNumGossipActiveQuests();
    local npcQuests =  {GetGossipActiveQuests()};
    WoWPro:print("%s: ActiveQuests npcCount=%d", event, npcCount)
    if WoWProCharDB.AutoTurnin then
        WoWPro.QuestCount = npcCount
        for index=1,npcCount do
            -- name, level, isTrivial, isComplete, isLegendary, isIgnored
            local name = npcQuests[((index-1)*6)+1]
            WoWPro:print("%s: considering turnin %d for [%s] .vs. [%s]", event, index, name, tostring(WoWPro.step[qidx]))
	        if WoWPro.action[qidx] == "T" and name == WoWPro.step[qidx] then
	            WoWPro.QuestStep = qidx
	            SelectGossipActiveQuest(index)
	            WoWPro:print("%s: selected turnin %d for [%s]", event, index, name)
	            return
	        end
        end
        WoWPro.QuestCount = 0
    end

    local npcQuests = {GetGossipAvailableQuests()};
    local npcCount = GetNumGossipAvailableQuests();
    index = 0
    WoWPro:print("%s: AvailableQuests npcCount=%d", event, npcCount)
    if WoWProCharDB.AutoSelect then
        WoWPro.QuestCount = npcCount
        for index=1,npcCount do
            -- titleText, level, isTrivial, frequency, isRepeatable, isLegendary, isIgnored
            local name = npcQuests[((index-1)*7)+1]
            WoWPro:dbp("ZT: %s index %d/%d, considering [%s]",event,index,npcCount,name)
            if WoWPro.action[qidx] == "A" then
		        if WoWPro.QID[qidx] == "*" and WoWPro.NPC[qidx] and tonumber(WoWPro.NPC[qidx]) == myNPC then
		            WoWPro:dbp("ZZZT %d: %s Inhale %s, prev qcount was %d, new is %d",qidx, event,name, WoWPro.QuestCount, npcCount)
		            WoWPro.QuestStep = qidx
		            SelectGossipAvailableQuest(index)
		            return
		        end
		        if WoWPro.action[qidx] == "A" and name == WoWPro.step[qidx] then
		            WoWPro:dbp("ZZZT %d: %s Name matches [%s], selecting.",index,event,name)
		            SelectGossipAvailableQuest(index)
		            return
		        end
		    end
        end
        WoWPro.QuestCount = 0
    end

	if WoWPro.gossip and WoWPro.GossipText and WoWPro.gossip[qidx] then
		WoWPro:UpdateGuide(event)
	end
end

WoWPro.RegisterEventHandler("GOSSIP_CLOSED" ,function (event,...)
    WoWPro.GossipText = nil
    WoWPro.QuestDialogActive = nil
    WoWPro.UnregisterAllEvents()
    WoWPro:RegisterEvents()
    end)

WoWPro.RegisterEventHandler("QUEST_GREETING", function (event,...)
    WoWPro.QuestDialogActive = event
    WoWPro.RegisterAllEvents()
    C_Timer.After(WoWProDB.global.QuestEngineDelay, function()
        WoWPro.QUEST_GREETING_PUNTED(event.."_PUNTED")
        end)
    end)

WoWPro.RegisterEventHandler("QUEST_FINISHED", function (event,...)
    WoWPro.QuestDialogActive = nil
    WoWPro.QuestCount = nil
    WoWPro.QuestStep = nil
    WoWPro.UnregisterAllEvents()
    WoWPro.RegisterEvents()
    end)

function WoWPro.QUEST_GREETING_PUNTED(event,...)
    local numAvailableQuests = GetNumAvailableQuests()
    local numActiveQuests = GetNumActiveQuests()
    WoWPro:print("%s: numActiveQuests=%d, numAvailableQuests=%d", event, numActiveQuests, numAvailableQuests)
    local qidx = WoWPro.rows[WoWPro.ActiveStickyCount+1].index
    local myNPC = WoWPro:TargetNpcId()

    if not qidx then
        WoWPro:print("%s: No active step.", event)
        return
    end

    if WoWProCharDB.AutoTurnin  then
        -- Match from the top down
        for i=numActiveQuests,1,-1  do
            if WoWPro.action[qidx] == "T" and GetActiveTitle(i) == WoWPro.step[qidx] then
                WoWPro.QuestStep = qidx
                WoWPro:print("Turning in [%s]",WoWPro.step[qidx])
    	        SelectActiveQuest(i)
    	        return
    	    end
    	end
    end

    if WoWProCharDB.AutoSelect then
        WoWPro.QuestCount = numAvailableQuests
        -- Match from the top down
        for i=numAvailableQuests,1,-1  do
            if WoWPro.action[qidx] == "A" then
                if WoWPro.QID[qidx] == "*" and WoWPro.NPC[qidx] and tonumber(WoWPro.NPC[qidx]) == myNPC then
                    WoWPro:dbp("ZZZT %d: %s Inhale %s, prev qcount was %d, new is %d",qidx, event, GetAvailableTitle(i), WoWPro.QuestCount, numAvailableQuests)
                    WoWPro.QuestCount = numAvailableQuests
                    WoWPro.QuestStep = qidx
    	            SelectAvailableQuest(i)
    	            WoWPro.QUEST_GREETING(event)
    	            return
                end
                -- Look forward up to #numAvailableQuests steps for A steps, so the order does not matter much.
                for j=0,numAvailableQuests-1 do
                    if GetAvailableTitle(i) == WoWPro.step[qidx+j] then
                        WoWPro.QuestStep = qidx+j
                        WoWPro:dbp("ZZZT %d: %s Name matches [%s], selecting.", i, event, WoWPro.step[WoWPro.QuestStep])
                        WoWPro.QuestCount = numAvailableQuests
        	            SelectAvailableQuest(i)
        	            return
        	        end
        	    end
    	    end
    	end
    	WoWPro.QuestCount = 0
    end
end

WoWPro.RegisterEventHandler("QUEST_DETAIL", function (event,...)
    C_Timer.After(WoWProDB.global.QuestEngineDelay, function()
        WoWPro.QUEST_DETAIL_PUNTED(event.."_PUNTED")
        end)
    end)

function WoWPro.QUEST_DETAIL_PUNTED(event,...)
    if not WoWProCharDB.AutoAccept then return; end

    local qidx = WoWPro.QuestStep
    local questtitle = GetTitleText();
    local myNPC = WoWPro:TargetNpcId()

    if not qidx then
        qidx = WoWPro.rows[WoWPro.ActiveStickyCount+1].index
        if not qidx then
            WoWPro:print("%s: No active step.", event)
            return
        end
        WoWPro:dbp("Searching for %s from %d",questtitle,qidx)
        for j=0,5 do
            if questtitle == WoWPro.step[qidx+j] then
                qidx = qidx+j
                break
            end
        end
    end

	if (WoWPro.action[qidx] == "A") and (questtitle == WoWPro.step[qidx] or WoWPro.QID[qidx] == "*" or WoWPro:QIDsInTable(WoWPro.QID[qidx],WoWPro.QuestLog)) then
	    WoWPro:dbp("Accepted %d: %s [%s], QID %s",qidx, event, questtitle,tostring(WoWPro.QID[qidx]))
	    if  WoWPro.QID[qidx] == "*" then
	        if WoWPro.NPC[qidx] and tonumber(WoWPro.NPC[qidx]) == myNPC then
		        WoWPro:dbp("ZZZT %s %d: Auto Accept wildcard [%s], %d qcount", event, qidx,questtitle,WoWPro.QuestCount)
		    else
		        WoWPro:dbp("ZZZT %s %d: Auto Accept wildcard [%s] REJECT! Expected NPC %s and found %d", event, qidx,questtitle,tostring(WoWPro.NPC[qidx]), myNPC)
		        return
		    end
	    end
	    AcceptQuest()
	    if QuestFrameDetailPanel:IsShown() then
	        HideUIPanel(QuestFrameDetailPanel)
	        QuestFrameDetailPanel:Hide();
	        QuestFrameGreetingPanel:Hide();
		    QuestFrameGreetingPanel:Show();
	    end
	    WoWPro.QuestStep = nil
	else
	    -- DeclineQuest()
	    WoWPro:dbp("Rejected %d: %s [%s], QID %s",qidx, event, questtitle,tostring(WoWPro.QID[qidx]))
	end
end

WoWPro.RegisterEventHandler("QUEST_PROGRESS", function (event,...)
    C_Timer.After(WoWProDB.global.QuestEngineDelay, function()
        WoWPro.QUEST_PROGRESS_PUNTED(event)
        end)
    end)

function WoWPro.QUEST_PROGRESS_PUNTED(event,...)
    if not WoWProCharDB.AutoTurnin then return; end

    local qidx = WoWPro.rows[WoWPro.ActiveStickyCount+1].index
    local questtitle = GetTitleText();
    WoWPro:dbp("Quest is [%s], matching [%s]",tostring(questtitle),tostring(WoWPro.step[qidx]))
	if WoWPro.action[qidx] == "T" and questtitle == WoWPro.step[qidx] then
	    CompleteQuest()
	end
end

-- Noting that a quest is being completed for AutoTurnin --
WoWPro.RegisterEventHandler("QUEST_COMPLETE", function (event,...)
    local qidx = WoWPro.rows[WoWPro.ActiveStickyCount+1].index
    local questtitle = GetTitleText();
    WoWPro:dbp("Quest is [%s], matching %s[%s]",tostring(questtitle),tostring(WoWPro.action[qidx]), tostring(WoWPro.step[qidx]))
	if WoWProCharDB.AutoTurnin == true and
	   WoWPro.action[qidx] == "T" and
	   questtitle == WoWPro.step[qidx] then
	    if (GetNumQuestChoices() <= 1) then
	        GetQuestReward(1)
	    end
    end
    -- Some quests are auto-turnin on accept
    if WoWProCharDB.AutoAccept == true and
	   WoWPro.action[qidx] == "A" and
	   questtitle == WoWPro.step[qidx] then
	    if (GetNumQuestChoices() <= 1) then
	        GetQuestReward(1)
	    end
    end
    end)

WoWPro.RegisterEventHandler("QUEST_TURNED_IN", function (event,...)
    local qid, exp, money = ...
    WoWPro:dbp("%s(qid=%d,exp=%d,money=%d)",event,qid, exp, money)
	WoWPro.CompletingQuest = true
	WoWProCharDB.completedQIDs[qid] = true
	WoWPro:AutoCompleteQuestUpdate(qid)
    end)

WoWPro.RegisterEventHandler("QUEST_ACCEPTED", function (event,...)
    local qlidx, qid = ...
    WoWPro:dbp("%s(qidx=%d,qid=%d)",event,qlidx,qid)
    local qidx = WoWPro.rows[WoWPro.ActiveStickyCount+1].index
    local questtitle = GetTitleText();
	if WoWProCharDB.AutoTurnin == true and
	   WoWPro.action[qidx] == "A" and
	   questtitle == WoWPro.step[qidx] then
	    WoWPro:AutoCompleteQuestUpdate(nil)
    end
    end)

-- scan skill lines when they change
WoWPro.RegisterEventHandler("SKILL_LINES_CHANGED", function(event, ...)
	WoWPro.UpdateTradeSkills(...)
end)

-- register newly learned recipes
WoWPro.RegisterEventHandler("NEW_RECIPE_LEARNED", function (event,...)
    WoWPro.LearnRecipe(...)
    end)

-- Auto-Completion --
WoWPro.RegisterEventHandler("TAXIMAP_OPENED", function (event,...)
	WoWPro:RecordTaxiLocations(...)
	local qidx = WoWPro.rows[WoWPro.ActiveStickyCount+1].index
	if (WoWPro.action[qidx] == "F" or WoWPro.action[qidx] == "b") and WoWProCharDB.AutoSelect == true then
        WoWPro.TakeTaxi(qidx,WoWPro.step[qidx])
	end
    end)

WoWPro.RegisterEventHandler("PLAYER_CONTROL_LOST", function (event,...)
    C_Timer.After(WoWProDB.global.QuestEngineDelay, function()
        WoWPro.PLAYER_CONTROL_LOST_PUNTED(event)
        end)
    end)

function WoWPro.PLAYER_CONTROL_LOST_PUNTED(event,...)
    local qidx = WoWPro.rows[WoWPro.ActiveStickyCount+1].index
    if (WoWPro.action[qidx] == "F" or WoWPro.action[qidx] == "b") then
        if UnitOnTaxi("player") then
            WoWPro:dbp("PLAYER_CONTROL_LOST_PUNTED: UnitOnTaxi! calling CompleteStep")
            WoWPro.CompleteStep(qidx,"Took a taxi")
        else
            WoWPro:dbp("PLAYER_CONTROL_LOST_PUNTED: not on taxi!")
        end
    end
end

WoWPro.RegisterEventHandler("CHAT_MSG_SYSTEM", function (event,...)
	WoWPro:AutoCompleteSetHearth(...)
    end)

WoWPro.RegisterEventHandler("QUEST_LOG_UPDATE", function (event,...)
	local delta = WoWPro.PopulateQuestLog()
	WoWPro:dbp("QUEST_LOG_UPDATE: delta = %d", delta)
	if delta == 0 then
	    return
	end
	if WoWPro.Ready(event) then
        WoWPro:AutoCompleteQuestUpdate(nil)
        WoWPro:UpdateGuide(event)
        if WoWProCharDB.AutoSelect and delta == 1 then
        -- OK, now get the next quest if QuestCount is set
            if WoWPro.QuestCount ~= 0 and WoWPro.QuestDialogActive then
                WoWPro:dbp("ZZZT Faking %s, QuestCount is %d", WoWPro.QuestDialogActive, WoWPro.QuestCount)
                WoWPro.DelayedEventHandler(frame,WoWPro.QuestDialogActive)
            end
        end
    end
    end)

WoWPro.RegisterEventHandler("UI_INFO_MESSAGE", function (event,...)
	WoWPro:AutoCompleteGetFP(event,...)
    end)

WoWPro.RegisterEventHandler("PLAYER_TARGET_CHANGED", function (event,...)
    WoWPro.NpcCheck(...)
    end)

function WoWPro.DelayedEventHandler(frame,event)
    C_Timer.After(WoWProDB.global.QuestEngineDelay, function ()
        WoWPro.EventHandler(frame,event)
        end)
end


function WoWPro.EventHandler(frame, event, ...)
    -- Filter out non-player UNIT_AURA events
    if event == "UNIT_AURA" then
         -- Process silently!
        WoWPro.UNIT_AURA(event, ...)
        return
    end

    -- Init Lockdown events are processed unconditionally and first.
    if WoWPro.InitLockdownEvents[event] then
        WoWPro:LogEvent("ILE:"..event,...)
        WoWPro[event](event, ...)
    else
        if WoWPro[event] then
            WoWPro:LogEvent("Handled: "..event,...)
        else
            WoWPro:LogEvent(event,...)
        end
    end

    -- debug
    if WoWPro.QuestDialogActive == "QUEST_GREETING" then
        local numAvailableQuests = GetNumAvailableQuests()
        local numActiveQuests = GetNumActiveQuests()
        WoWPro:print("%s:%s: numActiveQuests=%d, numAvailableQuests=%d", WoWPro.QuestDialogActive, event, numActiveQuests, numAvailableQuests)
    end
    if WoWPro.QuestDialogActive == "GOSSIP_SHOW" then
        local numAvailableQuests = GetNumGossipAvailableQuests()
        local numActiveQuests = GetNumGossipActiveQuests()
        WoWPro:print("%s:%s: numActiveQuests=%d, numAvailableQuests=%d", WoWPro.QuestDialogActive, event, numActiveQuests, numAvailableQuests)
    end

	if WoWPro.InitLockdown and event == "QUEST_LOG_UPDATE" then
	    WoWPro:SendMessage("WoWPro_PuntedQLU")
	    return
	end

	if WoWPro.InitLockdown or WoWPro.InitLockdownEvents[event] then
	    -- Stop processing during init lockdown or if event already processed.
	    return
	end

	-- Stop processing if no guide is active or something is odd!
    if not WoWPro.Ready("EventHandler:"..event) then
        return
    end

    if WoWPro[event] then
        WoWPro[event](event, ...)
    end

	-- Module Event Handlers --
	for name, module in WoWPro:IterateModules() do
		if WoWPro[name].EventHandler
		and WoWProDB.char.currentguide
		and WoWPro.Guides[WoWProDB.char.currentguide]
		and guidetype == name
		then
		    WoWPro:dbp("Now calling event handler for %s",name)
		    WoWPro[name]:EventHandler(frame, event, ...)
		end
	end
end

function WoWPro.PuntedQLU()
    if WoWPro.InitLockdown then
        WoWPro:SendMessage("WoWPro_PuntedQLU")
        return
    end
    WoWPro.EventHandler(nil, "QUEST_LOG_UPDATE","-punted-")
end
