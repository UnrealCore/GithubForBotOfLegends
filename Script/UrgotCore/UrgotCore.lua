if myHero.charName ~= "Urgot" then return end

require 'SourceLibk'

local autoUpdate = true
local Version = 1.1

if autoUpdate then
	SimpleUpdater("UrgotCore", Version, "raw.github.com" , "/UnrealCore/GithubForBotOfLegends/master/Script/UrgotCore/UrgotCore.lua" , SCRIPT_PATH .. "UrgotCore.lua" , "/UnrealCore/GithubForBotOfLegends/master/Script/UrgotCore/UrgotCore.version" ):CheckUpdate()
end
--[[
	Major module
]]
local Q = {Range = 1000,Speed = 1500,Width = 75,Delay = 0.5,}
local W = {Range = 1000}
local E = {Range = 900,Speed = 1500,Width = 300,Delay = 0.8,}

local STS = SimpleTS()

local _Init_Done_ = false;

local MODE = {
	COMBO = 1,
	HARASS = 2,
	CLEAR = 3,
	FARM = 4,
}

function OnLoad()
	_Initialization_()
end

function OnTick()
	if(not _Init_Done_) then return end
	--if not OBM:CanAttack() then return end
	if OBM:IsComboMode() then
		COMBO()
	end
	if OBM:IsHarassMode() then
		HARASS()
	end
	if OBM:IsClearMode() then
		--LineClear()
	end
	if OBM:IsLastHitMode() then
		FARM()
	end
end

function OnDraw()
	if myHero.dead then return end
	QCircle:Draw()
	WCircle:Draw()
	ECircle:Draw()
end


--[[
	Miner module
]]

function COMBO()
	local target = STS:GetTarget(Q.Range)
	if target then
		if Config.COMBO.USEE and SpellE:IsReady() then
			SpellE:Cast(target);
		end
		if Config.COMBO.USEQ < 3 and SpellQ:IsReady() and GetDistance(target) < Q.Range then
			if(Config.COMBO.USEW and SpellW:IsReady() and GetDistance(target) < Q.Range ) then
				SpellW:Cast()
			end
			if Config.COMBO.USEQ < 3 and _HAS_BUFF_(target) then
				SpellQ2:__Cast(target.x, target.z)
			elseif Config.COMBO.USEQ < 2 then
				SpellQ:Cast(target)
			end
		end
	end
end

function HARASS()
	if _Is_Mana_Low_(MODE.HARASS) then return end
	local target = STS:GetTarget(Q.Range)
	if(target) then
		if(Config.HARASS.USEE and SpellE:IsReady()) then
			SpellW:Cast();
		end
		if Config.HARASS.USEQ < 3 and SpellQ:IsReady() and GetDistance(target) < Q.Range then
			if Config.HARASS.USEQ < 3 and _HAS_BUFF_(target) then
				SpellQ2:__Cast(target.x, target.z)
			elseif Config.HARASS.USEQ < 2 then
				SpellQ:Cast(target)
			end
		end
	end
end

function FARM()
	if _Is_Mana_Low_(MODE.FARM) then return end
	enemyMinions:update()
	for index, minion in ipairs(enemyMinions.objects) do
		if ValidTarget(minion) and GetDistance(minion) < Q.Range and SpellQ:IsReady() and getDmg("Q", minion, myHero) > _Get_HP_Predict_(minion) and Config.FARM.USEQ and _G.srcLib.VP ~= nil then
			local CastPosition,  HitChance,  Position = _G.srcLib.VP:GetLineCastPosition(minion, 0.5, 75, 1000, 1500, myHero, true)
			if HitChance >= 2 and GetDistance(CastPosition) < 1200 then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
	end
end
--[[
	Util module
]]

function _HAS_BUFF_(target)
	return TargetHaveBuff("urgotcorrosivedebuff", target)
end

function _Get_HP_Predict_(target, tick)
	if _G.srcLib.HP ~= nil then
		return _G.srcLib.HP:PredictHealth(target, Q.Delay)
	elseif _G.srcLib.VP ~= nil then
		return _G.srcLib.VP:GetPredictedHealth(target, 0, Q.Delay)
	else
		return target.health
	end
end

