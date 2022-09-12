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

local function OnSetOwner(inst)
    if TheWorld.ismastersim then
        inst.tojiko_classified.Network:SetClassifiedTarget(inst)
    end
end

local function AttachClassified(inst, classified)
    inst.tojiko_classified = classified
    inst.ondetachclassified = function() inst:DetachClassified() end
    inst:ListenForEvent("onremove", inst.ondetachclassified, classified)
end

local function DetachClassified(inst)
    inst.tojiko_classified = nil
    inst.ondetachclassified = nil
end

local function OverrideOnRemoveEntity(inst)
    inst.OnRemoveTojiko = inst.OnRemoveEntity
    function inst.OnRemoveEntity(inst)
        if inst.jointask ~= nil then
            inst.jointask:Cancel()
        end

        if inst.tojiko_classified ~= nil then
            if TheWorld.ismastersim then
                inst.tojiko_classified:Remove()
                inst.tojiko_classified = nil
            else
                inst:RemoveEventCallback("onremove", inst.ondetachclassified, inst.tojiko_classified)
                inst:DetachClassified()
            end
        end
        return inst:OnRemoveTojiko()
    end
end

-- This initializes for both the server and client. Tags can be added here.
local common_postinit = function(inst) 
	-- Minimap icon
	inst:AddTag("tojiko")
	inst.MiniMapEntity:SetIcon( "tojiko.tex" )
	
	-- Yukari: 키 입력한 것을 서버에 전송하기 위해 Classified를 만든뒤, 클라이언트의 초기화 단계에서 부착시킨다.
	inst:ListenForEvent("setowner", OnSetOwner)
    OverrideOnRemoveEntity(inst)
    inst.AttachTojikoClassified = AttachClassified
    inst.DetachTojikoClassified = DetachClassified
end

-- This initializes for the server only. Components are added here.
local master_postinit = function(inst)
	inst.tojiko_classified = SpawnPrefab("tojiko_classified")
    inst:AddChild(inst.tojiko_classified)


	inst:AddComponent("tojikoskill") --스킬
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
