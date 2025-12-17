local addonName = "WowMagician"
local addon = CreateFrame("Frame")

-- 用户界面模块
WowMagicianUI = WowMagicianUI or {}

--- 创建主界面框架
-- @return Frame: 主界面框架
function WowMagicianUI.CreateMainFrame()
    local frame = CreateFrame("Frame", "WowMagicianFrame", UIParent)
    frame:SetSize(500, 400)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("HIGH")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    -- 背景
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetColorTexture(0, 0, 0, 0.8)

    -- 标题
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOP", 0, -15)
    frame.title:SetText("团队信息")

    -- 提示文本
    frame.hint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.hint:SetPoint("TOP", 0, -35)
    frame.hint:SetText("|cff808080提示: 可以直接在文本框中编辑和复制内容|r")

    -- 编辑框
    frame.editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    frame.editBox:SetSize(460, 280)
    frame.editBox:SetPoint("TOP", 0, -60)
    frame.editBox:SetMultiLine(true)
    frame.editBox:SetAutoFocus(false)
    frame.editBox:SetFontObject("GameFontHighlight")
    frame.editBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    -- 滚动框架
    frame.scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    frame.scrollFrame:SetSize(460, 280)
    frame.scrollFrame:SetPoint("TOP", 0, -60)
    frame.scrollFrame:SetScrollChild(frame.editBox)

    -- 全选按钮
    frame.selectAllButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.selectAllButton:SetSize(100, 30)
    frame.selectAllButton:SetPoint("BOTTOMLEFT", 20, 20)
    frame.selectAllButton:SetText("全选")
    frame.selectAllButton:SetScript("OnClick", function()
        frame.editBox:SetFocus()
        frame.editBox:HighlightText()
        frame.editBox:SetCursorPosition(0)
    end)

    -- 切换格式按钮
    frame.toggleButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.toggleButton:SetSize(100, 30)
    frame.toggleButton:SetPoint("BOTTOM", 0, 20)
    frame.toggleButton:SetText("切换格式")
    frame.toggleButton:SetScript("OnClick", function()
        WowMagicianUI.ToggleDisplayFormat(frame)
    end)

    -- 关闭按钮
    frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.closeButton:SetSize(100, 30)
    frame.closeButton:SetPoint("BOTTOMRIGHT", -20, 20)
    frame.closeButton:SetText("关闭")
    frame.closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    -- 初始化显示状态
    frame.showJson = false

    return frame
end

--- 切换显示格式
-- @param frame Frame: 主界面框架
function WowMagicianUI.ToggleDisplayFormat(frame)
    if frame.showJson then
        frame.showJson = false
        frame.editBox:SetText(WowMagicianData.GetRaidInfoDisplay())
        frame.toggleButton:SetText("显示JSON")
    else
        frame.showJson = true
        frame.editBox:SetText(WowMagicianData.GetRaidInfoJson())
        frame.toggleButton:SetText("显示列表")
    end
end

--- 显示团队信息界面
function WowMagicianUI.ShowRaidInfo()
    if not WowMagicianUI.mainFrame then
        WowMagicianUI.mainFrame = WowMagicianUI.CreateMainFrame()
    end

    local raidInfoJson = WowMagicianData.GetRaidInfoJson()
    local raidInfoDisplay = WowMagicianData.GetRaidInfoDisplay()

    WowMagicianUI.mainFrame.showJson = true
    WowMagicianUI.mainFrame.editBox:SetText(raidInfoJson)
    WowMagicianUI.mainFrame.toggleButton:SetText("显示列表")

    WowMagicianUI.mainFrame:Show()
end

--- 隐藏团队信息界面
function WowMagicianUI.HideRaidInfo()
    if WowMagicianUI.mainFrame then
        WowMagicianUI.mainFrame:Hide()
    end
end
