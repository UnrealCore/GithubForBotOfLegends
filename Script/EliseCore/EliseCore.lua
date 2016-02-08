if myHero.charName ~= "Elise" then return end

--/============================================\
--|				 	Requires				   |
--\============================================/

function Check(file_name)
	local file_found=io.open(file_name, "r")      

	if file_found==nil then
		return false
	else
		return true
	end
	return file_found
end
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
local VERSION = 1.0
SimpleUpdater("[EliseCore]", VERSION, "raw.github.com" , "/UnrealCore/GithubForBotOfLegends/master/Script/EliseCore/EliseCore.lua" , SCRIPT_PATH .. "EliseCore.lua" , "/UnrealCore/GithubForBotOfLegends/master/Script/EliseCore/EliseCore.version" ):CheckUpdate()

--/============================================\
--|				 Initialization				   |
--\============================================/

class('Summoner')
function Summoner:__init(Id, range)
	self.slot = GetSummonerSlot(Id)
	self.range = range
end
function Summoner:IsReady()
	if self.slot == nil then return false end
	return myHero:CanUseSpell(self.slot) == READY
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

function AddManaChecker(m, v)
	per = v or 40
	m:addParam("mper", "dont use if my mana <= (%)", per, 1, 100)
end

function IsManaLow(per)
	if per == nil then return false end
	return ((myHero.mana / myHero.maxMana * 100) <= per)
end

local ScriptName = "EliseCore"
local OWM = OrbWalkManager(ScriptName)
local DM = DrawManager()
local DLib = DamageLib()
local STS = SimpleTS()
local IT = Interrupter()
local Config = scriptConfig(ScriptName, ScriptName)
local SMM

--/============================================\
--|				 MainFunctions				   |
--\============================================/

local CD = {
	["Human"] = {
		["Q"] = {6, 6, 6, 6, 6},
		["W"] = {12, 12, 12, 12, 12},
		["E"] = {14, 13, 12, 11, 10},
	},
	["Spider"] = {
		["Q"] = {6, 6, 6, 6, 6},
		["W"] = {12, 12, 12, 12, 12},
		["E"] = {26, 23, 20, 17, 14},
	},
}

local Cooldown = {
	["Human"] = {
		["Q"] = 0,
		["W"] = 0,
		["E"] = 0,
	},
	["Spider"] = {
		["Q"] = 0,
		["W"] = 0,
		["E"] = 0,
	},
}

local Spell = {
	["Human"] = {
		["Q"] = Spell(_Q, 625),
		["W"] = Spell(_W, 950),
		["E"] = Spell(_E, 1075),
	},
	["Spider"] = {
		["Q"] = Spell(_Q, 475),
		["W"] = Spell(_W, 0),
		["E"] = Spell(_E, 750),
	},
	["R"] = Spell(_R, 0),
	["Ignite"] = Summoner("summonerdot"),
	["Smite"] = Summoner(""), -- ?
}

local Circle = {
	["Human"] = {
		["Q"] = _Circle(myHero, 625, 1, {100, 255, 0, 0}),
		["W"] = _Circle(myHero, 950, 1, {100, 255, 0, 0}),
		["E"] = _Circle(myHero, 1075, 1, {100, 255, 0, 0}),
	},
	["Spider"] = {
		["Q"] = _Circle(myHero, 475, 1, {100, 255, 0, 0}),
		-- ["W"] = _Circle(myHero, 625, 1, {100, 255, 0, 0}),
		["E"] = _Circle(myHero, 750, 1, {100, 255, 0, 0}),
	}
}


Spell["Human"]["W"]:SetSkillshot(SKILLSHOT_LINEAR, 100, 0.25, 1000, true)
Spell["Human"]["E"]:SetSkillshot(SKILLSHOT_LINEAR, 55, 0.25, 1300, true)

local Data = {
	["IsHuman"] = false,
	["Cooldown"] = {
		["Human"] = {
			["Q"] = 0,
			["W"] = 0,
			["E"] = 0,
		},
		["Spider"] = {
			["Q"] = 0,
			["W"] = 0,
			["E"] = 0,
		},
	},
}

-- DLib:RegisterDamageSource(_Q, )


