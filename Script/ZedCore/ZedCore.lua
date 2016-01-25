-- XD
if myHero.charName ~= "Zed" then return end

function Check(file_name)
	local file_found=io.open(file_name, "r")      

	if file_found==nil then
		return false
	else
		return true
	end
	return file_found
end
function Rename(from, to)
	if Check(from) then
		os.rename(from, to)
	else
		return nil
	end
end

local ScriptName = "ZedCore"
printMessage = function(message) print("<font color=\"#6699ff\"><b>" .. ScriptName .. ":</b></font> <font color=\"#FFFFFF\">" .. message .. "</font>") end
-- Rename(LIB_PATH.."SourceLib_Fix.lua", "SourceLibk.lua")
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

local VERSION = 1.1
SimpleUpdater("[ZedCore]", VERSION, "raw.github.com" , "/UnrealCore/GithubForBotOfLegends/master/Script/ZedCore/ZedCore.lua" , SCRIPT_PATH .. "ZedCore.lua" , "/UnrealCore/GithubForBotOfLegends/master/Script/ZedCore/ZedCore.version" ):CheckUpdate()

local DangerousList = {
	"AatroxQ",
	"AhriSeduce",
	"CurseoftheSadMummy",
	"InfernalGuardian", 
	"EnchantedCrystalArrow",
	"AzirR", 
	"BrandWildfire",
	"CassiopeiaPetrifyingGaze",
	"DariusExecute",
	"DravenRCast",
	"EvelynnR",
	"EzrealTrueshotBarrage",
	"Terrify",
	"GalioIdolOfDurand",
	"GarenR",
	"GravesChargeShot",
	"HecarimUlt",
	"LissandraR",
	"LuxMaliceCannon",
	"UFSlash",                
	"AlZaharNetherGrasp",
	"OrianaDetonateCommand",
	"LeonaSolarFlare",
	"SejuaniGlacialPrisonStart",
	"SonaCrescendo",
	"VarusR",
	"GragasR",
	"GnarR",
	"FizzMarinerDoom",
	"SyndraR",
}

local OWM = OrbWalkManager(ScriptName)
local STS = SimpleTS()
local DLib = DamageLib()
local CM = DrawManager()

function OrbwalkToPosition(position)
	if position ~= nil then
		if _G.MMA_Loaded then
			_G.moveToCursor(position.x, position.z)
		elseif _G.AutoCarry and _G.AutoCarry.Orbwalker then
			_G.AutoCarry.Orbwalker:OverrideOrbwalkLocation(position)
		end
	else
		if _G.MMA_Loaded then
			return
		elseif _G.AutoCarry and _G.AutoCarry.Orbwalker then
			_G.AutoCarry.Orbwalker:OverrideOrbwalkLocation(nil)
		end
	end
end

function Contain(table, value)
	for _, v in ipairs(table) do
		if(v == value)then
			return true
		end
	end
	return false
end

function Extends(v1, v2, v3)
	return Vector(v1) + (Vector(v2) - Vector(v1)):normalized() * (GetDistance(v1, v2)+v3)
end

function GetNearObjectCount(source, range, objects)
	local count = 0
	for _, o in ipairs(objects) do
		if(GetDistance(o, source) < range) then
			count = count + 1
		end
	end
	return count
end

function GetMyTryeRange()
	return myHero.range+GetDistance(myHero.minBBox)/2 
end

function OnLoad()
	Main = Main()
end

class("Main")
function Main:__init()
	self:Initialization()
	self.shadowdelay = 0
	self.delayw = 500
end

