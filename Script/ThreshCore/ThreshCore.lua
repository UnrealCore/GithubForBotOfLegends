
if myHero.charName ~= "Thresh" then return end

require 'SourceLibk'


local ScriptVersion = 1.00

SimpleUpdater("[ThreshCore]", ScriptVersion, "raw.github.com" , "/UnrealCore/GithubForBotOfLegends/master/Script/ThreshCore/ThreshCore.lua" , SCRIPT_PATH .. "ThreshCore.lua" , "/UnrealCore/GithubForBotOfLegends/master/Script/ThreshCore/ThreshCore.version" ):CheckUpdate()

local ScriptName = "ThreshCore"
local OWM = OrbWalkManager(ScriptName);
local Q, Q2, W, E, R;
local QCircle, ECircle
local Flash = {Range = 450, Slot = nil}
local Config = scriptConfig(ScriptName, ScriptName)
local oWp = 0;
local nWp = 0;

local Interrupts, AGC;

local STS = SimpleTS();

function OnLoad()
	Q = Spell(_Q, 1100)
	Q2 = Spell(_Q, 1400)
	W = Spell(_W, 950)
	E = Spell(_E, 400)
	R = Spell(_R, 400)
	
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
			if(GetDistance(unit) < E.range and Config.GapCloser.UseE) then
				E:Cast(spell.endPos)
			end
			if(GetDistance(unit) < R.range and Config.GapCloser.UseR)then
				R:Cast()
			end
		end
	)
	
	Config:addSubMenu("Target Selector", "TargetSelector")
		STS:AddToMenu(Config.TargetSelector);
	Config:addSubMenu("OrbWalk Manager", "OWM")
		OWM:AddToMenu(Config.OWM)
	Config:addSubMenu("Combo", "Combo")
		Config.Combo:addParam("UseQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.Combo:addParam("UseW", "Use W", SCRIPT_PARAM_ONOFF, true)
		Config.Combo:addParam("UseE", "Use E", SCRIPT_PARAM_ONOFF, true)
		Config.Combo:addParam("UseR", "Use R", SCRIPT_PARAM_ONOFF, true)
		Config.Combo:addParam("EPush", "E Push/Pull(on/off)", SCRIPT_PARAM_ONOFF, true)
	
	Config:addSubMenu("Harass", "Harass")
		Config.Harass:addParam("UseQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
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
		Config.GapCloser:addParam("RGapCloser", "Auto use R on Gap Closers", SCRIPT_PARAM_ONOFF, true)
		AGC:AddToMenu(Config.GapCloser)
	
	Config:addSubMenu("Lantern Settings", "LanternSettings")
		Config.LanternSettings:addParam("ThreshLantern", "Throw Lantern to ally", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('T'))
		Config.LanternSettings:addParam("Prioritize", "Prioritize", SCRIPT_PARAM_LIST, 3, {"FARTHEST Ally", "NEAREST ALLY", "LOW ALLY"})
	
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
	if(Config.Flay.Push) then
		Push()
	elseif (Config.Flay.Pull) then
		Pull()
	end
	
	--if(Config.FHook.FlashQ) then
	
	--end
	
	if(Config.LanternSettings.ThreshLantern) then
		ThrowLantern()
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

function Push(t)
	target = t or GetTarget() or STS:GetTarget(E.range)
	if(target ~= nil) then
		E:Cast(Vector(target))
	end
end

function Pull(t)
	target = t or GetTarget() or STS:GetTarget(E.range)
	if(target ~= nil) then
		pos = Vector(target) + (Vector(myHero) - Vector(target)):normalized() * (GetDistance(target)+400)
		E:Cast(pos)
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
		if(R:IsReady() and Config.Combo.UseR and GetDistance(target) < R.range) then
			R:Cast()
		end
	end
end

function Harass()
	target = GetTarget() or STS:GetTarget(Q2.range)
	
	if(target ~= nil)then
		if(Q:IsReady() and Config.Harass.UseQ and GetDistance(target) < Q.range ) then
			Q:Cast(target)
		end
		if(E:IsReady() and Config.Harass.UseW and GetDistance(target) < E.range ) then
			E:Cast(target)
		end
	end
end