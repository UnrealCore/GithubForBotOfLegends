
if myHero.charName ~= "Thresh" then return end

--[[

	just check for sourcelibk renamed to sourcelib_fix
	
	navermind

]]

function file_check(file_name)
  local file_found=io.open(file_name, "r")      

  if file_found==nil then
    return false
  else
    return true
  end
  return file_found
end

if(file_check(LIB_PATH.."SourceLibk.lua")) then
	require 'SourceLibk';
elseif(file_check(LIB_PATH.."SourceLib_Fix.lua")) then
	require 'SourceLib_Fix';
else
	print("THreshCore: Download Sourcelibk")
	return;
end


local ScriptVersion = 1.4

SimpleUpdater("[ThreshCore]", ScriptVersion, "raw.github.com" , "/UnrealCore/GithubForBotOfLegends/master/Script/ThreshCore/ThreshCore.lua" , SCRIPT_PATH .. "ThreshCore.lua" , "/UnrealCore/GithubForBotOfLegends/master/Script/ThreshCore/ThreshCore.version" ):CheckUpdate()

local ScriptName = "ThreshCore"
local OWM = OrbWalkManager(ScriptName);
local Q, Q2, W, E, R;
local QCircle, ECircle
local Flash = {Range = 450, Slot = nil}
local Config = scriptConfig(ScriptName, ScriptName)
local oWp = 0;
local nWp = 0;
local LanternPosition = nil
local LanternObjName = "Thresh_Base_Lantern.troy"

local Interrupts, AGC;

local STS = SimpleTS();

