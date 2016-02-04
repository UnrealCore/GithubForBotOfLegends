if myHero.charName ~= "Karthus" then return end

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
function GetNearObject(position, distance, objects)
	local count = 0;
	local _objects = {}
	for index, object in ipairs(objects) do
		if(GetDistance(position, Vector(object)) < distance) then
			count = count+1
			table.insert(_objects, object)
		end
	end
	return count, _objects
end
local ScriptName = "KarthusCore"
printMessage = function(message) print("<font color=\"#6699ff\"><b>" .. ScriptName .. ":</b></font> <font color=\"#FFFFFF\">" .. message .. "</font>") end
SimpleUpdater("[KarthusCore]", ScriptVersion, "raw.github.com" , "/UnrealCore/GithubForBotOfLegends/master/Script/KarthusCore/KarthusCore.lua" , SCRIPT_PATH .. "KarthusCore.lua" , "/UnrealCore/GithubForBotOfLegends/master/Script/KarthusCore/KarthusCore.version" ):CheckUpdate()
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
local Colors = { 
    -- O R G B
    Green   =  ARGB(255, 0, 180, 0), 
    Yellow  =  ARGB(255, 255, 215, 00),
    Red     =  ARGB(255, 255, 0, 0),
    White   =  ARGB(255, 255, 255, 255),
    Blue    =  ARGB(255, 0, 0, 255),
}
local Q, E, R
local OWM = OrbWalkManager(ScriptName)
local STS = SimpleTS()
local DLib = DamageLib()
local Config = scriptConfig(ScriptName, ScriptName)
local DM = DrawManager()
local minionTable, jungleTable
local OnPassive = false
local LBClicked = false
local EActive = false
local dead = false
local LastPinged = {}
for _, enemy in ipairs(GetEnemyHeroes())do
	newParam = {unit = enemy, LastPinged = false, LastTick = GetTickCount(), Count = 0}
	table.insert(LastPinged, newParam)