function OnLoadMenu()
	Config:addSubMenu("TargetSelector", "TargetSelector")
		STS:AddToMenu(Config.TargetSelector)
	Config:addSubMenu("OrbWalkManager", "OrbWalkManager")
		OWM:AddToMenu(Config.OrbWalkManager)
	
	Config:addSubMenu("Draw", "Draw")
		Circle["Human"]["Q"]:AddToMenu(Config.Draw, "Draw Human Q", true, true, true)
		Circle["Human"]["W"]:AddToMenu(Config.Draw, "Draw Human W", true, true, true)
		Circle["Human"]["E"]:AddToMenu(Config.Draw, "Draw Human E", true, true, true)
		Circle["Spider"]["Q"]:AddToMenu(Config.Draw, "Draw Human Q", true, true, true)
		-- Circle["Spider"]["W"]:AddToMenu(Config.Draw, "Draw Human W", true, true, true)
		Circle["Spider"]["E"]:AddToMenu(Config.Draw, "Draw Human E", true, true, true)
	
	Config:addSubMenu("Combo", "Combo")
		Config.Combo:addParam("HumanQ", "Human Q", SCRIPT_PARAM_ONOFF, true)
		Config.Combo:addParam("HumanW", "Human W", SCRIPT_PARAM_ONOFF, true)
		Config.Combo:addParam("HumanE", "Human E", SCRIPT_PARAM_ONOFF, true)
		Config.Combo:addParam("SpiderQ", "Spider Q", SCRIPT_PARAM_ONOFF, true)
		Config.Combo:addParam("SpiderW", "Spider W", SCRIPT_PARAM_ONOFF, true)
		Config.Combo:addParam("SpiderE", "Spider E", SCRIPT_PARAM_ONOFF, true)
		Config.Combo:addParam("AutoR", "Auto R", SCRIPT_PARAM_ONOFF, true)
	
	Config:addSubMenu("Harass", "Harass")
		Config.Harass:addParam("HumanQ", "Human Q", SCRIPT_PARAM_ONOFF, true)
		Config.Harass:addParam("HumanW", "Human W", SCRIPT_PARAM_ONOFF, true)
		-- Config.Harass:addParam("AutoR", "Auto Transform to human", SCRIPT_PARAM_ONOFF, true)
		AddManaChecker(Config.Harass)
	
	Config:addSubMenu("Farm", "Farm")
		Config.Farm:addParam("HumanQ", "Human Q", SCRIPT_PARAM_ONOFF, true)
		Config.Farm:addParam("HumanW", "Human W", SCRIPT_PARAM_ONOFF, true)
		Config.Farm:addParam("SpiderQ", "Spider Q", SCRIPT_PARAM_ONOFF, true)
		Config.Farm:addParam("SpiderW", "Spider W", SCRIPT_PARAM_ONOFF, true)
		-- Config.Farm:addParam("AutoR", "Auto R", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte('G'))
		AddManaChecker(Config.Farm, 60)
	
	Config:addSubMenu("Jungle", "Jungle")
		Config["Jungle"]:addParam("HumanQ", "Human Q", SCRIPT_PARAM_ONOFF, true)
		Config.Jungle:addParam("HumanW", "Human W", SCRIPT_PARAM_ONOFF, true)
		Config.Jungle:addParam("SpiderQ", "Spider Q", SCRIPT_PARAM_ONOFF, true)
		Config.Jungle:addParam("SpiderW", "Spider W", SCRIPT_PARAM_ONOFF, true)
		AddManaChecker(Config.Jungle, 60)
	
	Config:addSubMenu("Misc", "Misc")
		-- Config.Misc:addParam("Spidergapcloser", "Anti Gapcloser with Spider E", SCRIPT_PARAM_ONOFF, true)
		-- Config.Misc:addParam("Humangapcloser", "Anti Dash with Human E", SCRIPT_PARAM_ONOFF, true)
		Config.Misc:addParam("HumanInter", "Human E to Interrupt", SCRIPT_PARAM_ONOFF, true)
	
	Config:addSubMenu("Interrupt", "Interrupt")
		IT:AddToMenu(Config.Interrupt)
	
	Config:addSubMenu("Skillshot", "Skillshot")
		Config.Skillshot:addSubMenu("W", "W")
			Spell["Human"]["W"]:AddToMenu(Config.Skillshot.W)
		
		Config.Skillshot:addSubMenu("E", "E")
			Spell["Human"]["E"]:AddToMenu(Config.Skillshot.E)
end

function OnLoad()
	OnLoadMenu()
	
	SMM = SimpleMM(MINION_ENEMY, 2000, myHero, function(a, b) return GetDistance(a) < GetDistance(b) end)
	
	IT:AddCallback( function(u, s) if Config.Misc.HumanInter then Spell["Human"]["E"]:Cast(u) end end )
end

