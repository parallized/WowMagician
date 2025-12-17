local addonName = "WowMagician"

WowMagicianTimelineData = WowMagicianTimelineData or {}

-- 时间轴数据存储
local timelineData = {}
local currentDungeonKey = nil

--- 解析时间字符串为秒数
-- @param timeStr string: 时间字符串，如"0:36", "1:04", "10:44"
-- @return number: 秒数
local function ParseTimeString(timeStr)
    if not timeStr then return 0 end

    -- 处理"MM:SS"格式
    local minutes, seconds = timeStr:match("(%d+):(%d+)")
    if minutes and seconds then
        return tonumber(minutes) * 60 + tonumber(seconds)
    end

    -- 处理纯数字秒数
    return tonumber(timeStr) or 0
end

--- 解析技能列表字符串
-- @param skillsStr string: 技能字符串，如"雷霆一击, 心灵之火, 射击"
-- @return table: 技能列表
local function ParseSkillsString(skillsStr)
    if not skillsStr or skillsStr == "" then
        return {}
    end

    local skills = {}
    for skill in skillsStr:gmatch("[^,]+") do
        skill = skill:gsub("^%s*(.-)%s*$", "%1") -- 去除前后空格
        if skill ~= "" then
            table.insert(skills, skill)
        end
    end
    return skills
end

--- 解析单行时间轴数据
-- @param line string: 时间轴行，如"0:36 彼岸椛已落 {spell:196718} - 雷霆一击, 心灵之火, 射击"
-- @return table|nil: 解析后的数据
local function ParseTimelineLine(line)
    if not line or line == "" then return nil end

    -- 匹配时间戳
    local timeStr, rest = line:match("^(%d+:%d+)%s+(.+)$")
    if not timeStr then
        -- 尝试匹配纯数字时间戳
        timeStr, rest = line:match("^(%d+)%s+(.+)$")
    end

    if not timeStr or not rest then return nil end

    local time = ParseTimeString(timeStr)

    -- 检查是否是"{所有人}"类型
    if rest:match("^{所有人}") then
        local skillsPart = rest:match("^{所有人}%s+(.+)$") or ""
        local skills = ParseSkillsString(skillsPart)

        return {
            time = time,
            type = "all",
            name = "{所有人}",
            skills = skills,
            rawText = line
        }
    else
        -- 解析普通事件
        local name, spellId, skillsPart = rest:match("^([^%s{]+)%s*{spell:(%d+)}%s*-%s*(.+)$")
        if not name then
            -- 尝试没有技能的格式
            name, spellId = rest:match("^([^%s{]+)%s*{spell:(%d+)}%s*$")
            skillsPart = ""
        end
        if not name then
            -- 尝试只有名字的格式
            name = rest:match("^([^%s{]+)")
            spellId = nil
            skillsPart = ""
        end

        local skills = ParseSkillsString(skillsPart)

        return {
            time = time,
            type = "unit",
            name = name,
            spellId = spellId and tonumber(spellId),
            skills = skills,
            rawText = line
        }
    end
end

--- 设置当前副本的时间轴数据
-- @param dungeonKey string: 副本键值
-- @param data string: 时间轴数据字符串
function WowMagicianTimelineData.SetTimelineData(dungeonKey, data)
    if not dungeonKey or not data then return end

    timelineData[dungeonKey] = {}
    currentDungeonKey = dungeonKey

    -- 按行分割数据
    for line in data:gmatch("[^\r\n]+") do
        line = line:gsub("^%s*(.-)%s*$", "%1") -- 去除前后空格
        if line ~= "" and not line:match("^战斗结束") then -- 跳过战斗结束行
            local parsed = ParseTimelineLine(line)
            if parsed then
                table.insert(timelineData[dungeonKey], parsed)
            end
        end
    end

    -- 按时间排序
    table.sort(timelineData[dungeonKey], function(a, b)
        return a.time < b.time
    end)

    print(string.format("|cff00ff00[WowMagician Timeline]|r 已加载 %s 的时间轴数据 (%d 项)",
        dungeonKey, #timelineData[dungeonKey]))
end

--- 获取指定副本的时间轴数据
-- @param dungeonKey string: 副本键值
-- @return table: 时间轴数据列表
function WowMagicianTimelineData.GetTimelineData(dungeonKey)
    return timelineData[dungeonKey or currentDungeonKey] or {}
end

--- 根据当前时间获取最近的5项时间轴事件
-- @param currentTime number: 当前时间(秒)
-- @param dungeonKey string: 副本键值(可选)
-- @return table: 包含5项事件的数据表，格式：{previous={}, current=nil, upcoming={}}
function WowMagicianTimelineData.GetNearbyEvents(currentTime, dungeonKey)
    local data = WowMagicianTimelineData.GetTimelineData(dungeonKey)
    if #data == 0 then
        return {previous={}, current=nil, upcoming={}}
    end

    local result = {
        previous = {}, -- 之前的2项
        current = nil, -- 当前项(如果有的话)
        upcoming = {}  -- 之后的3项
    }

    -- 找到当前时间对应的位置
    local currentIndex = nil
    for i, event in ipairs(data) do
        if event.time <= currentTime then
            currentIndex = i
        else
            break
        end
    end

    -- 如果没有找到当前索引，说明所有事件都在未来
    if not currentIndex then
        -- 取前3个作为即将到来的事件
        for i = 1, math.min(3, #data) do
            table.insert(result.upcoming, data[i])
        end
        return result
    end

    -- 添加之前的2项
    for i = math.max(1, currentIndex - 2), currentIndex - 1 do
        if data[i] then
            table.insert(result.previous, data[i])
        end
    end

    -- 设置当前项
    result.current = data[currentIndex]

    -- 添加之后的3项
    for i = currentIndex + 1, math.min(currentIndex + 3, #data) do
        if data[i] then
            table.insert(result.upcoming, data[i])
        end
    end

    return result
end

--- 获取当前设置的副本键值
-- @return string: 当前副本键值
function WowMagicianTimelineData.GetCurrentDungeonKey()
    return currentDungeonKey
end

--- 清空所有时间轴数据
function WowMagicianTimelineData.ClearAllData()
    timelineData = {}
    currentDungeonKey = nil
    print("|cff00ff00[WowMagician Timeline]|r 已清空所有时间轴数据")
end

--- 初始化TimelineData模块
function WowMagicianTimelineData.Initialize()
    -- 这里可以添加默认的时间轴数据
    print("|cff00ff00[WowMagician TimelineData]|r TimelineData模块已初始化")
end
