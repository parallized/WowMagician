local addonName = "WowMagician"
local addon = CreateFrame("Frame")

-- 工具函数模块
WowMagicianUtils = WowMagicianUtils or {}

--- 从玩家全名中移除服务器名称
-- @param fullName string: 完整的玩家名称（可能包含服务器名）
-- @return string: 移除服务器名后的玩家名称
function WowMagicianUtils.RemoveServerName(fullName)
    if not fullName then
        return fullName
    end
    local name, server = strsplit("-", fullName, 2)
    return name or fullName
end

--- 获取当前团队难度信息
-- @return string: 难度标识符（mythic, heroic, normal, lfr）
function WowMagicianUtils.GetDifficulty()
    local difficultyID = GetRaidDifficultyID()
    local difficultyName = GetDifficultyInfo(difficultyID)

    if difficultyID == 16 then
        return "mythic"
    elseif difficultyID == 15 then
        return "heroic"
    elseif difficultyID == 14 then
        return "normal"
    elseif difficultyID == 1 then
        return "lfr"
    else
        return "normal"
    end
end

--- 检查玩家是否在团队中
-- @return boolean: 是否在团队中
function WowMagicianUtils.IsInGroup()
    return GetNumGroupMembers() > 0
end