function OnTick()
	-- Cooldown --
	
	Cooldown["Human"]["Q"] = Data["Cooldown"]["Human"]["Q"] - GetGameTimer() > 0 and Data["Cooldown"]["Human"]["Q"] - GetGameTimer() or 0
	Cooldown["Human"]["W"] = Data["Cooldown"]["Human"]["W"] - GetGameTimer() > 0 and Data["Cooldown"]["Human"]["W"] - GetGameTimer() or 0
	Cooldown["Human"]["E"] = Data["Cooldown"]["Human"]["E"] - GetGameTimer() > 0 and Data["Cooldown"]["Human"]["E"] - GetGameTimer() or 0
	
	Cooldown["Spider"]["Q"] = Data["Cooldown"]["Spider"]["Q"] - GetGameTimer() > 0 and Data["Cooldown"]["Spider"]["Q"] - GetGameTimer() or 0
	Cooldown["Spider"]["W"] = Data["Cooldown"]["Spider"]["W"] - GetGameTimer() > 0 and Data["Cooldown"]["Spider"]["W"] - GetGameTimer() or 0
	Cooldown["Spider"]["E"] = Data["Cooldown"]["Spider"]["E"] - GetGameTimer() > 0 and Data["Cooldown"]["Spider"]["E"] - GetGameTimer() or 0
	
	-- Cooldown End --
	
	-- IsHuman? --
	
	Data["IsHuman"] = myHero:GetSpellData(_Q).name:lower():find("human") and true or false
	
	-- IsHuman? End --
	
	if OWM:IsComboMode() then
		Combo()
	end
	if OWM:IsHarassMode() then
		Harass()
	end
	if OWM:IsClearMode() then
		LineFarm()
		JungleFarm()
	end
end

function OnDraw()
	-- DrawText(Spell["Spider"]["E"]:GetName(), 18, 100, 100, 0xFFFF0000)
	
	if Data["IsHuman"] then
		Circle["Human"]["Q"]:Draw()
		Circle["Human"]["W"]:Draw()
		Circle["Human"]["E"]:Draw()
	else
		Circle["Spider"]["Q"]:Draw()
		-- Circle["Spider"]["W"]:Draw()
		Circle["Spider"]["E"]:Draw()
	end
end

function OnProcessSpell(unit, spell)
	if unit.isMe then
		name = spell.name
		if Data["IsHuman"] then
			-- Human
			if name == "EliseHumanQ" then Data["Cooldown"]["Human"]["Q"] = GetGameTimer() + GetCooldown(CD["Human"]["Q"][ Spell["Human"]["Q"]:GetLevel() ]) end
			if name == "EliseHumanW" then Data["Cooldown"]["Human"]["W"] = GetGameTimer() + GetCooldown(CD["Human"]["W"][Spell["Human"]["W"]:GetLevel()]) end
			if name == "EliseHumanE" then Data["Cooldown"]["Human"]["E"] = GetGameTimer() + GetCooldown(CD["Human"]["E"][Spell["Human"]["E"]:GetLevel()]) end
		else
			if name == "EliseSpiderQCast" then Data["Cooldown"]["Spider"]["Q"] = GetGameTimer() + GetCooldown(CD["Spider"]["Q"][Spell["Spider"]["Q"]:GetLevel()]) end
			if name == "EliseSpiderW" then Data["Cooldown"]["Spider"]["W"] = GetGameTimer() + GetCooldown(CD["Spider"]["W"][Spell["Spider"]["W"]:GetLevel()]) end
			if name == "EliseSpiderEInitial" then Data["Cooldown"]["Spider"]["E"] = GetGameTimer() + GetCooldown(CD["Spider"]["E"][Spell["Spider"]["E"]:GetLevel()]) end
		end
	end
end

function GetCooldown(cooldown)
	local cdr = myHero.cdr
	return (cooldown - (cooldown * cdr))
end

function IgniteDamage()
	return 50 + 20 * myHero.level
end

