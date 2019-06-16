--------------------------------------
--      WoWPro_Profession_Trade     --
--------------------------------------

-- list of all available professions and their skillLine ID
WoWPro.ProfessionSkillLines = {
    [164] = 'Blacksmithing',
    [165] = 'Leatherworking',
    [171] = 'Alchemy',
    [182] = 'Herbalism',
    [185] = 'Cooking',
    [186] = 'Mining',
    [197] = 'Tailoring',
    [202] = 'Engineering',
    [333] = 'Enchanting',
    [356] = 'Fishing',
    [393] = 'Skinning',
    [755] = 'Jewelcrafting',
    [773] = 'Inscription',
    [794] = 'Archaeology'
}

-- list of all available professions and SpellIDs with their names
WoWPro.ProfessionSpellIDs = {
    ['Alchemy'] = 2259,
    ['Archeology'] = 78670,
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
    local name = GetSpellInfo(spellID)
    if name ~= nil then
        WoWPro.ProfessionLocalNames[name] = profName
    end
end


-- scan skill lines for profession information
function WoWPro.UpdateTradeSkills()
    WoWPro:dbp("UpdateTradeSkills()")
    local tradeskills = {}
    if WoWPro.CLASSIC then
        -- in Classic we have to rely on skill lines
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
    else
        -- the modern API has GetProfessions()/GetProfessionInfo()
        local profs = {}
        profs[1], profs[2], profs[3], profs[4], profs[5], profs[6] = GetProfessions()
        for idx = 1, 6 do
            if profs[idx] then
                local _, _, skillLevel, maxSkillLevel, _, _, skillLine, skillModifier = GetProfessionInfo(profs[idx])
                local profName = WoWPro.ProfessionSkillLines[skillLine]
                if profName then
                    tradeskills[profName] = {
                        skillLvl = skillLevel,
                        skillMax = maxSkillLevel,
                        skillMod = skillModifier
                    }
                end
            end
        end
    end

    -- merge tradeskill update so we don't forget detailed ScanTrade information
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
