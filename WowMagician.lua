local addonName = "WowMagician"

WowMagician = WowMagician or {}
WowMagicianDB = WowMagicianDB or {}

local addonFrame = CreateFrame("Frame")

addonFrame:SetScript("OnEvent", function(self, event, ...)
    WowMagicianCore.OnEvent(event, ...)
end)

addonFrame:RegisterEvent("ADDON_LOADED")

function ShowRaidInfo()
    WowMagicianUI.ShowRaidInfo()
end
