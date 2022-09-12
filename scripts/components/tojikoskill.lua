local TojikoSkill = Class(function(self, inst)
    self.inst = inst

    self.thunderpos = nil
    self.thundertask = nil
    self.thundercooldowntask = nil
    self.thundernumcast = 0
end)

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
function TojikoSkill:ThunderStrike()
    -- self.thundernumcast = self.thundernumcast + 1
    -- if self.thundertask == nil then -- 최초 시전시
    --     self.thundertask = self.inst:DoTaskInTime(THUNDER_SEQUENCE, function()
    --         self:CooldownThunder()
    --     end)
    -- elseif self.thundernumcast == THUNDER_MAX_USE - 1 then -- 연속 3회 시전시 즉시 쿨타임 적용
    --     self:CooldownThunder()
    -- end
    SpawnPrefab("lightning").Transform:SetPosition(self.thunderpos:Get()) -- ISSUE : 번개FX가 마우스 커서 지점에 정확히 맞지 않음, 필요시 수정
end

return TojikoSkill