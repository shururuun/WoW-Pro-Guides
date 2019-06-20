--------------------------------------
--      WoWPro_Profession_Trade     --
--------------------------------------

-- list of all available professions and their skillLine ID
WoWPro.ProfessionSkillLines = {
     [164] = { name = 'Blacksmithing' },
    [2437] = { exp = 7, parent = 164, name = 'Battle for Azeroth Blacksmithing' },
    [2454] = { exp = 6, parent = 164, name = 'Legion Blacksmithing' },
    [2472] = { exp = 5, parent = 164, name = 'Draenor Blacksmithing' },
    [2473] = { exp = 4, parent = 164, name = 'Pandaria Blacksmithing' },
    [2474] = { exp = 3, parent = 164, name = 'Cataclysm Blacksmithing' },
    [2475] = { exp = 2, parent = 164, name = 'Northrend Blacksmithing' },
    [2476] = { exp = 1, parent = 164, name = 'Outland Blacksmithing' },
    [2477] = { exp = 0, parent = 164, name = 'Blacksmithing' },

     [165] = { name = 'Leatherworking' },
    [2525] = { exp = 7, parent = 165, name = 'Battle for Azeroth Leatherworking' },
    [2526] = { exp = 6, parent = 165, name = 'Legion Leatherworking' },
    [2527] = { exp = 5, parent = 165, name = 'Draenor Leatherworking' },
    [2528] = { exp = 4, parent = 165, name = 'Pandaria Leatherworking' },
    [2529] = { exp = 3, parent = 165, name = 'Cataclysm Leatherworking' },
    [2530] = { exp = 2, parent = 165, name = 'Northrend Leatherworking' },
    [2531] = { exp = 1, parent = 165, name = 'Outland Leatherworking' },
    [2532] = { exp = 0, parent = 165, name = 'Leatherworking' },

     [171] = { name = 'Alchemy' },
    [2478] = { exp = 7, parent = 171, name = 'Battle for Azeroth Alchemy' },
    [2479] = { exp = 6, parent = 171, name = 'Legion Alchemy' },
    [2480] = { exp = 5, parent = 171, name = 'Draenor Alchemy' },
    [2481] = { exp = 4, parent = 171, name = 'Pandaria Alchemy' },
    [2482] = { exp = 3, parent = 171, name = 'Cataclysm Alchemy' },
    [2483] = { exp = 2, parent = 171, name = 'Northrend Alchemy' },
    [2484] = { exp = 1, parent = 171, name = 'Outland Alchemy' },
    [2485] = { exp = 0, parent = 171, name = 'Alchemy' },

     [182] = { name = 'Herbalism' },
    [2549] = { exp = 7, parent = 182, name = 'Battle for Azeroth Herbalism' },
    [2550] = { exp = 6, parent = 182, name = 'Legion Herbalism' },
    [2551] = { exp = 5, parent = 182, name = 'Draenor Herbalism' },
    [2552] = { exp = 4, parent = 182, name = 'Pandaria Herbalism' },
    [2553] = { exp = 3, parent = 182, name = 'Cataclysm Herbalism' },
    [2554] = { exp = 2, parent = 182, name = 'Northrend Herbalism' },
    [2555] = { exp = 1, parent = 182, name = 'Outland Herbalism' },
    [2556] = { exp = 0, parent = 182, name = 'Herbalism' },

    -- Cooking is not included in GetTradeSkillLineInfoByID()
     [185] = { name = 'Cooking' },
    [2541] = { exp = 7, parent = 185, name = 'Battle for Azeroth Cooking' },
    [2542] = { exp = 6, parent = 185, name = 'Legion Cooking' },
    [2543] = { exp = 5, parent = 185, name = 'Draenor Cooking' },
    [2544] = { exp = 4, parent = 185, name = 'Pandaria Cooking' },
    [2545] = { exp = 3, parent = 185, name = 'Cataclysm Cooking' },
    [2546] = { exp = 2, parent = 185, name = 'Northrend Cooking' },
    [2547] = { exp = 1, parent = 185, name = 'Outland Cooking' },
    [2548] = { exp = 0, parent = 185, name = 'Cooking' },

     [186] = { name = 'Mining' },
    [2565] = { exp = 7, parent = 186, name = 'Battle for Azeroth Mining' },
    [2566] = { exp = 6, parent = 186, name = 'Legion Mining' },
    [2567] = { exp = 5, parent = 186, name = 'Draenor Mining' },
    [2568] = { exp = 4, parent = 186, name = 'Pandaria Mining' },
    [2569] = { exp = 3, parent = 186, name = 'Cataclysm Mining' },
    [2570] = { exp = 2, parent = 186, name = 'Northrend Mining' },
    [2571] = { exp = 1, parent = 186, name = 'Outland Mining' },
    [2572] = { exp = 0, parent = 186, name = 'Mining' },

     [197] = { name = 'Tailoring' },
    [2533] = { exp = 7, parent = 197, name = 'Battle for Azeroth Tailoring' },
    [2534] = { exp = 6, parent = 197, name = 'Legion Tailoring' },
    [2535] = { exp = 5, parent = 197, name = 'Draenor Tailoring' },
    [2536] = { exp = 4, parent = 197, name = 'Pandaria Tailoring' },
    [2537] = { exp = 3, parent = 197, name = 'Cataclysm Tailoring' },
    [2538] = { exp = 2, parent = 197, name = 'Northrend Tailoring' },
    [2539] = { exp = 1, parent = 197, name = 'Outland Tailoring' },
    [2540] = { exp = 0, parent = 197, name = 'Tailoring' },

     [202] = { name = 'Engineering' },
    [2499] = { exp = 7, parent = 202, name = 'Battle for Azeroth Engineering' },
    [2500] = { exp = 6, parent = 202, name = 'Legion Engineering' },
    [2501] = { exp = 5, parent = 202, name = 'Draenor Engineering' },
    [2502] = { exp = 4, parent = 202, name = 'Pandaria Engineering' },
    [2503] = { exp = 3, parent = 202, name = 'Cataclysm Engineering' },
    [2504] = { exp = 2, parent = 202, name = 'Northrend Engineering' },
    [2505] = { exp = 1, parent = 202, name = 'Outland Engineering' },
    [2506] = { exp = 0, parent = 202, name = 'Engineering' },

     [333] = { name = 'Enchanting' },
    [2486] = { exp = 7, parent = 333, name = 'Battle for Azeroth Enchanting' },
    [2487] = { exp = 6, parent = 333, name = 'Legion Enchanting' },
    [2488] = { exp = 5, parent = 333, name = 'Draenor Enchanting' },
    [2489] = { exp = 4, parent = 333, name = 'Pandaria Enchanting' },
    [2491] = { exp = 3, parent = 333, name = 'Cataclysm Enchanting' },
    [2492] = { exp = 2, parent = 333, name = 'Northrend Enchanting' },
    [2493] = { exp = 1, parent = 333, name = 'Outland Enchanting' },
    [2494] = { exp = 0, parent = 333, name = 'Enchanting' },

    -- Fishing is not included in GetTradeSkillLineInfoByID()
     [356] = { name = 'Fishing' },
    [2585] = { exp = 8, parent = 356, name = 'Battle for Azeroth Fishing' },
    [2586] = { exp = 7, parent = 356, name = 'Legion Fishing' },
    [2587] = { exp = 5, parent = 356, name = 'Draenor Fishing' },
    [2588] = { exp = 4, parent = 356, name = 'Pandaria Fishing' },
    [2589] = { exp = 3, parent = 356, name = 'Cataclysm Fishing' },
    [2590] = { exp = 2, parent = 356, name = 'Northrend Fishing' },
    [2591] = { exp = 1, parent = 356, name = 'Outland Fishing' },
    [2592] = { exp = 0, parent = 356, name = 'Fishing' },

     [393] = { name = 'Skinning' },
    [2557] = { exp = 7, parent = 393, name = 'Battle for Azeroth Skinning' },
    [2558] = { exp = 6, parent = 393, name = 'Legion Skinning' },
    [2559] = { exp = 5, parent = 393, name = 'Draenor Skinning' },
    [2560] = { exp = 4, parent = 393, name = 'Pandaria Skinning' },
    [2561] = { exp = 3, parent = 393, name = 'Cataclysm Skinning' },
    [2562] = { exp = 2, parent = 393, name = 'Northrend Skinning' },
    [2563] = { exp = 1, parent = 393, name = 'Outland Sknning' },
    [2564] = { exp = 0, parent = 393, name = 'Skinning' },

     [755] = { name = 'Jewelcrafting' },
    [2517] = { exp = 7, parent = 755, name = 'Battle for Azeroth Jewelcrafting' },
    [2518] = { exp = 6, parent = 755, name = 'Legion Jewelcrafting' },
    [2519] = { exp = 5, parent = 755, name = 'Draenor Jewelcrafting' },
    [2520] = { exp = 4, parent = 755, name = 'Pandaria Jewelcrafting' },
    [2521] = { exp = 3, parent = 755, name = 'Cataclysm Jewelcrafting' },
    [2522] = { exp = 2, parent = 755, name = 'Northrend Jewelcrafting' },
    [2523] = { exp = 1, parent = 755, name = 'Outland Jewelcrafting' },
    [2524] = { exp = 0, parent = 755, name = 'Jewelcrafting' },

     [773] = { name = 'Inscription' },
    [2507] = { exp = 7, name = 'Battle for Azeroth Inscription' },
    [2508] = { exp = 6, name = 'Legion Inscription' },
    [2509] = { exp = 5, name = 'Draenor Inscription' },
    [2510] = { exp = 4, name = 'Pandaria Inscription' },
    [2511] = { exp = 3, name = 'Cataclysm Inscription' },
    [2512] = { exp = 2, name = 'Northrend Inscription' },
    [2513] = { exp = 1, name = 'Outland Inscription' },
    [2514] = { exp = 0, name = 'Inscription' },

    --  Archaeology is not included in GetTradeSkillLineInfoByID()
     [794] = { name = 'Archaeology' }
}


