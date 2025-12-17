local addonName = "WowMagician"

-- 职业颜色映射
WowMagicianConstants = WowMagicianConstants or {}

WowMagicianConstants.classColors = {
    ["WARRIOR"] = "|cffC79C6E",
    ["PALADIN"] = "|cffF58CBA",
    ["HUNTER"] = "|cffABD473",
    ["ROGUE"] = "|cffFFF569",
    ["PRIEST"] = "|cffFFFFFF",
    ["DEATHKNIGHT"] = "|cffC41F3B",
    ["SHAMAN"] = "|cff0070DE",
    ["MAGE"] = "|cff69CCF0",
    ["WARLOCK"] = "|cff9482C9",
    ["MONK"] = "|cff00FF96",
    ["DRUID"] = "|cffFF7D0A",
    ["DEMONHUNTER"] = "|cffA330C9",
    ["EVOKER"] = "|cff33937F",
}

-- 角色名称映射（中文）
WowMagicianConstants.roleNames = {
    ["TANK"] = "坦克",
    ["HEALER"] = "治疗",
    ["DAMAGER"] = "输出",
}

-- 职业名称映射（中文）
WowMagicianConstants.classNameMap = {
    ["WARRIOR"] = "战士",
    ["PALADIN"] = "圣骑士",
    ["HUNTER"] = "猎人",
    ["ROGUE"] = "潜行者",
    ["PRIEST"] = "牧师",
    ["DEATHKNIGHT"] = "死亡骑士",
    ["SHAMAN"] = "萨满",
    ["MAGE"] = "法师",
    ["WARLOCK"] = "术士",
    ["MONK"] = "武僧",
    ["DRUID"] = "德鲁伊",
    ["DEMONHUNTER"] = "恶魔猎手",
    ["EVOKER"] = "唤魔师",
}

-- 角色到JSON格式映射
WowMagicianConstants.roleToJson = {
    ["TANK"] = "tank",
    ["HEALER"] = "healer",
    ["DAMAGER"] = "dps",
}

-- 职业到JSON格式映射
WowMagicianConstants.classToJson = {
    ["WARRIOR"] = "warrior",
    ["PALADIN"] = "paladin",
    ["HUNTER"] = "hunter",
    ["ROGUE"] = "rogue",
    ["PRIEST"] = "priest",
    ["DEATHKNIGHT"] = "deathknight",
    ["SHAMAN"] = "shaman",
    ["MAGE"] = "mage",
    ["WARLOCK"] = "warlock",
    ["MONK"] = "monk",
    ["DRUID"] = "druid",
    ["DEMONHUNTER"] = "demonhunter",
    ["EVOKER"] = "evoker",
}
