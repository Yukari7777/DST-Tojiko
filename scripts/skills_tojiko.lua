local Profile = GLOBAL.Profile
local TimeEvent = GLOBAL.TimeEvent
local ACTIONS = GLOBAL.ACTIONS
local State = GLOBAL.State
local GetString = GLOBAL.GetString
local BufferedAction = GLOBAL.BufferedAction
local ActionHandler = GLOBAL.ActionHandler
local EventHandler = GLOBAL.EventHandler
local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local FRAMES = GLOBAL.FRAMES
local next = GLOBAL.next
local Vector3 = GLOBAL.Vector3

local function ForceStopHeavyLifting(inst)
    if inst.components.inventory:IsHeavyLifting() then
        inst.components.inventory:DropItem(inst.components.inventory:Unequip(EQUIPSLOTS.BODY), true, true)
    end
end

local function OnStartSkillGeneral(inst, shouldstop) 
   inst:AddTag("inskill")
   inst.components.locomotor:Stop()
   inst.components.locomotor:Clear()
   inst:ClearBufferedAction()
   ForceStopHeavyLifting(inst)
   if shouldstop ~= false and inst.components.playercontroller ~= nil then -- shouldstop이 false일 경우 스킬 시전도중 
      inst.components.playercontroller:RemotePausePrediction()
      inst.components.playercontroller:Enable(false)
   end
   inst:PerformBufferedAction()
end

local function OnFinishSkillGeneral(inst)
   inst:RemoveTag("inskill")
   if inst.components.playercontroller ~= nil then
      inst.components.playercontroller:Enable(true)
   end
end

local function RegisterSkill(skillname, character, Stategraph, datahandlefn)
   local upperskillname = skillname:upper()

   AddAction(upperskillname, skillname, function() return true end)
   AddModRPCHandler(character, skillname, function(inst, x, y, z)
      inst:PushEvent("on"..skillname, {pos = Vector3(x, y, z)})
   end)

   AddStategraphState("wilson", Stategraph)
   AddStategraphActionHandler("wilson", ActionHandler(ACTIONS[upperskillname], skillname))
   AddPrefabPostInit(character, function(inst)
      inst:ListenForEvent("on"..skillname, function(inst, data)
         local buff = BufferedAction(inst, nil, ACTIONS[upperskillname])
         datahandlefn(inst, data)
         inst.components.playercontroller:DoAction(buff)
      end)
   end)
end

---------------------------------------------------------------------------------------------------
-- 아래부터는 실제 스킬과 관련된 스크립트

local thunder_Sg = State { 
   name = "thunder",
   tags = { "busy", "doing", "skill", "pausepredict", "nointerrupt" },

   onenter = function(inst)
      OnStartSkillGeneral(inst) -- 캐릭터 조작 멈춤, 현재 진행중인 동작 해제
      inst.sg:SetTimeout(12 * FRAMES)
      inst.AnimState:PlayAnimation("whip_pre") -- 팔 들어올리는 모션; 프레임 수: 7

      if inst.components.tojikoskill:CanThunderStrike() then -- 천둥 쿨타임 확인
         inst.AnimState:PushAnimation("whip", false) -- 휘두르는 모션
      else -- 쿨타임일 경우
         inst.components.talker:Say(GetString(inst.prefab, "SKILLS_COOLDOWN")) --speech_tojiko.lua에 있는 SKILLS_COOLDOWN 대사 출력
         inst.sg:GoToState("idle") -- 모션 강제 종료
         return
      end
   end,

   timeline = {
      TimeEvent(4 * FRAMES, function(inst)
         inst.components.tojikoskill:ThunderStrike() -- 정해진 좌표에 천둥
      end),
   },
   
   -- events, ontimeout, onexit은 스킬이 종료됐을 때 정상적인 상태로 돌아가기 위한 내용들이 있음.

   events = {
      EventHandler("animover", function(inst)
         if inst.AnimState:AnimDone() then
            inst.sg:GoToState("idle", true)
         end
      end),
    },
   
   ontimeout = function(inst)
      OnFinishSkillGeneral(inst)
   end,
   
   onexit = function(inst)   
      OnFinishSkillGeneral(inst)
   end,
}

function thunderfn(inst, data)
   inst.components.tojikoskill:SetThunderCoordinate(data.pos:Get()) -- 내리칠 천둥 좌표 설정
end

RegisterSkill("thunder", "tojiko", thunder_Sg, thunderfn) --스킬 등록