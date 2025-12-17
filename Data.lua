local addonName = "WowMagician"
local addon = CreateFrame("Frame")

-- 数据处理模块
WowMagicianData = WowMagicianData or {}

--- 获取团队信息的显示格式
-- @return string: 格式化的团队信息字符串，用于UI显示
function WowMagicianData.GetRaidInfoDisplay()
    local raidInfo = {}
    local numGroupMembers = GetNumGroupMembers()

    if numGroupMembers == 0 then
        return "你不在团队中"
    end

    local isRaid = IsInRaid()
    local groupType = isRaid and "团队" or "小队"

    table.insert(raidInfo, "=== " .. groupType .. "信息 ===")
    table.insert(raidInfo, "")

    for i = 1, numGroupMembers do
        local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)

        if name then
            name = WowMagicianUtils.RemoveServerName(name)
            local className = WowMagicianConstants.classNameMap[fileName] or fileName or "未知职业"
            local roleName = WowMagicianConstants.roleNames[role] or "未知"
            local color = WowMagicianConstants.classColors[fileName] or "|cffffffff"
            local status = online and "" or "|cff808080[离线]|r"

            local info = string.format("%s%s|r %s (%s) - %s%s",
                color, name, className, level, roleName, status)
            table.insert(raidInfo, info)
        end
    end

    return table.concat(raidInfo, "\n")
end

--- 获取团队信息的JSON格式
-- @return string: JSON格式的团队信息字符串
function WowMagicianData.GetRaidInfoJson()
    local numGroupMembers = GetNumGroupMembers()

    if numGroupMembers == 0 then
        return "你不在团队中"
    end

    local difficulty = WowMagicianUtils.GetDifficulty()
    local raidPlayers = {}

    for i = 1, numGroupMembers do
        local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)

        if name and online then
            name = WowMagicianUtils.RemoveServerName(name)
            local role = UnitGroupRolesAssigned(name)
            local jsonRole = WowMagicianConstants.roleToJson[role] or "unknown"
            local jsonClass = WowMagicianConstants.classToJson[fileName] or "unknown"

            table.insert(raidPlayers, {
                name = name,
                role = jsonRole,
                class = jsonClass
            })
        end
    end

    local jsonStr = '{"difficulty":"' .. difficulty .. '","raidPlayers":['

    for i, player in ipairs(raidPlayers) do
        if i > 1 then
            jsonStr = jsonStr .. ","
        end
        jsonStr = jsonStr .. string.format('{"name":"%s","role":"%s","class":"%s"}',
            player.name, player.role, player.class)
    end

    jsonStr = jsonStr .. "]}"

    return jsonStr
end

--- 获取玩家数据结构
-- @param index number: 团队成员索引
-- @return table|nil: 玩家数据结构或nil
function WowMagicianData.GetPlayerData(index)
    local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(index)

    if not name then
        return nil
    end

    return {
        name = WowMagicianUtils.RemoveServerName(name),
        fullName = name,
        rank = rank,
        subgroup = subgroup,
        level = level,
        class = fileName,
        className = WowMagicianConstants.classNameMap[fileName] or fileName or "未知职业",
        zone = zone,
        online = online,
        isDead = isDead,
        role = role,
        roleName = WowMagicianConstants.roleNames[role] or "未知",
        isML = isML,
        color = WowMagicianConstants.classColors[fileName] or "|cffffffff"
    }
end