function Main:Initialization()
	self.Q = Spell(_Q, 900)
	self.Q:SetSkillshot(SKILLSHOT_LINEAR, 50, 0.25, 1700)
	self.W = Spell(_W, 550)
	self.E = Spell(_E, 270)
	self.R = Spell(_R, 650)
	
	self.LastCast = nil
	self.Shadow = {}
	
	self.minionTable = minionManager(MINION_ENEMY, 1400, myHero, MINION_SORT_MAXHEALTH_DEC)
	self.jungleTable = minionManager(MINION_JUNGLE, 1400, myHero, MINION_SORT_MAXHEALTH_DEC)
	
	CM:CreateCircle(myHero, self.Q.range, 1, {100, 255, 0, 0}, "Draw Q range")
	CM:CreateCircle(myHero, self.W.range, 1, {100, 255, 0, 0}, "Draw W range")
	CM:CreateCircle(myHero, self.E.range, 1, {100, 255, 0, 0}, "Draw E range")
	CM:CreateCircle(myHero, self.R.range, 1, {100, 255, 0, 0}, "Draw R range")
	
	DLib:RegisterDamageSource(_Q, _PHYSICAL, 75, 40, _PHYSICAL, _BONUS_AD, 1, function() return myHero:CanUseSpell(_Q) end)
	DLib:RegisterDamageSource(_E, _PHYSICAL, 60, 30, _PHYSICAL, _BONUS_AD, 0.9, function() return myHero:CanUseSpell(_E) end)
	DLib:RegisterDamageSource(_R, _PHYSICAL, 0, 0, _PHYSICAL, _AD, 1, function() return myHero:CanUseSpell(_R) end)
	DLib:RegisterDamageSource(_Bilge, _MAGIC, 100, 0, _MAGIC, _AP, 0, function() return self.Blade:IsReady() end)
	
	self.IgniteSlot = GetSummonerSlot("summonerdot")
	-- _IGNITE = self.IgniteSlot
	
	self.IGNITE = Spell(self.IgniteSlot, 600)
	
	self.Config = scriptConfig(ScriptName, ScriptName)
	
	self.Config:addSubMenu("OrbWalk", "OrbWalk")
		OWM:AddToMenu(self.Config.OrbWalk)
	
	self.Config:addSubMenu("TargetSelecter", "TargetSelecter")
		STS:AddToMenu(self.Config.TargetSelecter)
	
	self.Config:addSubMenu("DamageLib", "DamageLib")
		DLib:AddToMenu(self.Config.DamageLib, {})
	
	self.Config:addSubMenu("Draw", "Draw")
		CM:AddToMenu(self.Config.Draw)
	
	self.Config:addSubMenu("Combo", "Combo")
		self.Config.Combo:addParam("UseW", "Use W", SCRIPT_PARAM_ONOFF, true)
		self.Config.Combo:addParam("UseIgnite", "Use Ignite", SCRIPT_PARAM_ONOFF, true)
		self.Config.Combo:addParam("UseUlt", "Use Ultimate", SCRIPT_PARAM_ONOFF, true)
		self.Config.Combo:addParam("TheLine", "Line Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('T'))
	
	self.Config:addSubMenu("Harass", "Harass")
		self.Config.Harass:addParam("longhar", "Long Poke", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte('U'))
		--self.Config.Harass:addParam("UseItem", "Use Tiamat/Hydra", SCRIPT_PARAM_ONOFF, true)
		self.Config.Harass:addParam("UseW", "Use W", SCRIPT_PARAM_ONOFF, true)
	
	
	self.Config:addSubMenu("LineClear", "LineClear")
		--self.Config.LineClear:addParam("UseItem", "Use Hydra/Tiamat", SCRIPT_PARAM_ONOFF, true)
		self.Config.LineClear:addParam("UseQ", "Use Q LineClear", SCRIPT_PARAM_ONOFF, true)
		self.Config.LineClear:addParam("UseE", "Use E LineClear", SCRIPT_PARAM_ONOFF, true)
		self.Config.LineClear:addParam("Energy", "Energy >", SCRIPT_PARAM_SLICE, 45, 1, 100)
	
	self.Config:addSubMenu("LastHit", "LastHit")
		self.Config.LastHit:addParam("UseQ", "Use Q LastHit", SCRIPT_PARAM_ONOFF, true)
		self.Config.LastHit:addParam("UseE", "Use E LastHit", SCRIPT_PARAM_ONOFF, true)
		self.Config.LastHit:addParam("Energy", "Energy >", SCRIPT_PARAM_SLICE, 45, 1, 100)
	
	self.Config:addSubMenu("JungleClear", "JungleClear")
		self.Config.JungleClear:addParam("UseQ", "Use Q JungleClear", SCRIPT_PARAM_ONOFF, true)
		self.Config.JungleClear:addParam("UseW", "Use W JungleClear", SCRIPT_PARAM_ONOFF, true)
		self.Config.JungleClear:addParam("UseE", "Use E JungleClear", SCRIPT_PARAM_ONOFF, true)
		self.Config.JungleClear:addParam("Energy", "Energy >", SCRIPT_PARAM_SLICE, 45, 1, 100)
	
	self.Config:addSubMenu("Misc", "Misc")
		self.Config.Misc:addParam("UseIgnite", "Use Ignite Killsteal", SCRIPT_PARAM_ONOFF, true)
		self.Config.Misc:addParam("UseQ", "Use Q Killsteal", SCRIPT_PARAM_ONOFF, true)
		self.Config.Misc:addParam("UseE", "Use E Killsteal", SCRIPT_PARAM_ONOFF, true)
		self.Config.Misc:addParam("AutoE", "Auto E", SCRIPT_PARAM_ONOFF, true)
		self.Config.Misc:addParam("rdodge", "R Dodge Dangerous", SCRIPT_PARAM_ONOFF, true)
		for _, e in ipairs(GetEnemyHeroes()) do
			name = e:GetSpellData(_R).name;
			if(Contain(DangerousList, name))then
				self.Config.Misc:addParam("ds"..name, "Dodge "..name, SCRIPT_PARAM_ONOFF, true)
			end
		end
	
	self.Config:addSubMenu("SS", "SS")
		self.Q:AddToMenu(self.Config.SS)
	
	AddTickCallback(function() self:OnTick() end)
	AddProcessSpellCallback(function(unit, spell) self:OnProcessSpell(unit, spell) end)
	-- AddCreateObjCallback(function(obj) self:OnCreateObj(obj) end)
	AddDrawCallback(function() self:Draw() end)
	AddAnimationCallback(function(unit, anim) self:Anim(unit, anim) end)
end

function Main:Anim(unit, anim)
	if unit.team == myHero.team and unit.name == "Shadow" then
		if(anim:lower():find("idle"))then
			table.insert(self.Shadow, unit)
		end
		if(anim:lower():find("death"))then
			for i = 1, #self.Shadow do
				if(Vector(self.Shadow[i]) == Vector(unit))then
					table.remove(self.Shadow, i)
				end
			end
		end
	end
	-- print(unit.name.." : "..anim..)
end

function Main:Draw()
	-- if(self:WShadow())then
		-- DrawCircle(self:WShadow().x, self:WShadow().y, self:WShadow().z, 100, ARGB(100, 255, 0, 0))
	-- end
end

function Main:OnProcessSpell(unit, spell)
	if(unit.type ~= myHero.type)then return end
	if(unit.team ~= myHero.team)then
		if(self.Config.Misc.rdodge and self.R:IsReady() and self:UltStat() == 1 and self.Config.Misc["ds"..spell.name])then
			if(Contain(DangerousList, spell.name) and (GetDistance(unit) < 650 or GetDistance(spell.endPos) <= 250))then
				if(spell.name == "SyndraR")then
					self.clockon = GetTickCount() + 150
					self.countdanger = countdanger + 1;
				else
					target = STS:GetTarget(640)
					if(target ~= nil)then
						self.R:Cast(target)
					end
				end
			end
		end
	end
	if(unit.isMe and spell.name == "zedult")then
		self.tickock = GetTickCount() + 200;
	end
	if(unit.isMe)then
		self.LastCast = spell
	end
	if(spell.name == self.R:GetName())then
		self.rpos = Vector(spell.startPos)
	end
end

function Main:OnCreateObj(obj)
	-- if(obj.name == "Shadow")then
		-- table.insert(self.Shadow, obj)
	-- end
end

function Main:OnTick()
	if(OWM:IsComboMode())then
		self:Combo()
	end
	if(self.Config.Combo.TheLine)then
		self:TheLine()
	end
	if(OWM:IsHarassMode())then
		self:Harass()
	end
	if(OWM:IsClearMode())then
		self:JungleClear()
		self:LineClear()
	end
	if(OWM:IsLastHitMode())then
		self:LastHit()
	end
	
	-- if(self.LastCast ~= nil and self.LastCast.name == self.R:GetName() and self.Shadow ~= nil )then
		-- self.rpos = Vector(self.Shadow)
	-- end
	self:Killsteal()
end

function Main:GetComboDamage(enemy)
	damage = 0;
	damage = damage + DLib:CalcComboDamage(enemy, {_Q, _E, _R})
	if(self.W:IsReady())then
		damage = damage + DLib:CalcComboDamage(enemy, {_Q})/2
	end
	if(self.Tiamat:IsReady())then
		-- damage = damage +
	end
	if(self.Hydra:IsReady())then
		-- damage = damage + 
	end
	if(self.Blade:IsReady())then
		local AddDamage
		if((enemy.maxHealth * 0.1) > 100) then
			AddDamage = enemy.maxHealth * 0.1
		else
			AddDamage = 100
		end
		damage = damage + AddDamage
	end
	damage = damage + (self.R:GetLevel() * 0.15 + 0.05 ) * ( damage - IgniteDamage())
	return damage
end

function Main:Combo()
	local target = STS:GetTarget(1400)
	if target == nil then return end
	local overkill = DLib:CalcComboDamage(target, {_Q, _E}) + getDmg("AD", target , myHero) * 2
	
	if(self.Config.Combo.UseUlt and self.R:IsReady() and self:UltStat() == 1 and (overkill > target.health or (not self.W:IsReady() and DLib:CalcComboDamage(target, {_Q}) < target.health and GetDistance(target) > 400)))then
		if((GetDistance(target) > 700 and target.ms > myHero.ms or GetDistance(Vector(target)) > 800 )) then
			self:CastW(target);
			self.W:Cast()
		end
		-- print("CastR")
		CastSpell(_R, target)
		-- self.R:Cast(target);
	else
		if(target ~= nil and self.Config.Combo.UseIgnite and self.IgniteSlot ~= nil and self.IGNITE:IsReady())then
			if(self:GetComboDamage(target) > target.health or HasBuff(target, "zedulttargetmark"))then
				self.IGNITE:Cast(target)
			end
		end
		if(target~= nil and self:ShadowStage() == 1 and self.Config.Combo.UseW and GetDistance(target) > 400 and GetDistance(target) < 1300)then
			self:CastW(target)
		end
		if(target ~= nil and self:ShadowStage() == 2 and self.Config.Combo.UseW and GetDistance(Vector(self:WShadow())) < GetDistance(Vector(target)))then
			self.W:Cast()
		end
		
		-- self:UseItem(target)
		self:CastE()
		self:CastQ(target)
	end
end

function Main:TheLine()
	local target = STS:GetTarget(1400)
	
	if(target == nil)then
		OrbwalkToPosition(mousePos)
	elseif(target ~= nil)then
		OrbwalkToPosition(target)
	end
	if target == nil then return end
	if(not self.R:IsReady() or GetDistance(target) >= 640 ) then return end
	
	if(self:UltStat() == 1 ) then CastSpell(_R, target) end
	
	linepos = Extends(target, myHero, -500)
	
	if(target ~= nil and self:ShadowStage() == 1 and self:UltStat() == 2)then --  
		-- self:UseItem(target);
		-- if(self.LastCast.name ~= self.W:GetName())then
			self.W:Cast(linepos);
			self:CastE()
			self:CastQ(target)
			
			-- if(target ~= nil and Config.Combo.UseIgnite and self.IgniteSlot ~= nil and self.IGNITE:IsReady())then
				-- self.IGNITE:Cast(target)
			-- end
		-- end
	end
	
	if(target ~= nil and self:WShadow() ~= nil and self:UltStat() == 2 and GetDistance(target) > 250 and GetDistance(Vector(self:WShadow()), target) < GetDistance(target))then
		self.W:Cast()
	end
end

function Main:Harass()
	local target = STS:GetTarget(1400)
	if target == nil then return end
	if(target and self.Config.Harass.longhar and self.Q:IsReady() and self.W:IsReady() and myHero.mana > myHero:GetSpellData(_Q).mana + myHero:GetSpellData(_W).mana and GetDistance(target) > 850 and GetDistance(target) < 1400 ) then
		self:CastW(target)
	end
	
	if(target and (self:ShadowStage() == 2 or not self.W:IsReady() or not self.Config.Harass.UseW) and self.Q:IsReady() and (GetDistance(target) <= 900 or GetDistance(self:WShadow(), target) <= 900))then
		self:CastQ(target)
	end
	
	if(target and self.W:IsReady() and self.Q:IsReady() and self.Config.Harass.UseW and myHero.mana > myHero:GetSpellData(_Q).mana + myHero:GetSpellData(_W).mana)then
		if(GetDistance(target)<750)then
			self:CastW(target)
		end
	end
	
	self:CastE()
end

function Main:LineClear()
	self.minionTable:update()
	
	mana = myHero.mana >= (myHero.maxMana*self.Config.LineClear.Energy/100)
	
	if(not mana)then return end
	
	if(self.Q:IsReady() and self.Config.LineClear.UseQ)then
		pos, hit = GetBestLineFarmPosition(self.Q.range, 50, self.minionTable.objects)
		-- print(hit)
		if(hit >= 3)then
			self.Q:SetSourcePosition(myHero)
			self.Q:Cast(pos.x, pos.z)
		else
			for _, m in ipairs(self.minionTable.objects) do
				if(not (GetMyTryeRange() > GetDistance(m)) and m.health < 0.75*DLib:CalcComboDamage(m, {_Q}))then
					self.Q:Cast(pos.x, pos.z)
				end
			end
		end
	end
	if(self.E:IsReady() and self.Config.LineClear.UseE)then
		value = GetNearObjectCount(myHero, self.E.range, self.minionTable.objects)
		if(value > 2)then
			self.E:Cast()
		else
			for _, m in ipairs(self.minionTable.objects) do
				if(not (GetMyTryeRange() > GetDistance(m)) and m.health < 0.75*DLib:CalcComboDamage(m, {_E}))then
					self.E:Cast()
				end
			end
		end
	end
end

function Main:LastHit()
	self.minionTable:update()
	
	mana = myHero.mana >= (myHero.maxMana*self.Config.LastHit.Energy/100)
	
	if not mana then return end
	
	for _, minion in ipairs(self.minionTable.objects)do
		if(self.Config.LastHit.UseQ and self.Q:IsReady() and GetDistance(minion) < self.Q.range and minion.health < 0.75 * DLib:CalcComboDamage(minion, {_Q}))then
			self.Q:SetSourcePosition(myHero)
			self.Q:Cast(minion)
		end
		
		if(self.Config.LastHit.UseQ and self.E:IsReady() and GetDistance(minion) < self.E.range and minion.health < 0.75 * DLib:CalcComboDamage(minion, {_E}))then
			self.E:Cast()
		end
	end
end

function Main:JungleClear()
	self.jungleTable:update()
	
	mana = myHero.mana >= (myHero.maxMana*self.Config.JungleClear.Energy/100)
	if(#self.jungleTable.objects>0 and mana )then
		mob = self.jungleTable.objects[1]
		if(self.W:IsReady() and GetDistance(mob) < self.Q.range)then
			self.W:Cast(Vector(mob))
		end
		if(self.Q:IsReady() and GetDistance(mob) < self.Q.range )then
			self:CastQ(mob)
		end
		if(self.E:IsReady() and GetDistance(mob) < self.E.range )then
			self.E:Cast()
		end
	end
end

function Main:Killsteal()
	target = STS:GetTarget(2000, 1, STS_LOW_HP_PRIORITY)
	if target == nil then return end
	igniteDmg = IgniteDamage()
	if(target.valid and self.Config.Misc.UseIgnite and self.IgniteSlot ~= nil and self.IGNITE:IsReady())then
		if(igniteDmg > target.health and GetDistance(target) <= self.IGNITE.range)then
			self.IGNITE:Cast(target)
		end
	end
	if(target.valid and self.Q:IsReady() and self.Config.Misc.UseQ and DLib:CalcComboDamage(target, {_Q}) > target.health)then
		if(GetDistance(target) <= self.Q.range)then
			self.Q:SetSourcePosition(Vector(myHero))
			self.Q:Cast(target)
		elseif (self.WShadow() ~= nil and GetDistance(self.WShadow(), target) <= self.Q.range )then
			self.Q:SetSourcePosition(Vector(self.WShadow()))
			self.Q:Cast(target)
		elseif (self.RShadow() ~= nil and GetDistance(self.RShadow(), target) <= self.Q.range )then
			self.Q:SetSourcePosition(Vector(self.RShadow()))
			self.Q:Cast(target)
		end
	end
	if(target.valid and self.R:IsReady() and self.Config.Misc.UseE)then
		t = STS:GetTarget(self.E.range, 1, STS_LOW_HP_PRIORITY)
		if(DLib:CalcComboDamage(t, {_E}) > t.health and (GetDistance(target) <= self.E.range or GetDistance(target, self:WShadow()) <= self.E.range))then
			self.E:Cast()
		end
	end
end


function Main:UltStat()
	if(self.R:GetName() == "ZedR")then
		return 1
	end
	return 2
end

function Main:ShadowStage()
	if(self.W:GetName() == "ZedW")then
		return 1
	end
	return 2
end 

function Main:WShadow()
	for _, data in ipairs(self.Shadow)do
		if(data and data.valid and Vector(data) ~= Vector(self.rpos) and data.name == "Shadow") then return data end
	end
	return nil
end

function Main:RShadow()
	for _, data in ipairs(self.Shadow)do
		if(data and data.valid and Vector(data) == Vector(self.rpos) and data.name == "Shadow") then return data end
	end
	return nil
end

function Main:CastW(target)
	if(self.delayw >= GetTickCount() - self.shadowdelay or self:ShadowStage() ~= 1 or HasBuff(target, "zedulttargetmark") and self.R:IsReady()) then return end
	
	local wPos = Extends(target, myHero, -200)
	self.W:Cast(wPos.x, wPos.z)
	self.shadowndelay = GetTickCount()
end

function Main:CastQ(target)
	if not self.Q:IsReady() then return end
	local WShadow = self:WShadow()
	if(WShadow ~= nil and GetDistance(WShadow) <= 900 and GetDistance(target) > 450) then
		self.Q:SetSourcePosition(Vector(WShadow))
		self.Q:Cast(target)
	else
		self.Q:SetSourcePosition(Vector(myHero))
		if(GetDistance(target) < 900)then
			self.Q:Cast(target)
		end
	end
end

function Main:CastE()
	if not self.E:IsReady() then return end
	if(GetNearObjectCount(myHero, self.E.range, GetEnemyHeroes()) > 0)then
		self.E:Cast()
	end
	if(self:WShadow() ~= nil and GetNearObjectCount(self:WShadow(), self.E.range, GetEnemyHeroes()) > 0 )then
		self.E:Cast()
	end
end

-- function Main:Killsteal()
	-- target = STS:GetTarget(2000, 1, STS_LOW_HP_PRIORITY)
	-- if target == nil then return end
	-- if(target.valid and self.Config.Misc.UseIgnite and self.IgniteSlot ~= nil and self.IGNITE:IsReady())then
		-- if(IgniteDamage() > target.health and GetDistance(target) < self.IGNITE.range)then
			-- self.IGNITE:Cast(target)
		-- end
	-- end
-- end

function IgniteDamage()
	return 50 + 20 * myHero.level
end