function Combo()
	target = STS:GetTarget(Spell["Human"]["W"].range)
	if target ~= nil then
		qd = getDmg("Q", target, myHero)
		wd = getDmg("W", target, myHero)
		if Data["IsHuman"] then
			if GetDistance(target) < Spell["Human"]["E"].range and Config.Combo.HumanE and Spell["Human"]["E"]:IsReady() then
				Spell["Human"]["E"]:Cast(target)
			end
			if GetDistance(target) <= Spell["Human"]["Q"].range and Config.Combo.HumanQ and Spell["Human"]["Q"]:IsReady() then
				Spell["Human"]["Q"]:Cast(target)
			end
			if GetDistance(target) <= Spell["Human"]["W"].range and Config.Combo.HumanW and Spell["Human"]["W"]:IsReady() then
				Spell["Human"]["W"]:Cast(target)
			end
			if not Spell["Human"]["Q"]:IsReady() and not Spell["Human"]["W"]:IsReady() and not Spell["Human"]["E"]:IsReady() and Config.Combo.AutoR and Spell["R"]:IsReady() then
				Spell["R"]:Cast()
			end
			if not Spell["Human"]["Q"]:IsReady() and not Spell["Human"]["W"]:IsReady() and GetDistance(target) <= Spell["Spider"]["Q"].range and Config.Combo.AutoR and Spell["R"]:IsReady() then
				Spell["R"]:Cast()
			end
		else
			if GetDistance(target) < Spell["Spider"]["Q"].range and Config.Combo.SpiderQ and Spell["Spider"]["Q"]:IsReady() then
				Spell["Spider"]["Q"]:Cast(target)
			end
			if GetDistance(target) < 200 and Config.Combo.SpiderW and Spell["Spider"]["W"]:IsReady() then
				CastSpell(_W)
				-- Spell["Spider"]["W"]:Cast()
			end
			if GetDistance(target) <= Spell["Spider"]["E"].range and GetDistance(target) > Spell["Spider"]["Q"].range and Config.Combo.SpiderE and Spell["Spider"]["E"]:IsReady() and not Spell["Spider"]["Q"]:IsReady() then
				-- Spell["Spider"]["E"]:Cast(target)
				if Spell["Spider"]["E"]:GetName() == "EliseSpideElnitial" then
					Spell["Spider"]["E"]:Cast()
				else
					Spell["Spider"]["E"]:Cast(target)
				end
			end
			if GetDistance(target) > Spell["Spider"]["Q"].range and not Spell["Spider"]["E"]:IsReady() and Spell["R"]:IsReady() and not Spell["Spider"]["Q"]:IsReady() and Config.Combo.AutoR then
				Spell["R"]:Cast()
			end
			if Cooldown["Human"]["Q"] == 0 and Cooldown["Human"]["W"] == 0 and Spell["R"]:IsReady() and Config.Combo.AutoR then
				Spell["R"]:Cast()
			end
			if Cooldown["Human"]["Q"] == 0 and qd >= target.health or Cooldown["Human"]["W"] == 0 and wd >= target.health and Config.Combo.AutoR then
				Spell["R"]:Cast()
			end
		end
	end
end

function Harass()
	target = STS:GetTarget(Spell["Human"]["Q"].range)
	if IsManaLow(Config.Harass.mper) then return end
	if target ~= nil then
		if Data["IsHuman"] then
			if GetDistance(target) <= Spell["Human"]["Q"].range and Config.Harass.UseQ then
				Spell["Human"]["Q"]:Cast(target)
			end
			if GetDistance(target) <= Spell["Human"]["W"].range and Config.Harass.UseW then
				Spell["Human"]["W"]:Cast(target)
			end
		else
			-- TODO
		end
	end
end

function JungleFarm()
	mobs = SMM:GetMinion(MINION_JUNGLE, Spell["Human"]["Q"].range)
	for count, minion in ipairs(mobs) do
		if Data["IsHuman"] then
			if Config.Jungle.HumanQ and Spell["Human"]["Q"]:IsReady() and minion.valid and GetDistance(minion) <= Spell["Human"]["Q"].range then
				Spell["Human"]["Q"]:Cast(minion)
			end
			if Config.Jungle.HumanW and Spell["Human"]["W"]:IsReady() and not Spell["Human"]["Q"]:IsReady() and minion.valid and GetDistance(minion) <= Spell["Human"]["W"].range then
				Spell["Human"]["W"]:Cast(minion.x, minion.z)
			end
			if not IsManaLow(Config.Jungle.mper) or (not Spell["Human"]["Q"]:IsReady() and not Spell["Human"]["W"]:IsReady()) and Spell["R"]:IsReady() then
				Spell["R"]:Cast()
			end
		else
			if Config.Jungle.SpiderQ and Spell["Spider"]["Q"]:IsReady() and minion.valid and GetDistance(minion) <= Spell["Spider"]["Q"].range then
				Spell["Spider"]["Q"]:Cast(minion)
			end
			if Config.Jungle.SpiderW and Spell["Spider"]["W"]:IsReady() and minion.valid and GetDistance(minion) <= 150 then
				Spell["Spider"]["W"]:Cast()
			end
			if Spell["R"]:IsReady() and Cooldown["Human"]["Q"] == 0 and not Spell["Spider"]["Q"]:IsReady() and not Spell["Spider"]["W"]:IsReady() then
				Spell["R"]:Cast()
			end
		end
	end
end