-- special handling for Classic because of the reduced addon API
if WoWPro.CLASSIC then

    -- list of all available professions and SpellIDs with their names
    WoWPro.ProfessionSpellIDs = {
        ['Alchemy'] = 2259,
        ['Archaeology'] = 78670,
        ['Blacksmithing'] = 2018,
        ['Cooking'] = 2550,
        ['Enchanting'] = 7411,
        ['Engineering'] = 4036,
        ['First Aid'] = 3273,
        ['Fishing'] = 7620,
        ['Herbalism'] = 9134,
        ['Inscription'] = 45357,
        ['Jewelcrafting'] = 25229,
        ['Leatherworking'] = 2108,
        ['Mining'] = 2575,
        ['Skinning'] = 8613,
        ['Tailoring'] = 3908
    }

    -- generate a list of localized profession names via GetSpellInfo()
    WoWPro.ProfessionLocalNames = {}
    for profName, spellID in pairs(WoWPro.ProfessionSpellIDs) do
        local localName = GetSpellInfo(spellID)
        if localName ~= nil then
            WoWPro.ProfessionLocalNames[localName] = profName
        end
    end

    -- get tradeskill information from skill lines
    function WoWPro.UpdateTradeSkills()
        WoWPro:dbp("UpdateTradeSkills() for Classic")
        local tradeskills = {}
        for idx = 1, GetNumSkillLines() do
            local localName, header, _, skillLevel, _, skillModifier, skillMaxRank = GetSkillLineInfo(idx)
            local tradeskillName = WoWPro.ProfessionLocalNames[localName]
            if not header and tradeskillName ~= nil then
                tradeskills[tradeskillName] = {
                    skillLvl = skillLevel,
                    skillMod = skillModifier,
                    skillMax = skillMaxRank
                }
            end
        end
        WoWPro.UpdateTradeSkillsTable(tradeskills)
    end
