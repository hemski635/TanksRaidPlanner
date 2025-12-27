-- UI.lua
-- UI frame for displaying raid plan

RaidPlannerUI = {}

local mainFrame = nil
local textDisplay = nil

local function CreateMainFrame()
    if mainFrame then
        return mainFrame
    end
    
    -- Create main window
    mainFrame = CreateFrame("Frame", "RaidPlannerMainFrame", UIParent)
    mainFrame:SetSize(400, 200)
    mainFrame:SetPoint("CENTER", UIParent, "CENTER")
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
    
    -- Background
    mainFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    mainFrame:SetBackdropColor(0, 0, 0, 0.8)
    mainFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    
    -- Title bar
    local titleBar = CreateFrame("Frame", nil, mainFrame)
    titleBar:SetSize(400, 30)
    titleBar:SetPoint("TOPLEFT", mainFrame, "TOPLEFT")
    titleBar:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        tile = true,
        tileSize = 16,
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    })
    titleBar:SetBackdropColor(0.2, 0.2, 0.3, 1)
    
    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("LEFT", titleBar, "LEFT", 10, 0)
    titleText:SetText("|cFF00FF00Raid Planner|r")
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function()
        mainFrame:Hide()
    end)
    
    -- Content area - Difficulty display
    local difficultyLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    difficultyLabel:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 15, -40)
    difficultyLabel:SetText("Next Boss:")
    
    local difficultyValue = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    difficultyValue:SetPoint("LEFT", difficultyLabel, "RIGHT", 10, 0)
    difficultyValue:SetText("HEROIC")
    difficultyValue:SetTextColor(1, 0.84, 0)  -- Gold
    
    -- Reason display
    local reasonLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    reasonLabel:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 15, -70)
    reasonLabel:SetText("Reason:")
    reasonLabel:SetWidth(360)
    reasonLabel:SetWordWrap(true)
    
    -- Condition/Notes display
    local conditionText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontSmall")
    conditionText:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 15, -110)
    conditionText:SetWidth(360)
    conditionText:SetWordWrap(true)
    conditionText:SetTextColor(0.8, 0.8, 0.8)
    
    -- Duration display
    local durationText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontSmall")
    durationText:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 15, 15)
    durationText:SetText("Est. Duration: N/A")
    durationText:SetTextColor(0.6, 0.8, 1)
    
    -- Store references
    mainFrame.difficultyValue = difficultyValue
    mainFrame.reasonLabel = reasonLabel
    mainFrame.conditionText = conditionText
    mainFrame.durationText = durationText
    
    mainFrame:Hide()
    
    return mainFrame
end

function RaidPlannerUI:Update(plan)
    if not mainFrame then
        mainFrame = CreateMainFrame()
    end
    
    if not plan or not plan.nextBossDifficulty then
        mainFrame:Hide()
        return
    end
    
    mainFrame:Show()
    
    -- Update difficulty with color
    if plan.nextBossDifficulty == "HEROIC" then
        mainFrame.difficultyValue:SetTextColor(1, 0.84, 0)  -- Gold
    elseif plan.nextBossDifficulty == "NORMAL" then
        mainFrame.difficultyValue:SetTextColor(0.2, 1, 0.2)  -- Green
    else
        mainFrame.difficultyValue:SetTextColor(0.5, 0.5, 0.5)  -- Gray
    end
    
    mainFrame.difficultyValue:SetText(plan.nextBossDifficulty)
    mainFrame.reasonLabel:SetText("Reason: " .. (plan.reason or "N/A"))
    mainFrame.conditionText:SetText(plan.condition or "")
    mainFrame.durationText:SetText("Est. Duration: " .. (plan.estimatedDuration or "N/A"))
end

function RaidPlannerUI:Toggle()
    if not mainFrame then
        mainFrame = CreateMainFrame()
    end
    
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
        -- Update with current plan
        local plan = RaidPlanner_GetCurrentPlan()
        RaidPlannerUI:Update(plan)
    end
end

-- Initialize on load
local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("ADDON_LOADED")
loadFrame:SetScript("OnEvent", function(self, event, addon)
    if addon == "RaidPlanner" then
        mainFrame = CreateMainFrame()
        local plan = RaidPlanner_GetCurrentPlan()
        RaidPlannerUI:Update(plan)
        print("|cFF00FF00RaidPlanner|r: Loaded. Use /raidplan to toggle UI")
    end
end)
