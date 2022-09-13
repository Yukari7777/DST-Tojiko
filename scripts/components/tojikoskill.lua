local TojikoSkill = Class(function(self, inst)
    self.inst = inst

    self.thunderpos = nil
    self.thundertask = nil
    self.thundercooldowntask = nil
    self.thundernumcast = 0
end)

-- 번개와 벨런스 조정이 필요하다고 생각되면 정의된 함수 바로 위의 local 값들(ex. THUNDER_COOLDOWN 등)은 수정하시면 됩니다.

function TojikoSkill:CanThunderStrike()
    return self.thundertask == nil or self.thundercooldowntask == nil
end

function TojikoSkill:SetThunderCoordinate(x, y, z)
    self.thunderpos = Vector3(x, y, z)
end

local THUNDER_COOLDOWN = 20 -- 번개 쿨타임
function TojikoSkill:CooldownThunder()
    -- if self.thundertask ~= nil then
    --     self.thundertask:Cancel()
    --     self.thundertask = nil
    -- end

    -- self.thundernumcast = 0
    -- self.thundercooldowntask = self.inst:DoTaskInTime(THUNDER_COOLDOWN, function()
    --     self.thundercooldowntask:Cancel()
    --     self.thundercooldowntask = nil
    -- end)
end

local THUNDER_SEQUENCE = 3 -- 첫 시전 후 연속으로 번개를 칠 수 있는 시간
local THUNDER_MAX_USE = 3 -- 번개 연속 시전 횟수
local THUNDER_RADIUS = 3 -- 낙뢰 범위
local THUNDER_LIGHTNINGROD_SEARCH_RANGE = 10 -- 피뢰침 인식 범위
function TojikoSkill:ThunderStrike()
    -- self.thundernumcast = self.thundernumcast + 1
    -- if self.thundertask == nil then -- 최초 시전시
    --     self.thundertask = self.inst:DoTaskInTime(THUNDER_SEQUENCE, function()
    --         self:CooldownThunder()
    --     end)
    -- elseif self.thundernumcast == THUNDER_MAX_USE - 1 then -- 연속 3회 시전시 즉시 쿨타임 적용
    --     self:CooldownThunder()
    -- end
    self.inst:AddTag("ignorethunder") -- 시전자 자신은 번개 면역

    -- 참고: 전부 자란 Knobbly Tree는 번개 치는 것을 막아주는 기능을 하지만 이 함수에선 그것을 무시합니다.
    
    local x, y, z = self.thunderpos:Get()
    local rods = TheSim:FindEntities(x, y, z, THUNDER_LIGHTNINGROD_SEARCH_RANGE, {"lightningrod"})
    local rangesq = THUNDER_LIGHTNINGROD_SEARCH_RANGE * THUNDER_LIGHTNINGROD_SEARCH_RANGE
    local closest_rod = nil
    for _, v in pairs(rods) do
        local distsq = v:GetDistanceSqToPoint(x, y, z)
        if distsq < rangesq then
            rangesq = distsq
            closest_rod = v
        end
    end

    if closest_rod ~= nil then
        SpawnPrefab("thunder").Transform:SetPosition(x, y, z)
        closest_rod:PushEvent("lightningstrike")
    else -- weather.lua OnSendLightningStrike()
        SpawnPrefab("lightning").Transform:SetPosition(x-3, y, z-3) -- 좌표 조금씩 움직여서 커서지점에 맞출 필요가 있어보임
        local targets = TheSim:FindEntities(x, y, z, THUNDER_RADIUS, nil, {"INLIMBO", "ignorethunder"})
        for _, v in pairs(targets) do
            if v.components.playerlightningtarget ~= nil and (v.components.health ~= nil and not v.components.health:IsInvincible()) then 
                v.components.playerlightningtarget:DoStrike()
            elseif v.components.health ~= nil and not v.components.health:IsInvincible() then -- playerlightningtarget.lua
                local mult = v.components.moisture ~= nil and TUNING.ELECTRIC_WET_DAMAGE_MULT * v.components.moisture:GetMoisturePercent() or 1 -- 젖을수록 데미지 증가
                local damage = TUNING.LIGHTNING_DAMAGE + mult * TUNING.LIGHTNING_DAMAGE

                v.components.health:DoDelta(-damage, false, "lightning")
            elseif v.components.burnable ~= nil then
                v.components.burnable:Ignite()
            end
        end
    end
    
    -- 번개 칠때마다 정신력 닳게 하고 싶을 경우
    if self.inst.components.sanity ~= nil then
        self.inst.components.sanity:DoDelta(-1)
    end

    self.inst:RemoveTag("ignorethunder")
end

return TojikoSkill