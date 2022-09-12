local function OnEntityReplicated(inst)    
    inst._parent = inst.entity:GetParent()
    if inst._parent == nil then
        print("Unable to initialize classified data for tojiko.")
    else
        inst._parent:AttachTojikoClassified(inst)
    end
end

local function KeyCheckCommon(parent)
    return parent == ThePlayer and TheFrontEnd:GetActiveScreen() ~= nil and TheFrontEnd:GetActiveScreen().name == "HUD"
end

local function RegisterKeyEvent(classified)
    local parent = classified._parent
    if parent.HUD == nil then return end -- if it's not a client, stop here.

    if parent:HasTag("tojiko") then
        local ThunderKey = "KEY_V" -- V키로 스킬 발동
        TheInput:AddKeyDownHandler(_G[ThunderKey], function()
            if KeyCheckCommon(parent) then
                parent:DoTaskInTime(0, SendModRPCToServer(MOD_RPC[parent.prefab]["thunder"], TheInput:GetWorldPosition():Get()))
            end
        end)
    end
end

local function RegisterNetListeners(inst)
    if TheWorld.ismastersim then
        inst._parent = inst.entity:GetParent()
    end
    RegisterKeyEvent(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform() --So we can follow parent's sleep state
    inst.entity:AddNetwork()
    inst.entity:Hide()
    inst:AddTag("CLASSIFIED")
    
    --Delay net listeners until after initial values are deserialized
    inst:DoTaskInTime(0, RegisterNetListeners)
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        --Client interface
        inst.OnEntityReplicated = OnEntityReplicated
        return inst
    end

    inst.persists = false

    return inst
end


return Prefab("tojiko_classified", fn)