end
function OnLoad()
	Q = Spell(_Q, 875)
	Q:SetSkillshot(SKILLSHOT_CIRCULAR, 200, 1.1, math.huge)
	W = Spell(_W, 1000)
	W:SetSkillshot(SKILLSHOT_LINEAR, 200, 0.5, math.huge)
	E = Spell(_E, 550)
	R = Spell(_R, math.huge)
	
	minionTable = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	jungleTable = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	
	DM:CreateCircle(myHero, Q.range, 1, {100, 255, 0, 0}, "Draw Q range")
	DM:CreateCircle(myHero, W.range, 1, {100, 255, 0, 0}, "Draw W range")
	DM:CreateCircle(myHero, E.range, 1, {100, 255, 0, 0}, "Draw E range")
	
	DLib:RegisterDamageSource(_Q, _MAGIC, 40, 20, _MAGIC, _AP, 0.3, function() return (player:CanUseSpell(_Q) == READY) end)
	DLib:RegisterDamageSource(_E, _MAGIC, 30, 20, _MAGIC, _AP, 0.2, function() return (player:CanUseSpell(_E) == READY) end)
	DLib:RegisterDamageSource(_R, _MAGIC, 250, 150, _MAGIC, _AP, 0.6, function() return (player:CanUseSpell(_R) == READY) end)
	
	Config:addSubMenu("OrbWalkManager", "OrbWalkManager")
		OWM:AddToMenu(Config.OrbWalkManager)
	
	Config:addSubMenu("TargetSelector", "TargetSelector")
		STS:AddToMenu(Config.TargetSelector)
	
	Config:addSubMenu("Draw", "Draw")
		DM:AddToMenu(Config.Draw)
		Config.Draw:addParam("DrawKillable", "Draw Killable mark", SCRIPT_PARAM_ONOFF, true)
		Config.Draw:addParam("DrawPredictedHealth", "Draw damage Q", SCRIPT_PARAM_ONOFF , true)
	
	Config:addSubMenu("Combo", "Combo")
		Config.Combo:addParam("UseQ", "Use Q in combo mode", SCRIPT_PARAM_ONOFF, true)
		Config.Combo:addParam("UseW", "Use W in combo mode", SCRIPT_PARAM_ONOFF, true)
		Config.Combo:addParam("UseE", "Use E in combo mode", SCRIPT_PARAM_ONOFF, true)
	
	Config:addSubMenu("Harass", "Harass")
		Config.Harass:addParam("UseQ", "Use Q in harass mode", SCRIPT_PARAM_ONOFF, true)
		Config.Harass:addParam("UseW", "Use W in harass mode", SCRIPT_PARAM_ONOFF, true)
		Config.Harass:addParam("UseE", "Use E in harass mode", SCRIPT_PARAM_ONOFF, true)
		Config.Harass:addParam("mper", "dont use if my mana >= (%)", SCRIPT_PARAM_SLICE, 40, 0, 99)
	
	Config:addSubMenu("LineClear", "LineClear")
		Config.LineClear:addParam("UseQ", "Use Q in lineclear", SCRIPT_PARAM_ONOFF, true)
		-- Config.LineClear:addParam("OnlyQone", "Use Q when only 1 hit", SCRIPT_PARAM_ONOFF, true)
		-- Config.LineClear:addParam("UseE", "Use E in lineclear", SCRIPT_PARAM_ONOFF, true)
		Config.LineClear:addParam("mper", "dont use if my mana <= (%)", SCRIPT_PARAM_SLICE, 40, 0, 99)
		
	Config:addSubMenu("Farm", "Farm")
		Config.Farm:addParam("UseQ", "Use Q in Farm", SCRIPT_PARAM_ONOFF, true)
		Config.Farm:addParam("OnlyQone", "Use Q when only 1 hit", SCRIPT_PARAM_ONOFF, true)
		-- Config.Farm:addParam("UseE", "Use E in Farm", SCRIPT_PARAM_ONOFF, true)
		Config.Farm:addParam("mper", "dont use if my mana >= (%)", SCRIPT_PARAM_SLICE, 40, 0, 99)
	
	Config:addSubMenu("JungleClear", "JungleClear")
		Config.JungleClear:addParam("UseQ", "Use Q in JungleClear", SCRIPT_PARAM_ONOFF, true)
		-- Config.JungleClear:addParam("OnlyQone", "Use Q when only 1 hit", SCRIPT_PARAM_ONOFF, true)
		-- Config.JungleClear:addParam("UseE", "Use E in JungleClear", SCRIPT_PARAM_ONOFF, true)
		Config.JungleClear:addParam("mper", "dont use if my mana >= (%)", SCRIPT_PARAM_SLICE, 40, 0, 99)
	
	Config:addSubMenu("Misc", "Misc")
		Config.Misc:addParam("PassiveManager", "Cast Spell in passive time", SCRIPT_PARAM_ONOFF, true)
		Config.Misc:addParam("AutoEOff", "Auto E off", SCRIPT_PARAM_ONOFF, true)
		Config.Misc:addParam("AutoEoffoff", "Aut E off off with mouse left click", SCRIPT_PARAM_ONOFF, true)
		Config.Misc:addParam("Ping", "Ping to killable enemy", SCRIPT_PARAM_ONOFF, true)
		Config.Misc:addParam("PingCount", "Ping Count", SCRIPT_PARAM_SLICE, 2, 0, 5)
		
	Config:addSubMenu("Q", "Q")
		Q:AddToMenu(Config.Q)
	
	Config:addSubMenu("W", "W")
		W:AddToMenu(Config.W)
	
	AddApplyBuffCallback(function(source, unit, buff) OnApplyBuff(source, unit, buff) end)
	AddRemoveBuffCallback(function(unit, buff) OnRemoveBuff(unit, buff) end)