else
    -- get tradeskill information from GetProfession/GetProfessionInfo
    function WoWPro.UpdateTradeSkills()
        WoWPro:dbp("UpdateTradeSkills() for Live")
        local tradeskills = {}
        local profs = {}
        profs[1], profs[2], profs[3], profs[4], profs[5], profs[6] = GetProfessions()
        for idx = 1, 6 do
            if profs[idx] then
                local _, _, skillLevel, maxSkillLevel, _, _, skillLine, skillModifier = GetProfessionInfo(profs[idx])
                local profName = WoWPro.ProfessionSkillLines[skillLine].name
                if profName then
                    tradeskills[profName] = {
                        skillLvl = skillLevel,
                        skillMax = maxSkillLevel,
                        skillMod = skillModifier
                    }
                end
            end
        end
        WoWPro.UpdateTradeSkillsTable(tradeskills)
    end
end


-- update WoWProCharDB.Tradeskill map so we don't forget detailed ScanTrade() info
function WoWPro.UpdateTradeSkillsTable(tradeskills)
    if WoWProCharDB.Tradeskills then
        -- remove unlearned professions
        for trade in pairs(WoWProCharDB.Tradeskills) do
            if tradeskills[trade] == nil then
                WoWProCharDB.Tradeskills[trade] = nil
            end
        end
        -- add/update learned professions
        for trade, info in pairs(tradeskills) do
            if WoWProCharDB.Tradeskills[trade] == nil then
                WoWProCharDB.Tradeskills[trade] = info
            else
                WoWProCharDB.Tradeskills[trade].skillLvl = info.skillLvl
                WoWProCharDB.Tradeskills[trade].skillMax = info.skillMax
                WoWProCharDB.Tradeskills[trade].skillMod = info.skillMod
            end
        end
    else
        WoWProCharDB.Tradeskills = tradeskills
    end
