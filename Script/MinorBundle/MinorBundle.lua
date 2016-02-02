--[[

]]

local SupHero = {
	["Urgot"] = true,
	["Shen"] = true,
}

if not SupHero[myHero.charName] then return end

local ScriptInfo = { -- Do Not change this values
	["Author"] = "SectionCore",
	["Script"] = {
		["Host"] = "raw.github.com",
		["Download"] = "/UnrealCore/GithubForBotOfLegends/master/Script/MinorBundle/MinorBundle.lua",
		["Version"] = "/UnrealCore/GithubForBotOfLegends/master/Script/MinorBundle/MinorBundle.version",
	},
	["Version"] = 1.0,
	["AutoUpdate"] = true,
}
local Colors = { 
    -- O R G B
    Green   =  ARGB(255, 000, 180, 000), 
    Yellow  =  ARGB(255, 255, 215, 000),
    Red     =  ARGB(255, 255, 000, 000),
    White   =  ARGB(255, 255, 255, 255),
    Blue    =  ARGB(255, 000, 000, 255),
	Orange	=  ARGB(255, 255, 125, 000),
	Black	=  ARGB(150, 000, 000, 000),
}
local Colors2 = { 
    -- O R G B
    Green   =  {255, 0, 180, 0}, 
    Yellow  =  {255, 255, 215, 00},
    Red     =  {255, 255, 0, 0},
    White   =  {255, 255, 255, 255},
    Blue    =  {255, 0, 0, 255},
}
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

SimpleUpdater("[MinorBundle]", ScriptVersion, "raw.github.com" , "/UnrealCore/GithubForBotOfLegends/master/Script/MinorBundle/MinorBundle.lua" , SCRIPT_PATH .. "MinorBundle.lua" , "/UnrealCore/GithubForBotOfLegends/master/Script/MinorBundle/MinorBundle.version" ):CheckUpdate()

-- sup
class('Urgot')
class('Shen')
class('Karthus')

local ScriptName = "MB " .. myHero.charName

-- SourceLibk initialization

local OWM = OrbWalkManager()
local STS = SimpleTS()
local DLib = DamageLib()
local DM = DrawManager()
local AGC = AntiGapcloser()
local IT = Interrupter()
local SORT_CLOSE = function(a, b) return GetDistance(a) < GetDistance(b) end

local SMM
local Buffs = {}
local BuffTypes = {
	["debuff"] 		= 3,
	["stun"]		= 5,
	["taunt"]		= 8,
	["slow"]		= 10,
	["root"]		= 11,
	["fear"]		= 21,
	["charm"]		= 22,
	["suppress"]	= 24,
	["flee"]		= 28,
	["knockup"]		= 29,
}

local LBClicked = false

-- OrbWalkManager expend functions

function OrbWalkManager:EnableMovement()
	if self.MMALoad then
		_G.MMA_AvoidMovement(false)
	elseif self.SacLoad then
		_G.AutoCarry.MyHero:MovementEnabled(true)
	elseif self.SxOLoad then
	
	elseif self.NOLLoad then
		--self.NOL
	end
end
function OrbWalkManager:DisableMovement()
	if self.MMALoad then
		_G.MMA_AvoidMovement(true)
	elseif self.SacLoad then
		_G.AutoCarry.MyHero:MovementEnabled(false)
	elseif self.SxOLoad then
	
	elseif self.NOLLoad then
		--self.NOL
	end
end
function OrbWalkManager:EnableAttack()
	if self.MMALoad then
		_G.MMA_StopAttacks(false)
	elseif self.SacLoad then
		G.AutoCarry.MyHero:AttacksEnabled(true)
	elseif self.SxOLoad then
		self.SxO:EnableAttacks()
	elseif self.NOLLoad then
		self.NOL:SetAA(true)
	end
end
function OrbWalkManager:DisableAttack()
	if self.MMALoad then
		_G.MMA_StopAttacks(true)
	elseif self.SacLoad then
		 _G.AutoCarry.MyHero:AttacksEnabled(false)
	elseif self.SxOLoad then
		self.SxO:DisableAttacks()
	elseif self.NOLLoad then
		self.NOL:SetAA(false)
	end
end

-- OrbWalkManager expect functions end

-- Buffs

function OnApplyBuff(source, unit, buff)
	if unit and buff and buff.name and buff.valid then
		data = {unit = unit, name = buff.name, type = buff.type, stack = 1}
		table.insert(Buffs, data)
	end
end
function OnUpdateBuff(unit, buff, stacks)
	if unit and buff and buff.name and stacks then
		for _, b in ipairs(Buffs)do
			if b.name == buff.name then
				b.stack = stacks
			end
		end
	end
end
function OnRemoveBuff(unit, buff)
	if unit and buff and buff.name and buff.valid then
		for i, b in ipairs(Buffs)do
			if b.name == buff.name then
				table.remove(Buffs, i)
			end
		end
	end
end
function GetBuffCount(unit, buffname)
	for _, b in ipairs(Buffs) do
		if b.name == buffname then return true end
	end
	return false
end
-- function HasBuff(unit, buffname)
	-- for _, b in ipairs(Buffs) do
		-- if b.type == buffname then return true end
	-- end
	-- return false
-- end
function HasBuffType(unit, _bt)
	if type(_bt) == "number" then
		if BuffType[unit.networkID][_bt] == nil then return false end
		return true
	elseif type(_by) == "string" then
		if BuffType[unit.networkID][BuffTypes[_bt:lower()]] == nil then return false end
		return true
	end
end

-- Buffs end

-- button check

function OnWndMsg(msg, wParam)
	if msg == 513 then
		-- print("Mouse Left Click")
		LBClicked = true
	elseif msg == 514 then
		-- print("Mouse Left Release")
		LBClicked = false
	end
end

-- button check end

function OnLoad()
	SMM = SimpleMM(MINION_ENEMY, 2000, myHero, function(a, b) return GetDistance(a) < GetDistance(b) end)
	if myHero.charName == "Shen" then
		champ = Shen()
	elseif myHero.charName == "Urgot" then
		champ = Urgot()
	end
end
function AddManaChecker(m, v)
	per = v or 40
	m:addParam("mper", "dont use if my mana <= (%)", per, 1, 100)