end
function OnTick()
	-- PingSignal(PING_DANGER, math.random(0,25000),0,math.random(0,25000), 0)
	if OWM:IsComboMode() then
		Combo()
	elseif OWM:IsHarassMode() then
		Harass()
	elseif OWM:IsClearMode() then
		LineClear()
		JungleClear()
	elseif OWM:IsLastHitMode() then
		Farm()
	end
	
	if dead and Config.Misc.PassiveManager then
		OnPassive()
	end
	
	if EActive then
		if Config.Misc.AutoEoffoff and LBClicked then return end
		if OWM:IsComboMode() then
			count = GetNearObject(myHero, E.range, GetEnemyHeroes())
			if count > 0 then return end
		end
		E:Cast()
	end
	
	if Config.Misc.Ping then
		for i = 1, #LastPinged do
			if GetTickCount() - LastPinged[i].LastTick > 1000 and not LastPinged[i].LastPinged and LastPinged[i].Count < Config.Misc.PingCount and DLib:IsKillable(LastPinged[i].unit, {_R}) and R:IsReady() and not LastPinged[i].unit.dead then
				PingSignal(PING_DANGER, LastPinged[i].unit.x, 0, LastPinged[i].unit.y, 0)
				LastPinged[i].Count = LastPinged[i].Count + 1
				LastPinged[i].LastTick = GetTickCount()
				if LastPinged[i].Count +1 == Config.Misc.PingCount then
					LastPinged[i].LastPinged = true
				end
			end
			if LastPinged[i].LastPinged then
				if GetTickCount() - LastPinged[i].LastTick > 50000 then
					LastPinged[i].LastPinged = false
					LastPinged[i].Count = 0
					-- print("Reseted")
				end
				if LastPinged[i].unit.health > DLib:CalcComboDamage(LastPinged[i].unit, {_R}) + 200 then
					LastPinged[i].LastPinged = false
					LastPinged[i].Count = 0
					-- print("Reseted")
				end
				if LastPinged[i].unit.dead then
					LastPinged[i].LastPinged = false
					LastPinged[i].Count = 0
					-- print("Reseted")
				end
			end
		end
	end
end
function OnDraw()
	DrawKillable()
	-- for count, data in ipairs(LastPinged) do
		-- DrawText(tostring(GetTickCount() - data.LastTick), 18, 100, 80, 0xFFFF0000)
		-- DrawText(tostring(data.LastTick), 18, 100, 100, 0xFFFF0000)
		-- DrawText(tostring(data.LastPinged), 18, 100, 120, 0xFFFF0000)
		-- DrawText(tostring(data.Count), 18, 100, 140, 0xFFFF0000)
	-- end
	
	for i, j in ipairs(GetEnemyHeroes()) do
		if GetDistance(j) < 2000 and not j.dead and ValidTarget(j) then
			local pos = GetHPBarPos(j)
			local Qdamage = getDmg("Q", j, myHero)
			
			local pos2 = ((j.health - Qdamage)/j.maxHealth)*108
			DrawLine(pos.x+pos2, pos.y, pos.x+pos2, pos.y-30, 1, 0xffff0000)
			local hit = tostring(math.ceil(j.health/Qdamage))
			DrawText("Q hit : "..hit,18 , pos.x, pos.y-48, 0xffff0000)
		end
	end
end
function DrawKillable()
	mainXPos = WINDOW_W/2
	for count, enemy in ipairs(GetEnemyHeroes()) do
		IsKillable = ""
		DrawingColor = Colors.Red
		if DLib:IsKillable(enemy, {_R}) and not enemy.dead then
			IsKillable = "Kill with R!"
			DrawingColor = Colors.Blue
		else
			IsKillable = "Can't Kill"
		end
		Damage = DLib:CalcComboDamage(enemy, {_R})
		DamagePer = 0
		if enemy.health > 0 then
			DamagePer = math.ceil(100 - (Damage / enemy.health * 100))
		end
		valid = enemy.valid and  "He is not missing" or "He is missing"
		text = enemy.charName .. " | " .. IsKillable .. " | " .. DamagePer .. "%" .. " | Is Missing? > " .. valid
		length = string.len(text)*5
		DrawText(text, 18, mainXPos- length, (count*20), DrawingColor)
	end
end
function FarmQ()
	minionTable:update()
	for _, minion in ipairs(minionTable.objects) do
		if Config.Farm.OnlyQone then
			PH = GetPredicHealth(minion)
			if PH > 10 and PH < getDmg("Q", minion, myHero) and not minion.dead and minion.valid and Config.Farm.UseQ then
				if PH < getDmg("Q", minion, myHero)/2 then
					Q:Cast(minion.x, minion.z)
				else
					FarmCast(minion, PH)
				end
			end
		else
			if DLib:IsKillable(minion, {_Q}) and Config.Farm.UseQ then
				Q:Cast(minion)
			end
			if not Q:IsReady() and DLib:IsKillable(minion, {_E}) and Config.Farm.UseE then
				E:Cast(minion)
			end
		end
	end