end


-- scan tradeskill recipe IDs
function WoWPro.ScanTrade()
    -- local tradeskillName, rank, maxLevel = GetTradeSkillLine()
    local tradeSkillID, skillLineName, skillLineRank, skillLineMaxRank, skillLineModifier =  C_TradeSkillUI.GetTradeSkillLine();
    
    if not skillLineName then
        -- Got event when not in Trade window. Ignore
        return
    end

    WoWPro:dbp("Opened %s window",skillLineName)
    WoWProCharDB.Trades = WoWProCharDB.Trades or {}
    local Trade = WoWProCharDB.Trades 
    
    -- Scan trade skills, saving state of headers
    local recipeIDs = C_TradeSkillUI.GetAllRecipeIDs({})
    WoWPro:dbp("Located %d recipeIDs",#recipeIDs)
    
    for i, recipeID in ipairs(recipeIDs) do
		local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
		if recipeInfo.type == "recipe" then
		    if recipeInfo.learned then
--		        WoWPro:Print("Scanning %d:%s",recipeID,recipeInfo.name)
                local link = C_TradeSkillUI.GetRecipeLink(recipeID)
                local _, _, spellId = link:find("^|%x+|Henchant:(.+)|h%[.+%]");
                spellId = tonumber(spellId)
                if not spellId then
                    local safe_link = link:gsub("|", "¦")
                    WoWPro:Error("Error scanning recipeID %d for [%s]: %s",recipeID, recipeInfo.name, safe_link)
                else
                    if not Trade[spellId] then
                        Trade[spellId] = true
                        WoWPro:dbp("Newly learned %s:%d",recipeInfo.name, spellId)
                    end
                end
            end
        end
	end

    WoWProCharDB.Trades  = Trade
end


function WoWPro.LearnRecipe(which)
    local which = tonumber(which)
    if which then
        if WoWProCharDB.Trades[which] then
            -- You managed to learn something you already knew?
            WoWPro:Warning("Recipe %d was already recorded as learned.",which)
        else
            WoWProCharDB.Trades[which] = true
            WoWPro:dbp("Newly learned %d", which)
        end
    end
end