function OnLoad()
	Q = Spell(_Q, 1100)
	Q2 = Spell(_Q, 1400)
	W = Spell(_W, 950)
	E = Spell(_E, 400)
	R = Spell(_R, 400)
	Flash = Summoner("summonerdot", 450)
	
	QCircle = _Circle(myHero, Q.range, 1, {100, 255, 0, 0})
	WCircle = _Circle(myHero, W.range, 1, {100, 255, 0, 0})
	ECircle = _Circle(myHero, E.range, 1, {100, 255, 0, 0})
	RCircle = _Circle(myHero, R.range, 1, {100, 255, 0, 0})
	
	Q:SetSkillshot(SKILLSHOT_LINEAR, 70, 0.5, 1900, true)
	Q2:SetSkillshot(SKILLSHOT_LINEAR, 70, 0.5, 1900, true)
	
	Interrupts = Interrupter()
	Interrupts:AddCallback(
		function(unit, spell) 
			if(GetDistance(unit) < E.range and Config.Interrupts.Enable) then
				E:Cast(Vector(unit))
			end
		end
	)
	
	AGC = AntiGapcloser()
	AGC:AddCallback(
		function(unit, spell)
		--[[
			unit = unit, spell = spell.name, startT = os.clock(), endT = os.clock() + 1, startPos = startPos, endPos = endPos
		]]
			if not Config.AntiGapCloser.EGapCloser then return end
			if GetDistance(spell.endPos) < E.range then
				E:Cast(spell.endPos.x, spell.endPos.z)
			end
		end
	)
	
	Config:addSubMenu("Target Selector", "TargetSelector")
		STS:AddToMenu(Config.TargetSelector);
	Config:addSubMenu("OrbWalk Manager", "OWM")
		OWM:AddToMenu(Config.OWM)
	Config:addSubMenu("Combo", "Combo")
		Config.Combo:addParam("UseQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
		-- Config.Combo:addParam("UseW", "Use W mode", SCRIPT_PARAM_LIST, {"To Closet", "Off"})
		Config.Combo:addParam("UseE", "Use E", SCRIPT_PARAM_ONOFF, true)
		Config.Combo:addParam("UseR", "Use R", SCRIPT_PARAM_ONOFF, true)
		Config.Combo:addParam("UseRPercent", "use r near enemy >=", SCRIPT_PARAM_SLICE, 2, 1, 5)
		Config.Combo:addParam("EPush", "E Push/Pull(on/off)", SCRIPT_PARAM_ONOFF, true)
	
	Config:addSubMenu("Harass", "Harass")
		Config.Harass:addParam("UseQ", "Use Q", SCRIPT_PARAM_LIST, 2, {"throw and go", "only throw", "off"})
		Config.Harass:addParam("UseE", "Use E", SCRIPT_PARAM_ONOFF, true)
	
	Config:addSubMenu("Flay", "Flay")
		Config.Flay:addParam("Push", "Push", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('I'))
		Config.Flay:addParam("Pull", "Pull", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('U'))
	
	--Config:addSubMenu("Flash Hook", "FHook")
	--	Config.FHook:addParam("FlashQ", "Flash + Hook", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('G'))
	
	Config:addSubMenu("Interrupts", "Interrupts")
		Config.Interrupts:addParam("Enable", "Interrupt Spells with E", SCRIPT_PARAM_ONOFF, true)
		Interrupter:AddToMenu(Config.Interrupts)
	
	Config:addSubMenu("Gap Closers", "GapCloser")
		Config.GapCloser:addParam("EGapCloser", "Auto use E away on Gap Closers", SCRIPT_PARAM_ONOFF, true)
		-- Config.GapCloser:addParam("RGapCloser", "Auto use R on Gap Closers", SCRIPT_PARAM_ONOFF, true)
		AGC:AddToMenu(Config.GapCloser)
	
	Config:addSubMenu("Lantern Settings", "LanternSettings")
		Config.LanternSettings:addParam("ThreshLantern", "Throw Lantern to ally", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('T'))
		Config.LanternSettings:addParam("Prioritize", "Prioritize", SCRIPT_PARAM_LIST, 3, {"FARTHEST Ally", "NEAREST ALLY", "LOWEST HEALTH ALLY"})
	
	Config:addSubMenu("Misc feature", "Misc")
		Config.Misc:addSubMenu("Q With Lantern", "Feature1")
			Config.Misc.Feature1:addParam("Enable", "Do it", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('G'))
			Config.Misc.Feature1:addParam("info1", "this is Q -> Lantern to near ally", SCRIPT_PARAM_INFO, "")
			Config.Misc.Feature1:addParam("info2", "Q2 will casted enemy is near from lantern", SCRIPT_PARAM_INFO, "")
			Config.Misc.Feature1:addParam("OnlyClickedTarget", "Only Cast to Clicked Target", SCRIPT_PARAM_ONOFF, true)
			-- Config.Misc.Feature1:addParam("UseFlash", "Use Flash", SCRIPT_PARAM_ONOFF, true)
	
	Config:addSubMenu("Drawings", "Drawings")
		QCircle:AddToMenu(Config.Drawings, "Q circle setting", true, false, true)
		WCircle:AddToMenu(Config.Drawings, "W circle setting", true, false, true)
		ECircle:AddToMenu(Config.Drawings, "E circle setting", true, false, true)
		RCircle:AddToMenu(Config.Drawings, "R circle setting", true, false, true)
		Config.Drawings:addParam("drawQpred", "Draw Q line prediction", SCRIPT_PARAM_ONOFF, true)
	
	Config:addSubMenu("Skillshot", "SS")
		Config.SS:addSubMenu("Q", "Q")
			Q:AddToMenu(Config.SS.Q)
		Config.SS:addSubMenu("flashQ", "flashQ")
			Q2:AddToMenu(Config.SS.flashQ)
end

function OnTick()
	if(Config.Flay ~= nil) then
		if(Config.Flay.Push) then
			Push()
		elseif (Config.Flay.Pull) then
			Pull()
		end
	end
	
	for _, enemy in ipairs(GetEnemyHeroes())do
		
	end
	
	--if(Config.FHook.FlashQ) then
	
	--end
	
	if(Config.LanternSettings.ThreshLantern) then
		ThrowLantern()
	end
	
	if Config.Misc.Feature1.Enable then
		Feature1()
	end
	
	if(OWM:IsComboMode())then
		Combo()
	elseif (OWM:IsHarassMode())then
		Harass()
	end
end

function OnDraw()
	QCircle:Draw()
	WCircle:Draw()
	ECircle:Draw()
	RCircle:Draw()
end

function OnCreateObj(obj)
	if obj.name == LanternObjName then
		LanternPosition = Vector(obj)
	end
end

function OnDeleteObj(obj)
	if obj.name == LanternObjName then
		LanternPosition = nil
	end
end

function ThrowLantern()
	if(W:IsReady()) then
		local L_Target  = nil;
		if(Config.LanternSettings.Prioritize == 1)then
			local length = 0
			for index, ally in ipairs(GetAllyHeroes()) do
				if(GetDistance(ally) > length and GetDistance(ally) < E.range) then
					length = GetDistance(ally)
					L_Target = ally
				end
			end
		elseif(Config.LanternSettings.Prioritize == 2)then
			local length = E.range
			for index, ally in ipairs(GetAllyHeroes()) do
				if(GetDistance(ally) < length)then
					length = GetDistance(ally)
					L_Target = ally
				end
			end
		elseif (Config.LanternSettings.Prioritize == 3) then
			local Health = math.huge
			for index, ally in ipairs(GetAllyHeroes()) do
				if(ally.health < Health and GetDistance(ally) < E.range )then
					Health = ally.health
					L_Target = ally
				end
			end
		end
		if(L_Target ~= nil) then
			E:Cast(Vector(L_Target))
		end
	end
end

function Feature1()
	target = GetTarget() or (not Config.Misc.Feature1.OnlyClickedTarget and STS:GetTarget(Q.range))
	if target ~= nil then
		if Qstat() == 1 then
			Q:Cast(target)
		else
			ally = GetAllyHeroes()
			table.sort(ally, function(a, b) return GetDistance(a) < GetDistance(b) end)
			if GetDistance(ally[1]) < W.range then
				W:Cast(ally[1].x, ally[1].z)
			elseif GetDistance(ally[1]) < W.range+400 then
				pos = Extends(myHero, ally[1], W.range)
				W:Cast(pos.x, pos.z)
			end
			if LanternPosition ~= nil then
				if GetDistance(LanternPosition, ally[1]) < 350 and Qstat() == 2 then
					if GetDistance(target) < Q.range then
						Q:Cast()
					elseif GetDistance(target) < Q.range + 420 then
						Flash:Cast()
					end
				end
			end
		end
	end
	myHero:MoveTo(mousePos.x, mousePos.z)
end

function Push(t)
	target = t or GetTarget() or STS:GetTarget(E.range)
	if(target ~= nil) then
		E:Cast(target.x, target.z)
	end
end

function Pull(t)
	target = t or GetTarget() or STS:GetTarget(E.range)
	if(target ~= nil) then
		pos = Vector(target) + (Vector(myHero) - Vector(target)):normalized() * (GetDistance(target)+E.range)
		-- CastSpell(_E, pos.x, pos.z)
		E:Cast(pos.x, pos.z)
	end
end

function Combo()
	target = GetTarget() or STS:GetTarget(Q2.range)
	if(target ~= nil) then
		if(E:IsReady() and Config.Combo.UseE and GetDistance(target) < E.range ) then
			if(Config.Combo.EPush) then
				Push(target)
			else
				Pull(target)
			end
		end
		if(Q:IsReady() and Config.Combo.UseQ and GetDistance(target) < Q.range ) then
			Q:Cast(target)
		end
		if(R:IsReady() and Config.Combo.UseR and GetDistance(target) < R.range and GetNearObject(myHero, 400, GetEnemyHeroes()) < Config.Combo.UseRPercent) then
			R:Cast()
		end
	end
end

function Harass()
	target = GetTarget() or STS:GetTarget(Q2.range)
	
	if(target ~= nil)then
		if(Q:IsReady() and Config.Harass.UseQ < 3 and GetDistance(target) < Q.range ) then
			if Qstat() == 1 then
				Q:Cast(target)
			elseif Qstat() == 2 and Config.Harass.UseQ == 1 then
				Q:Cast()
			end
		end
		if(E:IsReady() and Config.Harass.UseW and GetDistance(target) < E.range ) then
			Push(target)
		end
	end
end

function GetNearObject(position, distance, objects)
	local count = 0;
	for index, object in ipairs(objects) do
		if(GetDistance(position, object) < distance) then
			count = count+1
		end
	end
	return count
end

function Qstat()
	if not Q:IsReady() then return 0 end
	if Q:GetName() == "ThreshQ" then return 1 end
	return 2
end

function Extends(v1, v2, v3)
	return Vector(v1) + (Vector(v2) - Vector(v1)):normalized() * v3
end

class('Summoner')
function Summoner:__init(Id, range)
	self.slot = GetSummonerSlot(Id)
	self.range = range
end
function Summoner:IsReady()
	if self.slot == nil then return false end
	return myHero:CanUseSpell(self.slot) == READY
end
function Summoner:GetDamage(target)
	return 50 + 20 * myHero.level
end
function Summoner:Cast(param1, param2)
	if param1 ~= nil and param2 ~= nil then
		if type(param1) ~= "number" and type(param2) ~= "number" and VectorType(param1) and VectorType(param2) then
			-- Packet("S_CAST", {spellId = self.spellId, toX = param2.x, toY = param2.z, fromX = param1.x, fromY = param1.z}):send()
			CastSpell(self.slot, param1, param2)
		else
			CastSpell(self.slot, param1, param2)
		end
	elseif param1 ~= nil then
		CastSpell(self.slot, param1)
	else
		CastSpell(self.slot)
	end
end