end
function AddSkillshotMenu(m, spells)
	for index, spell in ipairs(spells) do
		m:addSubMenu(SpellToString(spell.spellId) .. " Setting", "sp"..tostring(index))
		spell:AddToMenu(m["sp"..tostring(index)])
	end
end
function IsManaLow(per)
	if per == nil then return false end
	return ((myHero.mana / myHero.maxMana * 100) <= per)
end
function GetPredicHealth(target, delay)
	local PredHelth
	if _G.srcLib.HP ~= nil then
		PredHelth = _G.srcLib.HP:PredictHealth(target, delay)
	elseif _G.srcLib.VP ~= nil then
		PredHelth = _G.srcLib.VP:GetPredictedHealth(target, 0, delay)
	else
		PredHelth = minion.health
	end
	return PredHelth
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
function CountHits(points, objects, _s, _w)
	source = _s or myHero
	width = _w and _w/2 or 20
	result = 0
	from = Vector(points)
	to = Vector(source)
	From = from + ( from - to ):normalized()
	FromL = From + ( to - from ):perpendicular():normalized() * width
	FromR = From + ( to - from ):perpendicular2():normalized() * width
	To = to + ( to - from ):normalized()
	ToL = To + ( to - from ):perpendicular():normalized() * width
	ToR = To + ( to - from ):perpendicular2():normalized() * width
	
	StartL = WorldToScreen(D3DXVECTOR3(FromL.x, FromL.y, FromL.z))
	StartR = WorldToScreen(D3DXVECTOR3(FromR.x, FromR.y, FromR.z))
	
	EndL = WorldToScreen(D3DXVECTOR3(ToL.x, ToL.y, ToL.z))
	EndR = WorldToScreen(D3DXVECTOR3(ToR.x, ToR.y, ToR.z))
	
	poly = Polygon( Point(StartL.x, StartL.y), Point(StartR.x, StartR.y), Point(EndL.x, EndL.Y), Point(EndR.x, EndR.y) )
	for _, object in ipairs(objects) do
		if object.valid and objects.dead and GetDistance(object) < self.Q.range then
			objScreen = WorldToScreen(D3DXVECTOR3(object.x, object.y, object.z))
			objPoint = Point(objScreen.x, objScreen.y)
			if poly:contains(objPoint) then
				result = result + 1
			end
		end
	end
	return result
end
function Extends(v1, v2, v3)
	return Vector(v1) + (Vector(v2) - Vector(v1)):normalized() * v3
end
function Extends2(v1, v2, v3)
	return Vector(v1) + (Vector(v2) - Vector(v1)):normalized() * (GetDistance(v1, v2)+v3)
end

--Urgot