function _Is_Mana_Low_(mode)
	if(mode == MODE.HARASS) then
		return ((myHero.mana / myHero.maxMana * 100) <= Config.HARASS.ManaCheck)
	elseif (mode == MODE.CLEAR) then
		return ((myHero.mana / myHero.maxMana * 100) <= Config.CLEAR.ManaCheck)
	elseif (mode == MODE.FARM) then
		return ((myHero.mana / myHero.maxMana * 100) <= Config.FARM.ManaCheck)
	end
end

--[[
	initicalzation section
]]
function _Initialization_()
	_Init_Done_ = false
	
	_Initialization_Spell_()
	_Initialization_Menu_()
	
	enemyMinions = minionManager(MINION_ENEMY, Q.Range, myHero, MINION_SORT_MAXHEALTH_DEC)
	
	_Init_Done_ = true
end

function _Initialization_Menu_()
	Config = scriptConfig("UrgotCore", "UrgotCore")
	
	Config:addSubMenu("Orbwalk manager", "ORBWALK")
		OBM = OrbWalkManager("UrgotCore")
		OBM:AddToMenu(Config.ORBWALK)
	
	Config:addSubMenu("TargetSelector", "TARGETSELECTOR")
		STS:AddToMenu(Config.TARGETSELECTOR)
		
	Config:addSubMenu("Combo manager", "COMBO")
		Config.COMBO:addParam("USEQ", "UseQ", SCRIPT_PARAM_LIST, 2, {"ALWAYS", "ONLY HAS BUFF", "OFF"})
		Config.COMBO:addParam("USEW", "UseW", SCRIPT_PARAM_ONOFF, true)
		Config.COMBO:addParam("USEE", "UseE", SCRIPT_PARAM_ONOFF, true)
		
	Config:addSubMenu("Harass manager", "HARASS")
		Config.HARASS:addParam("USEQ", "UseQ", SCRIPT_PARAM_LIST, 2, {"ALWAYS", "ONLY HAS BUFF", "OFF"})
		Config.HARASS:addParam("USEW", "UseW", SCRIPT_PARAM_ONOFF, true)
		Config.HARASS:addParam("USEE", "UseE", SCRIPT_PARAM_ONOFF, false)
		Config.HARASS:addParam("ManaCheck", "Don't harass if mana < %", SCRIPT_PARAM_SLICE, 10, 0, 100)
	
	Config:addSubMenu("Farm manager", "FARM")
		Config.FARM:addParam("USEQ", "UseQ", SCRIPT_PARAM_ONOFF, true)
		Config.FARM:addParam("ManaCheck", "Don't farm if mana < %", SCRIPT_PARAM_SLICE, 10, 0, 100)
	
	Config:addSubMenu("Skillshot manager", "SKILLSHOT")
		Config.SKILLSHOT:addSubMenu("Q skillshot", "Q")
		SpellQ:AddToMenu(Config.SKILLSHOT.Q)
		Config.SKILLSHOT:addSubMenu("Q2 skillshot", "Q2")
		SpellQ2:AddToMenu(Config.SKILLSHOT.Q2)
		Config.SKILLSHOT:addSubMenu("E skillshot", "E")
		SpellE:AddToMenu(Config.SKILLSHOT.E)
	
	Config:addSubMenu("Draw manager", "DRAW")
		QCircle = _Circle(myHero, Q.Range, 1, {100, 255, 0, 0})
		WCircle = _Circle(myHero, W.Range, 1, {100, 255, 0, 0})
		ECircle = _Circle(myHero, E.Range, 1, {100, 255, 0, 0})

		QCircle:AddToMenu(Config.DRAW, "Q circle setting", true, false, true)
		WCircle:AddToMenu(Config.DRAW, "W circle setting", true, false, true)
		ECircle:AddToMenu(Config.DRAW, "E circle setting", true, false, true)
	
end

function _Initialization_Spell_()
	SpellQ = Spell(_Q, Q.Range)
	SpellQ:SetSkillshot(SKILLSHOT_LINEAR, Q.Width, Q.Delay, Q.Speed, true) --Config.SKILLSHOT.Q, 
	SpellQ2 = Spell(_Q, Q.Range)
	SpellQ2:SetSkillshot(SKILLSHOT_LINEAR, Q.Width, Q.Delay, Q.Speed) -- Config.SKILLSHOT.Q2, 
	SpellE = Spell(_E, E.Range)
	SpellE:SetSkillshot(SKILLSHOT_CIRCULAR, E.Width, E.Delay, E.Speed) --Config.SKILLSHOT.E,
	SpellW = Spell(_W, 0, SKILLSHOT_OTHER, 0)
end