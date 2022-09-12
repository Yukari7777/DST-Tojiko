PrefabFiles = {
	"tojiko",
	"tojiko_none",
    "tojiko_classified", -- 클라이언트와 관련된 처리를 하는 오브젝트
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/tojiko.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/tojiko.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/tojiko.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/tojiko.xml" ),
	
    Asset( "IMAGE", "images/selectscreen_portraits/tojiko_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/tojiko_silho.xml" ),

    Asset( "IMAGE", "bigportraits/tojiko.tex" ),
    Asset( "ATLAS", "bigportraits/tojiko.xml" ),
	
	Asset( "IMAGE", "images/map_icons/tojiko.tex" ),
	Asset( "ATLAS", "images/map_icons/tojiko.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_tojiko.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_tojiko.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_ghost_tojiko.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_tojiko.xml" ),
	
	Asset( "IMAGE", "images/avatars/self_inspect_tojiko.tex" ),
    Asset( "ATLAS", "images/avatars/self_inspect_tojiko.xml" ),
	
	Asset( "IMAGE", "images/names_tojiko.tex" ),
    Asset( "ATLAS", "images/names_tojiko.xml" ),
	
	Asset( "IMAGE", "images/names_gold_tojiko.tex" ),
    Asset( "ATLAS", "images/names_gold_tojiko.xml" ),
}

AddMinimapAtlas("images/map_icons/tojiko.xml")

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

-- The character select screen lines
STRINGS.CHARACTER_TITLES.tojiko = "Soga no tojiko"
STRINGS.CHARACTER_NAMES.tojiko = "Soga no tojiko"
STRINGS.CHARACTER_DESCRIPTIONS.tojiko = "*雷を起こす程度の能力"
STRINGS.CHARACTER_QUOTES.tojiko = "\"やってやんよ！\""
STRINGS.CHARACTER_SURVIVABILITY.tojiko = "Radish"

-- Custom speech strings
STRINGS.CHARACTERS.TOJIKO = require "speech_tojiko"

-- The character's name as appears in-game 
STRINGS.NAMES.TOJIKO = "tojiko"
STRINGS.SKIN_NAMES.tojiko_none = "tojiko"

-- The skins shown in the cycle view window on the character select screen.
-- A good place to see what you can put in here is in skinutils.lua, in the function GetSkinModes
local skin_modes = {
    { 
        type = "ghost_skin",
        anim_bank = "ghost",
        idle_anim = "idle", 
        scale = 0.75, 
        offset = { 0, -25 } 
    },
}

-- Add mod character to mod character list. Also specify a gender. Possible genders are MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL.
AddModCharacter("tojiko", "FEMALE", skin_modes)
modimport "scripts/skills_tojiko.lua" -- skills_util.lua 로드