function Urgot:__init()
	self.Q = Spell(_Q, 1000)
	self.Q:SetSkillshot(SKILLSHOT_LINEAR, 75, 0.5, 1000, true) -- non target
	self.Q2 = Spell(_Q, 1000)
	self.Q2:SetSkillshot(SKILLSHOT_CIRCULAR, 300, 0.5, 1000)
	self.W = Spell(_W, 0)
	self.E = Spell(_E, 900)
	self.E:SetSkillshot(SKILLSHOT_CIRCULAR, 300, 0.8, 1500)
	
	DM:CreateCircle(myHero, self.Q.range, 1, Colors2.Red, "Draw Q range")
	DM:CreateCircle(myHero, self.E.range, 1, Colors2.Red, "Draw E range")
	
	self.Config = scriptConfig(ScriptName, ScriptName)
	
	self.Config:addSubMenu("OrbWalkManager", "OrbWalkManager")
		OWM:AddToMenu(self.Config.OrbWalkManager)
	
	self.Config:addSubMenu("TargetSelector", "TargetSelector")
		STS:AddToMenu(self.Config.TargetSelector)
	
	self.Config:addSubMenu("DrawManager", "DrawManager")
		DM:AddToMenu(self.Config.DrawManager)
	
	self.Config:addSubMenu("Interrupter", "Interrupter")
		IT:AddToMenu(self.Config.Interrupter)
		
	self.Config:addSubMenu("AntiGapcloser", "AntiGapcloser")
		AGC:AddToMenu(self.Config.AntiGapcloser)
	
	self.Config:addSubMenu("Combo", "Combo")
		self.Config.Combo:addParam("UseQ", "UseQ", SCRIPT_PARAM_LIST, 2, {"ALWAYS", "ONLY HAS BUFF", "OFF"})
		self.Config.Combo:addParam("UseE", "UseE", SCRIPT_PARAM_ONOFF, true)
	
	self.Config:addSubMenu("Harass", "Harass")
		self.Config.Harass:addParam("UseQ", "UseQ", SCRIPT_PARAM_LIST, 2, {"ALWAYS", "ONLY HAS BUFF", "OFF"})
		self.Config.Harass:addParam("UseE", "UseE", SCRIPT_PARAM_ONOFF, true)
		AddManaChecker(self.Config.Harass)
		
	self.Config:addSubMenu("Farm", "Farm")
		self.Config.Farm:addParam("UseQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
		AddManaChecker(self.Config.Farm)
	
	self.Config:addSubMenu("Misc", "Misc")
		self.Config.Misc:addParam("AutoW", "Auto W when casting q", SCRIPT_PARAM_ONOFF, true)
	
	self.Config:addSubMenu("Skillshot","SS")
		AddSkillshotMenu(self.Config.SS, {self.Q, self.Q2, self.E})
	
	AddTickCallback(function() self:Tick() end)
	AddProcessSpellCallback(function(unit, spell) self:OnProcessSpell(unit, spell) end)
end
function Urgot:Tick()
	if OWM:IsComboMode() then
		self:Combo()
	elseif OWM:IsHarassMode() then
		self:Harass()
	elseif OWM:IsClearMode() then
		-- TODO
	elseif OWM:IsLastHitMode() then
		self:LastHit()
	end
end
function Urgot:Combo()
	target = STS:GetTarget(self.Q.range)
	if target ~= nil then
		if self.Config.Combo.UseQ < 3 and self:IsForceTarget(target) then
			self.Q2:Cast(target)
			-- print("Good")
		elseif self.Config.Combo.UseQ < 2 then
			self.Q:Cast(target)
		end
		if self.Config.Combo.UseE then
			self.E:Cast(target)
		end
	end
end
function Urgot:Harass()
	if IsManaLow(self.Config.Harass.mper) then return end
	target = STS:GetTarget(self.Q.range)
	if target ~= nil then
		if self.Config.Harass.UseQ < 3 and self:IsForceTarget(target) then
			self.Q2:Cast(target)
		elseif self.Config.Harass.UseQ < 2 then
			self.Q:Cast(target)
		end
		if self.Config.Harass.UseE then
			self.E:Cast(target)
		end
	end
end
function Urgot:LastHit()
	if IsManaLow(self.Config.Farm.mper) then return end
	for index, minion in ipairs(SMM:GetMinion(MINION_ENEMY, self.Q.range)) do
		if ValidTarget(minion, self.Q.range) and GetDistance(minion) < self.Q.range and self.Q:IsReady() and getDmg("Q", minion, myHero) > minion.health and self.Config.Farm.UseQ then
			h = GetPredicHealth(minion, 0.5)
			if h > 0 then
				pos, hit = self.Q:GetPrediction(minion)
				if pos and hit > 0 then
					self.Q:Cast(pos.x, pos.z)
				end
			end
		end
	end
end
function Urgot:OnProcessSpell(unit, spell)
	if unit.isMe and (spell.name == "UrgotHeatseekingLineMissile" or spell.name == "UrgotHeatseekingHomeMissile") and self.Config.Misc.AutoW and not OWM:IsLastHitMode() and (OWM:IsComboMode() or OWM:IsHarassMode()) then
		self.W:Cast() -- UrgotHeatseekingLineMissile UrgotHeatseekingHomeMissile
	end
	if unit.isMe then
		-- print(spell.name)
	end
end
function Urgot:IsForceTarget(target)
	return HasBuff(target, "urgotcorrosivedebuff")
end

-- Urgot end

-- shen

function Shen:__init()
	self.Q = Spell(_Q, 500)
	self.W = Spell(_W, 0)
	self.E = Spell(_E, 500)
	self.E:SetSkillshot(SKILLSHOT_LINEAR, 150, .25, math.huge, false)
	self.R = Spell(_R, 0)
	self.flash = Summoner("summonerflash", 380)
	self.ignite = Summoner("summonerdot", 450)
	
	self.SwardName = "Shen_Base_P_sword.troy"
	self.swardObj = nil
	
	self.IsDashing = false
	
	for i = 1, objManager.iCount do
		local object = objManager:getObject(i)
		if object and Vector(object) and object.name == "Shen_Base_P_sword.troy" then
			self.swardObj = objManager:getObject(i)
		end
	end
	
	-- DM:CreateCircle(self.swardObj, 200, 1, Colors2.Red, "Draw W range")
	-- swarddraw = _Circle(self.swardObj, 200, 1, Colors2.Red)
	DM:CreateCircle(myHero, self.E.range, 1, Colors2.Red, "Draw E range")
	
	AGC:AddCallback(
		function(unit, spell)
		--[[
			unit = unit, spell = spell.name, startT = os.clock(), endT = os.clock() + 1, startPos = startPos, endPos = endPos
		]]
			-- if not self.Config.Misc.AE then return end
			-- if GetDistance(spell.startPos) < GetDistance(spell.endPos) and GetDistance(spell.startPos) < E.range then -- run away
			
				-- speed = ( spell.endT - spell.startT ) / ( spell.endPos - spell.startPos )
				-- range = 0.25 * speed
				-- castPos = Vector(spell.startPos) + ( Vector(spell.endPos) - Vector(spell.startPos) ):normalized() * range
				-- if GetDistance(castPos) < self.E.range then
					-- self.E:Cast(castPos.x, castPos.z)
				-- end
				
			-- elseif GetDistance(spell.startPos) < GetDistance(spell.endPos) and GetDistance(spell.endPos) < E.range then -- gap closer
				
				-- point, customStartPos = GetPoint(myHero, E.range, spell)
				-- speed = ( spell.endT - spell.startT ) / ( spell.endPos - spell.startPos )
				
				-- passedRange = GetDistance(spell.startPos, customStartPos)
				-- passedTime = passedRange / speed
				
				-- if passedTime > spell.endT - spell.startT then return end -- finished dash. already in front of me
				-- if passedTime + 0.25 > spell.endT - spell.startT then return end -- finished dash. already in front of me
				
				-- range = 0.25 * speed
				-- castPos = Vector(customStartPos) + ( Vector(spell.endPos) - Vector(customStartPos) ):normalized() * range
				-- if GetDistance(castPos) < self.E.range then
					-- self.E:Cast(castPos.x, castPos.z)
				-- end
				
			-- end
			CastSpell(_E, spell.endPos.x, spell.endPos.z)
		end)
	
	self.Config = scriptConfig(ScriptName, ScriptName)
	
	self.Config:addSubMenu("OrbWalkManager", "OrbWalkManager")
		OWM:AddToMenu(self.Config.OrbWalkManager)
	
	self.Config:addSubMenu("TargetSelector", "TargetSelector")
		STS:AddToMenu(self.Config.TargetSelector)
	
	self.Config:addSubMenu("DrawManager", "DrawManager")
		DM:AddToMenu(self.Config.DrawManager)
	
	self.Config:addSubMenu("Interrupter", "Interrupter")
		IT:AddToMenu(self.Config.Interrupter)
		
	self.Config:addSubMenu("AntiGapcloser", "AntiGapcloser")
		AGC:AddToMenu(self.Config.AntiGapcloser)
	
	self.Config:addSubMenu("Draw", "Draw")
		self.Config.Draw:addParam("DrawSword", "Draw Sword position", SCRIPT_PARAM_ONOFF, true)
		self.Config.Draw:addParam("DrawRSup", "Draw R sup mode", SCRIPT_PARAM_ONOFF, true)
	
	self.Config:addSubMenu("Combo", "Combo")
		self.Config.Combo:addParam("UseQ", "UseQ", SCRIPT_PARAM_LIST, 2, {"Always", "Only Collistion", "Off"})
		self.Config.Combo:addParam("UseW", "UseW", SCRIPT_PARAM_ONOFF, true)
		self.Config.Combo:addParam("UseE", "UseE", SCRIPT_PARAM_ONOFF, true)
		self.Config.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
		self.Config.Combo:addParam("EF", "E => flash", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('T'))
		-- self.Config.Combo:addParam("InRangeDontF", "dont flash when enemy in range", SCRIPT_PARAM_ONOFF, true)
	
	-- self.Config:addSubMenu("Harass", "Harass")
		-- self.Config.Harass:addParam("UseQ", "UseQ" ,SCRIPT_PARAM_ONOFF, true)
		-- self.Config.Harass:addParam("Toggle", "Use Harass (Toggle)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte('V'))
		-- AddManaChecker(self.Config.Harass)
	
	-- self.Config:addSubMenu("Clear", "Clear")
		-- self.Config.Farm:addSubMenu("UseQ", "UseQ", SCRIPT_PARAM_ONOFF, true)
		-- AddManaChecker(self.Config.Clear)
	
	
	self.Config:addSubMenu("AntiGapcloser", "AntiGapcloser")
		AGC:AddToMenu(self.Config.Interrupter)
		
		
	self.Config:addSubMenu("Misc", "Misc")
		self.Config.Misc:addParam("AutoW", "Auto W when attacked", SCRIPT_PARAM_ONOFF, true)
		self.Config.Misc:addParam("DrawRInfo", "Draw R Info", SCRIPT_PARAM_ONOFF, true)
		self.Config.Misc:addParam("IE", "Cancel Immobile spell with E", SCRIPT_PARAM_ONOFF, true)
		self.Config.Misc:addParam("AE", "Cancel GapCloser spell with E", SCRIPT_PARAM_ONOFF, true)
		self.Config.Misc:addParam("AutoDE", "Auto cast E to dash", SCRIPT_PARAM_ONOFF, true)
	
	self.Config:addSubMenu("Skillshot", "SS")
		AddSkillshotMenu(self.Config.SS, {self.E})
	
	AddTickCallback(function() self:Tick() end)
	AddCreateObjCallback(function(obj) self:OnCreateObj(obj) end)
	-- AddDeleteObjCallback(function(obj) self:OnDeleteObj(obj) end)
	AddDrawCallback(function() self:Draw() end)
end
function Shen:Draw()
	if self.swardObj ~= nil and self.Config.Draw.DrawSword then
		DrawCircle(self.swardObj.x, self.swardObj.y, self.swardObj.z, 100, ARGB(100, 255, 0, 0))
		-- swarddraw:Draw()
	end
	if self.Config.Draw.DrawRSup then
		mainPos = WINDOW_W/2
		for i, ally in ipairs(GetAllyHeroes())do
			
			per = ally.health / ally.maxHealth * 100
			col = per == 0 and Colors.Red or (per < 20 and Colors.Yellow or (per < 50 and Colors.Orange or (per < 80 and Colors.Green or Colors.Blue)))
			txt = string.format("%s | %s | %s ", ally.charName, per == 0 and "IsDead" or tostring(math.ceil(per)).."%", self:CanHelpHe(ally) and "Can Help" or "Can't Help")
			dp = mainPos - (string.len(txt)*5)
			DrawText(txt, 20, dp, (i*20), col)
		end
	end
end
function Shen:Anim(unit, anim)
	if unit and unit.isMe then
		if anim == "Spell3" then
			self.IsDashing = true
		else
			self.IsDashing = false
		end
	end
end
-- ShenArrowVfxHostMinion
function Shen:OnCreateObj(obj)
	if obj and obj.team == myHero.team and obj.name == "ShenArrowVfxHostMinion" then
		self.swardObj = obj
	end
end
-- function Shen:OnDeleteObj(obj)
	-- if obj and obj.team == myHero.team and obj.name == "ShenArrowVfxHostMinion" then
		-- self.swardObj = nil
	-- end
-- end
function Shen:Tick()
	for _, enemy in ipairs(GetEnemyHeroes())do
		local isImmobile, pos = IsImmobile(enemy, .25 + GetLatency()/2000, 150, math.huge, myHero)
		local isDashing, canHit, position = IsDashing(enemy, 0.25 + GetLatency()/2000, 150, math.huge, myHero)
		if self.Config.Misc.IE and isImmobile then
			self.E:Cast(pos)
		end
		if self.Config.Misc.AutoDE and isDashing then
			self.E:Cast(position)
		end
	end
	if OWM:IsComboMode() then
		self:Combo()
	end
	if OWM:IsClearMode() then
		self:LineClear()
		self:JungleClear()
	end
	if self.IsDashing and myHero:CanUseSpell(_E) == COOLDOWN then
		self.IsDashing = false
	end
	if self.Config.Combo.EF then
		self:EF()
	end
end
function Shen:Combo()
	target = STS:GetTarget(self.Q.range)
	if target ~= nil then
		if self.Config.Combo.UseQ < 3 then
			self:CastQ(target)
		elseif self.Config.Combo.UseQ < 2 then
			self:CastQ()
		end
		if self.Config.Combo.UseE then
			self:CastE(target)
		end
		ally = GetAllyHeroes()
		table.sort(ally, function(a,b) return GetDistance(a) < GetDistance(b) end)
		if GetDistance(self.swardObj) < 350 or GetDistance(ally[1], self.swardObj) < 350 then
			self.W:Cast()
		end
	end
end
function Shen:Harass()
	target = STS:GetTarget(self.Q.range)
end
function Shen:LineClear()
	minions = SMM:GetMinion(MINION_ENEMY, 200)
	if #minions > 0 then
		if self.Q:IsReady() then self.Q:Cast() end
		if self.W:IsReady() and GetDistance(myHero, self.swardObj) < 350 then self.W:Cast() end
	end
end
function Shen:JungleClear()
	minions = SMM:GetMinion(MINION_JUNGLE, 200)
	if #minions > 0 then
		if self.Q:IsReady() then self.Q:Cast() end
		if self.W:IsReady() and GetDistance(myHero, self.swardObj) < 350 then self.W:Cast() end
	end
end
function Shen:CastQ(target)
	count = CountObjectsOnLineSegment(myHero.visionPos, Vector(self.swardObj), 120, GetEnemyHeroes())  -- CountHits(Vector(self.swardObj), GetEnemyHeroes(), myHero, 120)
	-- print(count)
	if count > 0 then
		self.Q:Cast()
	end
end
function Shen:EF()
	t1 = STS:GetTarget(self.E.range)
	t2 = STS:GetTarget(980)
	t3 = GetTarget()
	if t3 ~= nil then
		if self.IsDashing and GetDistance(t3)< 420 then
			self.flash:Cast(t3.x, t3.z)
		end
		if self.E:IsReady() and self.flash:IsReady() and ValidTarget(t3, 980) then
			self:CastE(t3)
		end
	end
	if t1 ~= nil and t2 ~= nil then
		if self.E:IsReady() and self.flash:IsReady() and GetDistance(t2) < 410 then
			self:CastE(t1)
		end
		if HasBuffType(t1, "taunt") and self.IsDashing() and GetDistance(t2) < 410 then
			self.flash:Cast(t2.x, t2.z)
		end
	end
	myHero:MoveTo(mousePos.x, mousePos.z)
end
function Shen:CastE(target)
	pos, hit = self.E:GetPrediction(target)
	if GetDistance(pos) < GetDistance(target) then
		self.E:Cast(pos.x, pos.z)
	else
		pos = Extends2(myHero, pos, myHero.boundingRadius/2)
		-- print(hit)
		if pos and hit and hit > self.E.hitChance then
			self.E:Cast(pos.x, pos.z)
		end
	end
	-- self.E:Cast(target)
end
function Shen:CanHelpHe(unit)
	objects = {}
	for _, enemy in ipairs(GetEnemyHeroes())do
		if GetDistance(enemy, unit) < 2000 then table.insert(objects, enemy) end
	end
	
	damage = 0
	for _, enemy in ipairs(objects) do
		-- damage = damage + getDmg
		if enemy.ap < enemy.totalDamage then damage = damage + getDmg("AD", unit, enemy) * 2 end
		damage = damage + getDmg("Q", unit, enemy)
		damage = damage + getDmg("W", unit, enemy)
		damage = damage + getDmg("E", unit, enemy)
		damage = damage + getDmg("R", unit, enemy)
	end
	-- print(unit.charName .. " " .. damage)
	lastHP = unit.health + self:selfSheld() - damage
	return lastHP > 0, objects
end

function Shen:selfSheld()
	return 250 + (300 * (self.R:GetLevel()-1)) + (1.35 * myHero.ap)
end
-- shen end

-- karthus

function Karthus:__init()
	self.AABLocked = false
	
	self.Q = Spell(_Q, 875)
	self.Q:SetSkillshot(SKILLSHOT_CIRCULAR, 200, 1.1, math.huge)
	self.W = Spell(_W, 1000)
	self.W:SetSkillshot(SKILLSHOT_LINEAR, 200, 0.5, math.huge)
	self.E = Spell(_E, 550)
	self.R = Spell(_R, math.huge)
	
	DM:CreateCircle(myHero, Q.range, 1, {100, 255, 0, 0}, "Draw Q range")
	DM:CreateCircle(myHero, W.range, 1, {100, 255, 0, 0}, "Draw W range")
	DM:CreateCircle(myHero, E.range, 1, {100, 255, 0, 0}, "Draw E range")
	
	DLib:RegisterDamageSource(_Q, _MAGIC, 40, 20, _MAGIC, _AP, 0.3, function() return (player:CanUseSpell(_Q) == READY) end)
	DLib:RegisterDamageSource(_W, _MAGIC, 30, 20, _MAGIC, _AP, 0.2, function() return (player:CanUseSpell(_W) == READY) end)
	DLib:RegisterDamageSource(_R, _MAGIC, 250, 150, _MAGIC, _AP, 0.6, function() return (player:CanUseSpell(_R) == READY) end)
	
	self.Config = scriptConfig(ScriptName, ScriptName)
	
	self.Config:addSubMenu("OrbWalkManager", "OrbWalkManager")
		OWM:AddToMenu(self.Config.OrbWalkManager)
	
	self.Config:addSubMenu("TargetSelector", "TargetSelector")
		STS:AddToMenu(self.Config.TargetSelector)
	
	self.Config:addSubMenu("DrawManager", "DrawManager")
		DM:AddToMenu(self.Config.DrawManager)
	
	self.Config:addSubMenu("Draw", "Draw")
		self.Config.Draw:addParam("DrawPredictedHealth", "Draw damage Q", SCRIPT_PARAM_ONOFF, true)
		self.Config.Draw:addParam("QP", "Draw Q Prediction", SCRIPT_PARAM_ONOFF, true)
		self.Config.Draw:addParam("Killmark", "Draw killable", SCRIPT_PARAM_ONOFF, true)
		
	self.Config:addSubMenu("Combo", "Combo")
		self.Config.Combo:addParam("UseQ", "Use Q in combo mode", SCRIPT_PARAM_ONOFF, true)
		self.Config.Combo:addParam("UseW", "Use W in combo mode", SCRIPT_PARAM_ONOFF, true)
		self.Config.Combo:addParam("UseE", "Use E in combo mode", SCRIPT_PARAM_ONOFF, true)
		self.Config.Combo:addParam("BlockAA", "Block AA when combo", SCRIPT_PARAM_ONOFF, true)
	
	self.Config:addSubMenu("Harass", "Harass")
		self.Config.Harass:addParam("UseQ", "Use Q in harass mode", SCRIPT_PARAM_ONOFF, true)
		self.Config.Harass:addParam("UseW", "Use W in harass mode", SCRIPT_PARAM_ONOFF, true)
		self.Config.Harass:addParam("UseE", "Use E in harass mode", SCRIPT_PARAM_ONOFF, true)
		AddManaChecker(self.Config.Harass)
	
	self.Config:addSubMenu("LineClear", "LineClear")
		self.Config.LineClear:addParam("UseQ", "Use Q in lineclear", SCRIPT_PARAM_ONOFF, true)
		-- Config.LineClear:addParam("OnlyQone", "Use Q when only 1 hit", SCRIPT_PARAM_ONOFF, true)
		self.Config.LineClear:addParam("UseE", "Use E in lineclear", SCRIPT_PARAM_ONOFF, true)
		AddManaChecker(self.Config.LineClear)
	
	self.Config:addSubMenu("Farm", "Farm")
		self.Config.Farm:addParam("UseQ", "Use Q in Farm", SCRIPT_PARAM_ONOFF, true)
		self.Config.Farm:addParam("OnlyQone", "Use Q when only 1 hit", SCRIPT_PARAM_ONOFF, true)
		self.Config.Farm:addParam("UseE", "Use E in Farm", SCRIPT_PARAM_ONOFF, true)
		AddManaChecker(self.Config.Farm)
	
	self.Config:addSubMenu("Misc", "Misc")
		self.Config.Misc:addParam("PassiveManager", "Cast Spell in passive time", SCRIPT_PARAM_ONOFF, true)
		
	
	self.Config:addSubMenu("Auto", "Auto")
		self.Config.Auto:addParam("AutoEoff", "Auto E off", SCRIPT_PARAM_ONOFF, true)
		self.Config.Auto:addParam("AutoEoffoff", "AutoEoff off with mouse left click", SCRIPT_PARAM_ONOFF, true)
	
	self.Config:addSubMenu("Skillshot", "SS")
		AddSkillshotMenu(self.Config.SS, {self.Q, self.W})
end
function Karthus:Tick()
	self.EActive = HasBuff(myHero, "KarthusDefile")
	self.Dead = HasBuff(myHero, "KarthusDeathDefiedBuff")
	
	if OWM:IsComboMode() then
		self:Combo()
		if self.Config.Combo.BlockAA and not self.AABLocked then
			OWM:DisableAttack()
			self.AABLocked = true
		end
	elseif OWM:IsHarassMode() then
		self:Harass()
	elseif OWM:IsClearMode() then
		self:LineClear()
		self:JungleClear()
	elseif OWM:IsLastHitMode() then
		self:Farm()
	end
	if self.Config.Combo.BlockAA and not OWM:IsComboMode() and self.AABLocked then
		OWM:EnableAttack()
		self.AABLocked = false
	end
	if self.Config.Auto.AutoEoff and self.EActive and GetNearObject(myHero, self.E.range, GetEnemyHeroes()) == 0 and not (self.Config.LineClear.UseE and OWM:IsClearMode() and GetNearObject(myHero, self.E.range, SMM:GetMinion(MINION_ENEMY, self.E.range)) == 0) then
		if self.Config.AutoEoffoff and LBClicked then return end
		self.E:Cast()
	end
end
-- and not (self.Config.Auto.AutoEoffoff and LBClicked) and not (self.Config.Combo.UseE and OWM:IsComboMode()) and not (self.Config.Harass.UseE)
function Karthus:Draw()
	mainPos = WINDOW_W/2
	if self.Config.Draw.DrawPredictedHealth then
		for _, enemy in ipairs(GetEnemyHeroes())do
			self:DrawIndicator(enemy)
		end
	end
	if self.Config.Draw.Killmark then
		for i, enemy in ipairs(GetEnemyHeroes())do
			isKillable = DLib:IsKillable(enemy, {_R})
			col = isKillable and Colors.Green or Colors.Red
			per = 100 - (DLib:CalcSpellDamage(enemy, _R) / enemy.health * 100)
			
			txt = string.format("%s | iskillable : %s | %s%", enemy.charName, tostring(isKillable), tostring(per))
			dp = mainPos - (string.len(txt)*13)
			DrawText(txt, 13, dp, (i*20), col)
		end
	end
	if self.Q:IsReady() and self.Config.Draw.QP then
		t = STS:GetTarget(self.Q.range)
		if t ~= nil then
			pos, hit = self.Q:GetPrediction(t)
			col = Colors.Black
			if pos and hit then
				if hit < 1 then
					col = Colors.RED
				elseif hit == 3 then
					col = Colors.Green
				elseif hit >= 2 then
					col = Colors.Yellow
				elseif hit >= 1 then
					col = Colors.Orange
				end
				
				DrawCircles(pos.x, pos.y, pos.z, 100, col)
			end
		end
	end
end
function Karthus:Combo()
	target = STS:GetTarget(self.E.range)
	if target == nil then return end
	if self.Config.Combo.UseQ then self.Q:Cast(target) end
	if self.Config.Combo.UseW then self.W:Cast(target) end
	if self.Config.Combo.UseE and GetNearObject(myHero, self.E.range, GetEnemyHeroes()) > 0 and not self.EActive then self.E:Cast() end
end
function Karthus:Harass()
	if IsManaLow(self.Config.Harass.mper) then return end
	target = STS:GetTarget(self.E.range)
	if self.Config.Harass.UseQ then self.Q:Cast(target) end
	if self.Config.Harass.UseW then self.W:Cast(target) end
	if self.Config.Harass.UseE and GetNearObject(myHero, self.E.range, GetEnemyHeroes()) > 0 and not self.EActive then self.E:Cast() end
end
function Karthus:LineClear()
	if IsManaLow(self.Config.LineClear.mper) then return end
	if self.Config.LineClear.UseQ then
		local bp, bh = GetBestCircularFarmPosition(875, 200, SMM:GetMinion(MINION_ENEMY, self.Q.range))
		if bp and bh then
			self.Q:Cast(bp.x, bp.z)
		end
	end
	if self.Config.LineClear.UseE then
		for _, minion in ipairs(SMM:GetMinion(MINION_ENEMY, self.E.range))do
			if getDmg("E", minion, myHero) > minion.health and not self.EActive then
				self.E:Cast()
			end
		end
	end
end
function Karthus:JungleClear()
	if IsManaLow(self.Config.JungleClear.mper) then return end
	if self.Config.LineClear.UseQ then
		local bp, bh = GetBestCircularFarmPosition(875, 200, SMM:GetMinion(MINION_JUNGLE, self.Q.range))
		if bp and bh then
			self.Q:Cast(bp.x, bp.z)
		end
	end
	if self.Config.LineClear.UseE then
		for _, minion in ipairs(SMM:GetMinion(MINION_JUNGLE, self.E.range))do
			if getDmg("E", minion, myHero) > minion.health and not self.EActive then
				self.E:Cast()
			end
		end
	end
end
function Karthus:Farm()
	if IsManaLow(self.Config.Farm.mper) then return end
	for _, minion in ipairs(SMM:GetMinion(MINION_ENEMY, self.Q.range)) do
		if self.Config.Farm.UseQ and getDmg("Q", minion, myHero) > minion.health then
			if self.Config.Farm.OnlyQone then
				position, hit = self:FindPosition(minion)
				if position and hit and hit == 1 then
					self.Q:Cast(position.x, position.z)
				end
			else
				_t = SMM:GetMinion(MINION_ENEMY, 200, minion)
				if #_t == 1 then
					self.Q:Cast(minion)
				elseif #_t > 1 then
					if getDmg("Q", minion, myHero)/2 > minion.health then
						self.Q:Cast(minion)
					end
				end
			end
		end
		if self.Config.Farm.UseE and getDmg("E", minion, myHero) > minion.health then
			self.E:Cast()
		end
	end
end
function Karthus:FindPosition(target)
	tempposition = nil
	multihit = 0;
	for i = -200, 200, 10 do
		for a = -200, 200, 10 do
			tempposition = Vector(target.x+i, target.y, target.z+a)
			multihit = GetNearObject(tempposition, 200, minionTable.objects)
			if(multihit == 1)then
				return tempposition, multihit
			end
		end
	end
	return Vector(target), GetNearObject(Vector(target), 200, minionTable.objects)
end
function Karthus:DrawIndicator(enemy)

	if not enemy.valid or enemy.dead then return end
    local aft = math.max(0, enemy.health - getDmg("Q", target, myHero)) / enemy.maxHealth
    local SPos, EPos = GetHPBarPos(enemy)

    -- Validate data
    if not VectorType(SPos) then return end
	
	local barwidth = EPos.x - SPos.x
	damage = getDmg("Q", target, myHero)
    local Position = SPos.x + math.max(0, ((enemy.health - damage) / enemy.maxHealth) * (enemy.health / enemy.maxHealth)*100)
	
    DrawText("|", 16, math.floor(Position), math.floor(SPos.y-23), ARGB(255,0,255,0))
    DrawText("After Q hit HP: "..math.floor(enemy.health - damage), 13, math.floor(SPos.x), math.floor(SPos.y), (enemy.health - damage) > 0 and ARGB(255, 0, 255, 0) or  ARGB(255, 255, 0, 0))
	DrawText("Q hit's " .. tostring(math.ceil(enemy.health / damage)), 13, math.floor(Position), math.floor(SPos.y-48), (enemy.health - damage) > 0 and ARGB(255, 0, 255, 0) or  ARGB(255, 255, 0, 0))
end
function GetHPBarPos(enemy)
	enemy.barData = {PercentageOffset = {x = -0.05, y = 0}}--GetEnemyBarData()
	local barPos = GetUnitHPBarPos(enemy)
	local barPosOffset = GetUnitHPBarOffset(enemy)
	local barOffset = { x = enemy.barData.PercentageOffset.x, y = enemy.barData.PercentageOffset.y }
	local barPosPercentageOffset = { x = enemy.barData.PercentageOffset.x, y = enemy.barData.PercentageOffset.y }
	local BarPosOffsetX = 171
	local BarPosOffsetY = 46
	local CorrectionY = 39
	local StartHpPos = 31

	barPos.x = math.floor(barPos.x + (barPosOffset.x - 0.5 + barPosPercentageOffset.x) * BarPosOffsetX + StartHpPos)
	barPos.y = math.floor(barPos.y + (barPosOffset.y - 0.5 + barPosPercentageOffset.y) * BarPosOffsetY + CorrectionY)

	local StartPos = Vector(barPos.x , barPos.y, 0)
	local EndPos =  Vector(barPos.x + 108 , barPos.y , 0)
	return Vector(StartPos.x, StartPos.y, 0), Vector(EndPos.x, EndPos.y, 0)
end

-- Karthus end


































class('Debugger')
function Debugger:__init()
	if not FileExist(SCRIPT_PATH .. "\\SectionCore_MB.log") then
		local logfile = io.open(SCRIPT_PATH.."\\SectionCore_MB.log", "a")
		logfile:close()
		self:print("new Log file loaded: "..os.date("%c"))
	end
end
function Debugger:print(msg)
end
local spells = {
	{name = "katarinar", duration = 1}, --Katarinas R
	{name = "drain", duration = 1}, --Fiddle W
	{name = "crowstorm", duration = 1}, --Fiddle R
	{name = "consume", duration = 0.5}, --Nunu Q
	{name = "absolutezero", duration = 1}, --Nunu R
	{name = "rocketgrab", duration = 0.5}, --Blitzcrank Q
	{name = "staticfield", duration = 0.5}, --Blitzcrank R
	{name = "cassiopeiapetrifyinggaze", duration = 0.5}, --Cassio's R
	{name = "ezrealtrueshotbarrage", duration = 1}, --Ezreal's R
	{name = "galioidolofdurand", duration = 1}, --Ezreal's R
	-- {name = "gragasdrunkenrage", duration = 1}, --Gragas W, Rito changed it so that it allows full movement while casting
	{name = "luxmalicecannon", duration = 1}, --Lux R
	{name = "reapthewhirlwind", duration = 1}, --Jannas R
	{name = "jinxw", duration = 0.6}, --jinxW
	{name = "jinxr", duration = 0.6}, --jinxR
	{name = "missfortunebullettime", duration = 1}, --MissFortuneR
	{name = "shenstandunited", duration = 1}, --ShenR
	{name = "threshe", duration = 0.4}, --ThreshE
	{name = "threshrpenta", duration = 0.75}, --ThreshR
	{name = "infiniteduress", duration = 1}, --Warwick R
	{name = "meditate", duration = 1} --yi W
}
local dashAboutToHappend = {
	{name = "ahritumble", duration = 0.25},--ahri's r
	{name = "akalishadowdance", duration = 0.25},--akali r
	{name = "headbutt", duration = 0.25},--alistar w
	{name = "caitlynentrapment", duration = 0.25},--caitlyn e
	{name = "carpetbomb", duration = 0.25},--corki w
	{name = "dianateleport", duration = 0.25},--diana r
	{name = "fizzpiercingstrike", duration = 0.25},--fizz q
	{name = "fizzjump", duration = 0.25},--fizz e
	{name = "gragasbodyslam", duration = 0.25},--gragas e
	{name = "gravesmove", duration = 0.25},--graves e
	{name = "ireliagatotsu", duration = 0.25},--irelia q
	{name = "jarvanivdragonstrike", duration = 0.25},--jarvan q
	{name = "jaxleapstrike", duration = 0.25},--jax q
	{name = "khazixe", duration = 0.25},--khazix e and e evolved
	{name = "leblancslide", duration = 0.25},--leblanc w
	{name = "leblancslidem", duration = 0.25},--leblanc w (r)
	{name = "blindmonkqtwo", duration = 0.25},--lee sin q
	{name = "blindmonkwone", duration = 0.25},--lee sin w
	{name = "luciane", duration = 0.25},--lucian e
	{name = "maokaiunstablegrowth", duration = 0.25},--maokai w
	{name = "nocturneparanoia2", duration = 0.25},--nocturne r
	{name = "pantheon_leapbash", duration = 0.25},--pantheon e?
	{name = "renektonsliceanddice", duration = 0.25},--renekton e
	{name = "riventricleave", duration = 0.25},--riven q
	{name = "rivenfeint", duration = 0.25},--riven e
	{name = "sejuaniarcticassault", duration = 0.25},--sejuani q
	{name = "shenshadowdash", duration = 0.25},--shen e
	{name = "shyvanatransformcast", duration = 0.25},--shyvana r
	{name = "rocketjump", duration = 0.25},--tristana w
	{name = "slashcast", duration = 0.25},--tryndamere e
	{name = "vaynetumble", duration = 0.25},--vayne q
	{name = "viq", duration = 0.25},--vi q
	{name = "monkeykingnimbus", duration = 0.25},--wukong q
	{name = "xenzhaosweep", duration = 0.25},--xin xhao q
	{name = "yasuodashwrapper", duration = 0.25},--yasuo e
}
local blinks = {
	{name = "ezrealarcaneshift", range = 475, delay = 0.25, delay2=0.8},--Ezreals E
	{name = "deceive", range = 400, delay = 0.25, delay2=0.8}, --Shacos Q
	{name = "riftwalk", range = 700, delay = 0.25, delay2=0.8},--KassadinR
	{name = "gate", range = 5500, delay = 1.5, delay2=1.5},--Twisted fate R
	{name = "katarinae", range = math.huge, delay = 0.25, delay2=0.8},--Katarinas E
	{name = "elisespideredescent", range = math.huge, delay = 0.25, delay2=0.8},--Elise E
	{name = "elisespidere", range = math.huge, delay = 0.25, delay2=0.8},--Elise insta E
}
local TargetsImmobile = {}
local TargetsDashing = {}
local TargetsSlowed = {}
function GetTime()
	return os.clock()
end
function OnProcessSpell(unit, spell)
	if unit and unit.type == myHero.type then
		for i, s in ipairs(spells) do
			if(spell.name:lower() == s.name) then
				TargetsImmobile[unit.networkID] = os.clock() + s.duration
			end
		end
		for i, s in ipairs(blinks) do
			local LandingPos = GetDistance(unit, Vector(spell.endPos)) < s.range and Vector(spell.endPos) or Vector(unit) + s.range * (Vector(spell.endPos) - Vector(unit)):normalized()
            if spell.name:lower() == s.name and not IsWall(D3DXVECTOR3(spell.endPos.x, spell.endPos.y, spell.endPos.z)) then
                TargetsDashing[unit.networkID] = {isblink = true, duration = s.delay, endT = GetTime() + s.delay, endT2 = os.clock() + s.delay2, startPos = Vector(unit), endPos = LandingPos}
                return
            end
		end
	end
end
function IsImmobile(unit, delay, radius, speed, from, spelltype)
	if TargetsImmobile[unit.networkID] then
        local ExtraDelay = speed == math.huge and  0 or (GetDistance(from, unit) / speed)
        if (TargetsImmobile[unit.networkID] > (GetTime() + delay + ExtraDelay) and spelltype == "circular") then
            return true, Vector(unit), Vector(unit) + (radius/3) * (Vector(from) - Vector(unit)):normalized()
        elseif (TargetsImmobile[unit.networkID] + (radius / unit.ms)) > (GetTime() + delay + ExtraDelay) then
            return true, Vector(unit), Vector(unit)
        end
    end
    return false, Vector(unit), Vector(unit)
end
function IsDashing(unit, delay, radius, speed, from)
    local TargetDashing = false
    local CanHit = false
    local Position

    if TargetsDashing[unit.networkID] then
        local dash = TargetsDashing[unit.networkID]
        if dash.endT >= GetTime() then
            TargetDashing = true
            if dash.isblink then
                if (dash.endT - GetTime()) <= (delay + GetDistance(from, dash.endPos)/speed) then
                    Position = Vector(dash.endPos.x, 0, dash.endPos.z)
                    CanHit = (unit.ms * (delay + GetDistance(from, dash.endPos)/speed - (dash.endT2 - GetTime()))) < radius
                end

                if ((dash.endT - GetTime()) >= (delay + GetDistance(from, dash.startPos)/speed)) and not CanHit then
                    Position = Vector(dash.startPos.x, 0, dash.startPos.z)
                    CanHit = true
                end
            else
                local t1, p1, t2, p2, dist = VectorMovementCollision(dash.startPos, dash.endPos, dash.speed, from, speed, (GetTime() - dash.startT) + delay)
                t1, t2 = (t1 and 0 <= t1 and t1 <= (dash.endT - GetTime() - delay)) and t1 or nil, (t2 and 0 <= t2 and t2 <=  (dash.endT - GetTime() - delay)) and t2 or nil
                local t = t1 and t2 and math.min(t1,t2) or t1 or t2
                if t then
                    Position = t==t1 and Vector(p1.x, 0, p1.y) or Vector(p2.x, 0, p2.y)
                    CanHit = true
                else
                    Position = Vector(dash.endPos.x, 0, dash.endPos.z)
                    CanHit = (unit.ms * (delay + GetDistance(from, Position)/speed - (dash.endT - GetTime()))) < radius
                end
            end
        end
    end
    return TargetDashing, CanHit, Position
end

--summonerdot
--summonerflash
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
    return result
end