function LineFarm()
	mobs = SMM:GetMinion(MINION_ENEMY, Spell["Human"]["Q"].range)
	if IsManaLow(Config.Farm.mper) then return end
	for count, minion in ipairs(mobs) do
		if Data["IsHuman"] then
			if Config.Farm.HumanQ and minion.valid and Spell["Human"]["Q"]:IsReady() and GetDistance(minion) <= Spell["Human"]["Q"].range then
				Spell["Human"]["Q"]:Cast(minion)
			end
			if Config.Farm.HumanW and Spell["Human"]["W"]:IsReady() and minion.valid and GetDistance(minion) <= Spell["Human"]["W"].range then
				Spell["Human"]["W"]:Cast(minion)
			end
		else
			if Config.Farm.SpiderQ and Spell["Spider"]["Q"]:IsReady() and minion.valid and GetDistance(minion) < Spell["Spider"]["Q"].range then
				Spell["Spider"]["Q"]:Cast(minion)
			end
			if Config.Farm.SpiderW and Spell["Spider"]["W"]:IsReady() and minion.valid and GetDistance(minion) < 125 then
				Spell["Spider"]["W"]:Cast()
			end
		end
	end
end

function Killsteal()
	-- for _, enemy in ipairs(GetEnemyHeroes())do
		
	-- end
end




























-- SimpleMinionManager by SectionCore
local _minionTable = { {}, {}, {}, {}, {} }
local _SimpleMM = { init = true, tick = 0, ally = "##", enemy = "##" }
local __SimpleMM__OnCreateObj
local function SimpleMM__OnLoad()
    if _SimpleMM.init then
        local mapIndex = GetGame().map.index
        if mapIndex ~= 4 then
            _SimpleMM.ally = "Minion_T" .. player.team
            _SimpleMM.enemy = "Minion_T" .. TEAM_ENEMY
        else
            _SimpleMM.ally = (player.team == TEAM_BLUE and "Blue" or "Red")
            _SimpleMM.enemy = (player.team == TEAM_BLUE and "Red" or "Blue")
        end
        if not __SimpleMM__OnCreateObj then
            function __SimpleMM__OnCreateObj(object)
                if object and object.valid and object.type == "obj_AI_Minion" then
                    DelayAction(function(object)
                        if object and object.valid and object.type == "obj_AI_Minion" and object.name and not object.dead then
                            local name = object.name
                            table.insert(_minionTable[MINION_ALL], object)
                            if name:sub(1, #_SimpleMM.ally) == _SimpleMM.ally then table.insert(_minionTable[MINION_ALLY], object)
                            elseif name:sub(1, #_SimpleMM.enemy) == _SimpleMM.enemy then table.insert(_minionTable[MINION_ENEMY], object)
                            elseif object.team == TEAM_NEUTRAL then table.insert(_minionTable[MINION_JUNGLE], object)
                            else table.insert(_minionTable[MINION_OTHER], object)
                            end
                        end
                    end, 0, { object })
                end
            end

            AddCreateObjCallback(__SimpleMM__OnCreateObj)
        end
        for i = 1, objManager.maxObjects do
            __SimpleMM__OnCreateObj(objManager:getObject(i))
        end
        _SimpleMM.init = nil
    end
end
class'SimpleMM'
function SimpleMM:__init(mode, range, fromPos, sortMode)
    assert(type(mode) == "number" and type(range) == "number", "SimpleMM: wrong argument types (<mode>, <number> expected)")
    SimpleMM__OnLoad()
    self.mode = mode
    self.range = range
    self.fromPos = fromPos or player
    self.sortMode = type(sortMode) == "function" and sortMode
    self.objects = {}
    self.iCount = 0
    self:update()
end
function SimpleMM:update()
    self.objects = {}
    for _, object in pairs(_minionTable[self.mode]) do
        if object and object.valid and not object.dead and object.visible and GetDistanceSqr(self.fromPos, object) <= (self.range) ^ 2 then
            table.insert(self.objects, object)
        end
    end
    if self.sortMode then table.sort(self.objects, self.sortMode) end
    self.iCount = #self.objects
end
function SimpleMM:SetSource(source)
	assert(source "SimpleMM:SetSource source cannot be nil")
	self.fromPos = source
end
function SimpleMM:SetRange(range)
	self.range = range
end
function SimpleMM:GetMinion(mode, range, forceSource)
	_from = forceSource or self.fromPos
	result = {}
    for _, object in pairs(_minionTable[mode]) do
        if object and object.valid and not object.dead and object.visible and GetDistanceSqr(_from, object) <= (range) ^ 2 then
            table.insert(result, object)
        end
    end
	if self.sortMode then table.sort(result, self.sortMode) end
    return result
end