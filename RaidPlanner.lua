-- RaidPlanner.lua
-- Core logic for raid planning

RaidPlannerDB = {}

local RAID_START_TIME = nil
local RAID_ROSTER = {}
local BOSS_STATES = {}
local CURRENT_PLAN = {}
local FULL_GUILD_THRESHOLD = 0.9  -- 90% of raid members are guild members

-- Boss encounter IDs and names (Hall of Fame, Nerub-ar Palace, etc.)
local BOSS_ENCOUNTERS = {
    [2688] = "Ulgrax the Devourer",
    [2689] = "The Bloodtwins",
    [2690] = "Sikran",
    [2691] = "Rasha'nan",
    [2692] = "Broodkeeper Lurker",
    [2693] = "Ansurek",
}

local function GetRaidInfo()
    local numMembers = GetNumGroupMembers()
    local isRaid = IsInRaid()
    
    if not isRaid then
        return {
            size = 0,
            members = {},
            isFullGuild = false,
            guildMembers = 0
        }
    end
    
    local members = {}
    local guildCount = 0
    
    for i = 1, numMembers do
        local name, _, _, _, _, _, _, _, _, _, _, guid = GetRaidRosterInfo(i)
        if name then
            table.insert(members, name)
            local guildName = GetGuildInfo(guid)
            if guildName == GetGuildInfo("player") then
                guildCount = guildCount + 1
            end
        end
    end
    
    return {
        size = numMembers,
        members = members,
        guildMembers = guildCount,
        isFullGuild = (guildCount / numMembers >= FULL_GUILD_THRESHOLD)
    }
end

local function GetMinutesLate()
    if RAID_START_TIME == nil then
        RAID_START_TIME = GetServerTime()
        return 0
    end
    
    local elapsed = GetServerTime() - RAID_START_TIME
    return math.floor(elapsed / 60)
end

local function IsBossKilled(bossId)
    -- Query raid encounter info
    for i = 1, GetNumEncounters() do
        local name, _, _, difficulty, encounterID, isDefeated = GetEncounterInfo(i)
        if encounterID == bossId and isDefeated then
            return true
        end
    end
    return false
end

local function UpdateBossStates()
    for bossId, bossName in pairs(BOSS_ENCOUNTERS) do
        BOSS_STATES[bossId] = IsBossKilled(bossId)
    end
end

local function PlanNextBossDifficulty()
    local raidInfo = GetRaidInfo()
    local minutesLate = GetMinutesLate()
    
    if not raidInfo.isFullGuild or minutesLate >= 30 then
        CURRENT_PLAN = {
            hcAllowed = false,
            reason = not raidInfo.isFullGuild and "Not full guild run" or "Started 30+ minutes late",
            nextBossDifficulty = "NORMAL",
            estimatedDuration = "Unknown"
        }
        return
    end
    
    -- Full guild run and on time: check boss progression
    local bossesCleared = 0
    for bossId, isKilled in pairs(BOSS_STATES) do
        if isKilled then
            bossesCleared = bossesCleared + 1
        end
    end
    
    if bossesCleared == 0 then
        -- First boss - try HC
        CURRENT_PLAN = {
            hcAllowed = true,
            reason = "Full guild run, on time, first boss",
            nextBossDifficulty = "HEROIC",
            estimatedDuration = "3-4 hours",
            condition = "If one-shot: continue HC. If wipe: switch to NORMAL"
        }
    elseif bossesCleared <= 2 then
        -- Second/third boss - check if first was one-shot
        -- (This is simplified - in real addon, track actual attempts)
        CURRENT_PLAN = {
            hcAllowed = true,
            reason = "First boss down, continuing progression",
            nextBossDifficulty = "HEROIC",
            estimatedDuration = "2-3 hours",
            condition = "If wipe: switch all remaining to NORMAL"
        }
    else
        -- Beyond 3rd boss - switch to normal
        CURRENT_PLAN = {
            hcAllowed = false,
            reason = "HC progression complete, farming remaining bosses",
            nextBossDifficulty = "NORMAL",
            estimatedDuration = "1-2 hours"
        }
    end
end

-- Event handlers
local frame = CreateFrame("Frame", "RaidPlannerFrame")

frame:RegisterEvent("RAID_ROSTER_UPDATE")
frame:RegisterEvent("ENCOUNTER_START")
frame:RegisterEvent("ENCOUNTER_END")
frame:RegisterEvent("GROUP_FORMED")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "RAID_ROSTER_UPDATE" or event == "GROUP_FORMED" then
        UpdateBossStates()
        PlanNextBossDifficulty()
        RaidPlannerUI:Update(CURRENT_PLAN)
    elseif event == "ENCOUNTER_END" then
        local encounterID, encounterName, difficultyID, raidSize, endStatus = ...
        -- endStatus: 0 = failure, 1 = success
        UpdateBossStates()
        PlanNextBossDifficulty()
        RaidPlannerUI:Update(CURRENT_PLAN)
    end
end)

-- Slash commands
SLASH_RAIDPLANNER1 = "/raidplan"

SlashCmdList["RAIDPLANNER"] = function(msg)
    if msg == "reset" then
        RAID_START_TIME = nil
        print("|cFF00FF00RaidPlanner|r: Raid time reset")
    else
        RaidPlannerUI:Toggle()
    end
end

-- Export for UI
function RaidPlanner_GetCurrentPlan()
    return CURRENT_PLAN
end