end
function FarmCast(minion, PredHelth)
	if PredHelth < 0 or minion.dead then return end
	local count = GetNearObject(Vector(minion), 400, minionTable.objects )
	local position, multihit = FindHitPosition(minion)
	if position ~= Vector(0, 0, 0) then
		
		if(not(position.x == 0 and position.y == 0 and position.z == 0) and multihit == 1 ) then
			-- count, count2 = GetNearObject(Vector(minion), 200, minionTable.objects)
			-- if(count==1)then return Q:Cast(minion.x, minion.z) end
			if(multihit==1)then
				return Q:Cast(position.x, position.z)
			end
		end
	else
		-- if getDmg("Q", minion, myHero)/2 > PredHelth and not minion.dead then
			-- Q:Cast(minion.x, minion.z)
		-- end
	end
end
function CanAllKill(objects)
	boolean = true
	for index, enemy in ipairs(objects) do
		if( getDmg("Q", enemy, player)/2 < GetPredicHealth(enemy) )then
			boolean = false
		end
	end
	return boolean
end
function FindHitPosition(minion)
	minionTable:update()
	tempposition = Vector(0, 0, 0)
	multihit = 0;
	for i = -160, 160, 10 do
		for a = -160, 160, 10 do
			tempposition = Vector(minion.x+i, minion.y+a, minion.z)
			multihit = GetNearObject(tempposition, 200, minionTable.objects)
			if(multihit == 1)then
				return tempposition, multihit
			end
		end
	end
	return Vector(0, 0, 0), multihit
end
function Combo()
	target = STS:GetTarget(Q.range)
	if target then
		if Config.Combo.UseQ then
			Q:Cast(target)
		end
		if Config.Combo.UseW then
			W:Cast(target)
		end
		if Config.Combo.UseE and not EActive and GetDistance(target) < E.range then
			E:Cast()
		end
	end
end
function Harass()
	if IsManaLow(Config.Harass.mper) then return end
	target = STS:GetTarget(Q.range)
	if target then
		if Config.Harass.UseQ then
			Q:Cast(target)
		end
		if Config.Harass.UseW then
			W:Cast(target)
		end
	end
end
function Farm()
	if IsManaLow(Config.Farm.mper) then return end
	FarmQ()
end
function LineClear()
	if IsManaLow(Config.LineClear.mper) then return end
	minionTable:update()
	for i, minion in pairs(minionTable.objects) do
		if minion ~= nil and not minion.dead and GetDistance(minion) < 975 and Config.LineClear.UseQ then
			local bestpos, besthit = GetBestCircularFarmPosition(875, 200, minionTable.objects)
			if bestpos ~= nil then
				CastSpell(_Q, bestpos.x, bestpos.z)
			end
		end
	end
end
function JungleClear()
	if IsManaLow(Config.JungleClear.mper) then return end
	jungleTable:update()
	for i, minion in pairs(jungleTable.objects) do
		if minion ~= nil and not minion.dead and GetDistance(minion) < 975 and Config.JungleClear.UseQ then
			local bestpos, besthit = GetBestCircularFarmPosition(875, 200, jungleTable.objects)
			if bestpos ~= nil then
				CastSpell(_Q, bestpos.x, bestpos.z)
			end
		end
	end
end
function OnPassive()
	target = STS:GetTarget(Q.range)
	if target ~= nil then
		Q:Cast(target)
		W:Cast(target)
	end
end






function OnApplyBuff(source, unit, buff)
	if unit and unit.isMe and buff.name == "KarthusDefile" then
		EActive = true
    end
	if unit and unit.isMe and buff.name == "KarthusDeathDefiedBuff" then
		dead = true
	end
end
function OnRemoveBuff(unit, buff)
	if unit and unit.isMe and buff.name == "KarthusDefile" then
		EActive = false
    end
	if unit and unit.isMe and buff.name == "KarthusDeathDefiedBuff" then
		dead = false
	end
end
function OnWndMsg(msg, wParam)
	if msg == 513 then
		-- print("Mouse Left Click")
		LBClicked = true
	elseif msg == 514 then
		-- print("Mouse Left Release")
		LBClicked = false
	end
end
function GetPredicHealth(target)
	local PredHelth
	if _G.srcLib.HP ~= nil then
		PredHelth = _G.srcLib.HP:PredictHealth(target, 1.1)
	elseif _G.srcLib.VP ~= nil then
		PredHelth = _G.srcLib.VP:GetPredictedHealth(target, 0, 1.1)
	else
		PredHelth = target.health
	end
	return PredHelth
end
function IsManaLow(per)
	if per == nil then return false end
	return ((myHero.mana / myHero.maxMana * 100) <= per)
end