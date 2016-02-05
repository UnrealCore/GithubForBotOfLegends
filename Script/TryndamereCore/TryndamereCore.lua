if Check(LIB_PATH.."SourceLibk.lua") then
	require 'SourceLibk'
else
	printMessage("Cant check SourceLibk. Download lastest version")
	UPDATE_HOST = "raw.github.com"
    UPDATE_PATH = "/kej1191/anonym/master/Common/SourceLibk.lua" .. "?rand="..math.random(1,10000)
    UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH
	DownloadFile(UPDATE_URL, LIB_PATH .. "SourceLibk.lua", function() printMessage("Successfully Download, please reload!") end)
	return
end
local ScriptVersion = 1.0
SimpleUpdater("[TryndamereCore]", ScriptVersion, "raw.github.com" , "/UnrealCore/GithubForBotOfLegends/master/Script/TryndamereCore/TryndamereCore.lua" , SCRIPT_PATH .. "TryndamereCore.lua" , "/UnrealCore/GithubForBotOfLegends/master/Script/TryndamereCore/TryndamereCore.version" ):CheckUpdate()
local ScriptName = "TryndamereCore"
local OWM = OrbWalkManager(ScriptName)
local STS = SimpleTS(STS_CLOSEST)
local DM = DrawManager()
local Config = scriptConfig(ScriptName, ScriptName)
local function GetCustomTarget()
	-- local T
	-- if OWM ~= nil and OWM.orbload then
		-- if OWM.MMALoad then T = _G.MMA_Target end
		-- if OWM.SacLoad then T = _G.AutoCarry.Crosshair.Attack_Crosshair.target end
		if OWM.RevampedLoaded then T = _G.AutoCarry.Orbwalker.target end
		-- if OWM.SxOLoad then T = OWN.SxO:GetTarget() end
		if OWM.SOWLoaded then T = SOW:GetTarget() end
		-- if OWM.NOLLoad then T = _G.NebelwolfisOrbWalker:GetTarget() end
	-- end
	-- if T == nil then T = STS:GetTarget(E.range) end
	-- if T and T.type == player.type then
		-- return T
	-- end
	-- return nil
	return STS:GetTarget(E.range, 1, STS_CLOSEST)
end
function OnLoad()
	Q = Spell(_Q, 125)
	W = Spell(_W, 400)
	E = Spell(_E, 650)
	E:SetSkillshot(SKILLSHOT_LINEAR, 175, 0, 1200, false)
	R = Spell(_R, 900)
	Ignite = Summoner("summonerdot")
	
	DM:CreateCircle(myHero, E.range, 1, {100, 255, 0, 0}, "Draw E range")
	
	Config:addSubMenu("OrbWalkManager", "OrbWalkManager")
		OWM:AddToMenu(Config.OrbWalkManager)
	
	Config:addSubMenu("TargetSelector", "TargetSelector")
		STS:AddToMenu(Config.TargetSelector)
	
	Config:addSubMenu("Draw", "Draw")
		DM:AddToMenu(Config.Draw)
	
	Config:addSubMenu("Combo", "Combo")
		Config.Combo:addParam("UseW", "Use W", SCRIPT_PARAM_LIST, 2, {"Always", "When not facting", "Off"})
		Config.Combo:addParam("UseE", "Use E to fallow", SCRIPT_PARAM_ONOFF, true)
		
	Config:addSubMenu("Harass", "Harass")
		Config.Harass:addParam("UseE", "Use E", SCRIPT_PARAM_ONOFF, true)
	
	Config:addSubMenu("Misc", "Misc")
		Config.Misc:addParam("Ult", "use R my health < (%)", SCRIPT_PARAM_SLICE, 10, 0, 100)
		Config.Misc:addParam("KillstealE", "Killsteal with E", SCRIPT_PARAM_ONOFF, true)
		Config.Misc:addParam("KillstealIgnite", "Killsteal with ignite", SCRIPT_PARAM_ONOFF, false)
		Config.Misc:addParam("QAfterR", "Auto Q after R", SCRIPT_PARAM_ONOFF, true)
	
	Config:addSubMenu("Skillshot", "Skillshot")
		E:AddToMenu(Config.Skillshot)
		
end
function OnTick()
	if Config.Misc.Ult ~= 0 and myHero.health / myHero.maxHealth * 100 < Config.Misc.Ult and R:IsReady() and STS:GetTarget(R.range) ~= nil then
		R:Cast()
	end
	if OWM:IsComboMode() then
		Combo()
	end
	if OWM:IsHarassMode() then
		Harass()
	end
	
	
	for _, enemy in ipairs(GetEnemyHeroes())do
		if Config.Misc.KillstealE and getDmg("E", enemy, myHero) > enemy.health and not enemy.dead and W:IsReady() then
			E:Cast(enemy)
		end
		if Config.Misc.KillstealIgnite and 50 + 20 * myHero.level > enemy.health and not enemy.dead and Ignite:IsReady() then
			Ignite:Cast(enemy)
		end
	end
end
function Combo()
	target = GetTarget() or STS:GetTarget(E.range, 1, STS_CLOSEST)
	if target ~= nil then
		if Config.Combo.UseW < 3 and not isFacing(myHero, target) then W:Cast() end
		if Config.Combo.UseW < 2 then W:Cast() end
		if Config.Combo.UseE and E:IsInRange(target) then E:Cast(target) end
	end
end
function Harass()
	target = GetTarget() STS:GetTarget(E.range, 1, STS_CLOSEST)
	if target ~= nil then
		if Config.Harass.UseE then E:Cast(target) end
	end
end
function OnProcessSpell(unit, spell)
	if unit.isMe and spell.name == "UndyingRage" and Config.Misc.QAfterR then
		DelayAction(function() CastSpell(_Q) end, 4.7)
	end
end
function isFacing(source, target, lineLength)
	local sourceVector = Vector(source.visionPos.x, source.visionPos.z)
	local sourcePos = Vector(source.x, source.z)
	sourceVector = (sourceVector-sourcePos):normalized()
	sourceVector = sourcePos + (sourceVector*(GetDistance(target, source)))
	return GetDistanceSqr(target, {x = sourceVector.x, z = sourceVector.y}) <= (lineLength and lineLength^2 or 90000)
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