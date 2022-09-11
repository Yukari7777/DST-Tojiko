local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
	Asset("SCRIPT", "scripts/prefabs/lightning.lua"),
}

-- Your character's stats
TUNING.TOJIKO_HEALTH = 200
TUNING.TOJIKO_HUNGER = 200
TUNING.TOJIKO_SANITY = 200

-- Custom starting inventory
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.TOJIKO = {
	"nightstick",
	"lightninggoathorn",
	"lightninggoathorn",
	"twigs",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.TOJIKO
end
local prefabs = FlattenTree(start_inv, true)

-- When the character is revived from human
local function onbecamehuman(inst)
	-- Set speed when not a ghost (optional)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "tojiko_speed_mod", 1.5)
end

local function onbecameghost(inst)
	-- Remove speed modifier when becoming a ghost
   inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "tojiko_speed_mod")
end

-- When loading or spawning the character
local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end
end

--function dothunder()
	--if not inst.sg:HasStateTag("busy") and 
	--then
	--TheWorld("ms_sendlightningstrike", TheInput:GetWorldPosition())
	

--end

-- This initializes for both the server and client. Tags can be added here.
local common_postinit = function(inst) 
	-- Minimap icon
	
	 

	
	inst.MiniMapEntity:SetIcon( "tojiko.tex" )
	
	
end

-- This initializes for the server only. Components are added here.
local master_postinit = function(inst)
	-- Set starting inventory
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
	
	-- choose which sounds this character will play
	inst.soundsname = "willow"
	
	-- Uncomment if "wathgrithr"(Wigfrid) or "webber" voice is used
    --inst.talker_path_override = "dontstarve_DLC001/characters/"
	

	
	
	
	-- Stats	
	inst.components.health:SetMaxHealth(TUNING.TOJIKO_HEALTH)
	inst.components.hunger:SetMax(TUNING.TOJIKO_HUNGER)
	inst.components.sanity:SetMax(TUNING.TOJIKO_SANITY)
	
	-- Damage multiplier (optional)
    inst.components.combat.damagemultiplier = 1
	
	-- Hunger rate (optional)
	inst.components.hunger.hungerrate = 0.5 * TUNING.WILSON_HUNGER_RATE
	
	inst.OnLoad = onload
    inst.OnNewSpawn = onload
	
end

return MakePlayerCharacter("tojiko", prefabs, assets, common_postinit, master_postinit, prefabs)
