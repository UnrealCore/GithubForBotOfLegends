if myHero.charName ~= "Ahri" then return end

--[[

	just check for SourceLibk renamed to SourceLib_Fix
	
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
	print("AhriCore: Download Sourcelibk")
	return;
end

---------------------------------------------------------------------
local ScriptVersion = 1.1
SimpleUpdater("[AhriCore]", ScriptVersion, "raw.github.com" , "/UnrealCore/GithubForBotOfLegends/master/Script/AhriCore/AhriCore.lua" , SCRIPT_PATH .. "AhriCore.lua" , "/UnrealCore/GithubForBotOfLegends/master/Script/AhriCore/AhriCore.version" ):CheckUpdate()

local Q, W, E, R, Ignite

local OLib = OrbWalkManager()
local STS = SimpleTS()
local Config = scriptConfig("AhriCore", "AhriCore")
local DLib = DamageLib()
local CLib = DrawManager()
local enemyMinion, enemyJungle

function OnLoad()
	Q = Spell(_Q, 965)
	Q:SetSkillshot(SKILLSHOT_LINEAR, 100, 0.2, 1000)
	W = Spell(_W, 650)
	E = Spell(_E, 965)
	E:SetSkillshot(SKILLSHOT_LINEAR, 70, 0.2, 1000, true)
	R = Spell(_R, 450)
	_Ignite = GetSummonerSlot("summonerdot", myHero)
	if(_Ignite ~= nil) then
		Ignite = Spell(_Ignite, 450)
	end
	
	enemyMinion = minionManager(MINION_ENEMY, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	enemyJungle = minionManager(MINION_JUNGLE, Q.range, myHero, MINION_SORT_MAXHEALTH_DEC)
	
	CLib:CreateCircle(myHero, Q.range, 1, {100, 255, 0, 0}, "Draw Q range")
	CLib:CreateCircle(myHero, W.range, 1, {100, 255, 0, 0}, "Draw W range")
	CLib:CreateCircle(myHero, W.range, 1, {100, 255, 0, 0}, "Draw W range")
	
	
	DLib:RegisterDamageSource(_Q, _MAGIC, 40, 15, _MAGIC, _AP, 0.35, function() return (player:CanUseSpell(_Q) == READY) end)
	DLib:RegisterDamageSource(_W, _MAGIC, 40, 15, _MAGIC, _AP, 0.4, function() return (player:CanUseSpell(_W) == READY) end)
	DLib:RegisterDamageSource(_E, _MAGIC, 60, 35, _MAGIC, _AP, 0.5, function() return (player:CanUseSpell(_E) == READY) end)
	DLib:RegisterDamageSource(_R, _MAGIC, 70, 40, _MAGIC, _AP, 0.3, function() return (player:CanUseSpell(_R) == READY) end)
	
	Config:addSubMenu("OrbWalkManager", "OLib")
		OLib:AddToMenu(Config.OLib)
	
	Config:addSubMenu("TargetSelector", "TargetSelector")
		STS:AddToMenu(Config.TargetSelector)
	
	Config:addSubMenu("DamageLib", "DamageLib")
		DLib:AddToMenu(Config.DamageLib, {_Q, _W, _E, _R})
	
	Config:addSubMenu("Combo", "Combo")
		Config.Combo:addParam("Q", "Use Q in combo mode", SCRIPT_PARAM_ONOFF, true)
		Config.Combo:addParam("W", "Use W in combo mode", SCRIPT_PARAM_ONOFF, true)
		Config.Combo:addParam("E", "Use E in combo mode", SCRIPT_PARAM_ONOFF, true)
		--Config.Combo:addParam("R", "Use E + R in combo mode", SCRIPT_PARAM_ONOFF, true)
	
	Config:addSubMenu("Harass", "Harass")
		Config.Harass:addParam("Q", "Use Q in harass mode", SCRIPT_PARAM_ONOFF, true)
		Config.Harass:addParam("W", "Use W in harass mode", SCRIPT_PARAM_ONOFF, true)
		Config.Harass:addParam("E", "Use E in harass mode", SCRIPT_PARAM_ONOFF, true)
		Config.Harass:addParam("EHitchance", "Use Hitchance only for harass E", SCRIPT_PARAM_SLICE, 0, 0, 3, 1)
		Config.Harass:addParam("EHitchanceInfo", "If you want not use upper manu then", SCRIPT_PARAM_INFO, "")
		Config.Harass:addParam("EHitchanceInfo2", "set value to 0", SCRIPT_PARAM_INFO, "")
		Config.Harass:addParam("LimitMana", "Use harass if my mana >=", SCRIPT_PARAM_SLICE, 50, 1, 100)
	
	Config:addSubMenu("Harass Toggle", "HarassT")
		Config.HarassT:addParam("Q", "Use Q in harass toggle mode", SCRIPT_PARAM_ONOFF, true)
		Config.HarassT:addParam("W", "Use W in harass toggle mode", SCRIPT_PARAM_ONOFF, false)
		Config.HarassT:addParam("E", "Use E in harass toggle mode", SCRIPT_PARAM_ONOFF, false)
		Config.HarassT:addParam("HotKey", "Use Harass toggle key", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte('T'))
	
	Config:addSubMenu("LastHit", "LastHit")
		Config.LastHit:addParam("Q", "Use Q in harass toggle mode", SCRIPT_PARAM_ONOFF, true)
		Config.LastHit:addParam("LimitMana", "Use lasthit if my mana >=", SCRIPT_PARAM_SLICE, 50, 1, 100)
		Config.LastHit:addParam("SafeMode", "Don't use q when enemy close", SCRIPT_PARAM_ONOFF, true)
		Config.LastHit:addParam("SafeModeRange", "Limit range", SCRIPT_PARAM_SLICE, 1000, 1, 1000)
	
	Config:addSubMenu("LineClear", "LineClear")
		Config.LineClear:addParam("Q", "Use Q in line clear", SCRIPT_PARAM_ONOFF, true)
		Config.LineClear:addParam("W", "Use W in line clear", SCRIPT_PARAM_ONOFF, false)
		Config.LineClear:addParam("E", "Use E in line clear", SCRIPT_PARAM_ONOFF, false)
		Config.LineClear:addParam("LimitMana", "Use line clear if my mana >=", SCRIPT_PARAM_SLICE, 50, 1, 100)
	
	Config:addSubMenu("JungleClear", "JungleClear")
		Config.JungleClear:addParam("Q", "Use Q in Jungle clear", SCRIPT_PARAM_ONOFF, true)
		Config.JungleClear:addParam("W", "Use W in Jungle clear", SCRIPT_PARAM_ONOFF, false)
		Config.JungleClear:addParam("E", "Use E in Jungle clear", SCRIPT_PARAM_ONOFF, false)
		Config.JungleClear:addParam("LimitMana", "Use Jungle clear if my mana >=", SCRIPT_PARAM_SLICE, 50, 1, 100)
	
	Config:addSubMenu("KS Mode", "KSMode")
		Config.KSMode:addParam("Q", "Killsteal with Q", SCRIPT_PARAM_ONOFF, true)
		Config.KSMode:addParam("W", "Killsteal with W", SCRIPT_PARAM_ONOFF, true)
		Config.KSMode:addParam("E", "Killsteal with E", SCRIPT_PARAM_ONOFF, true)
		--Config.KSMode:addParam("Ignite", "Killsteal with Ignite", SCRIPT_PARAM_ONOFF, true)
	
	Config:addSubMenu("Free", "Free")
		Config.Free:addParam("Q", "Use Q in free mode", SCRIPT_PARAM_ONOFF, true)
		Config.Free:addParam("E", "Use E in free mode", SCRIPT_PARAM_ONOFF, true)
		Config.Free:addParam("R", "Use R in free mode", SCRIPT_PARAM_ONOFF, true)
		Config.Free:addParam("HotKey", "HotKey", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('G'))
	
	Config:addSubMenu("AutoR", "AutoR")
		Config.AutoR:addParam("UseInCombo", "Use R when combo kill in combo mode", SCRIPT_PARAM_ONKEYTOGGLE,false, string.byte('U'))
		--Config.AutoR:addParam()

	
	Config:addSubMenu("Draw", "Draw")
		CLib:AddToMenu(Config.Draw)
	
	Config:addSubMenu("Spell Settings", "SS")
		Config.SS:addSubMenu("Q", "Q")
			Q:AddToMenu(Config.SS.Q)
		Config.SS:addSubMenu("W", "W")
			W:AddToMenu(Config.SS.W)
		Config.SS:addSubMenu("E", "E")
			E:AddToMenu(Config.SS.E)
		Config.SS:addSubMenu("R", "R")
			R:AddToMenu(Config.SS.R)
end

function OnTick()
	if (myHero.dead) then return end
	if (Config.HarassT.HotKey) then HarassToggle() end
	if (OLib:IsComboMode())then Combo()
	elseif OLib:IsHarassMode() then Harass()
	elseif OLib:IsLastHitMode() then LastHit()
	elseif OLib:IsClearMode() then 
		LineClear() 
		JungleClear()
	end
	if(Config.Free.HotKey) then Free() end
	RCombo()
end

function Combo()
	target = STS:GetTarget(Q.range)
	--targetR = STS:GetTarget(R.range + E.range)
	if(target ~= nil) then
		if(Config.Combo.E and GetDistance(target) < E.range and E:IsReady() )then E:Cast(target) end
		--
		if(Config.Combo.Q and GetDistance(target) < Q.range and Q:IsReady() )then Q:Cast(target) end
		if(Config.Combo.W and GetDistance(target) < W.range and W:IsReady() )then W:Cast() end
	end
end

function RCombo()
	target = STS:GetTarget(Q.range + E.range)
	if(Config.AutoR.UseInCombo and DLib:IsKillable(targetR, {_Q, _W, _E, _R}) and GetDistance(targetR) < E.range + R.range and target ~= nil ) then
		if(GetDistance(target) < 200) then
			pos = Extends2(target, myHero, 450)
			R:Cast(pos.x, pos.z) 
		else
			R:Cast(target) 
		end
	end
end

function Harass()
	if(IsManaLow(Config.Harass.LimitMana)) then return end
	target = STS:GetTarget(Q.range)
	if(target~=nil)then
		if(Config.Harass.E and E:IsReady())then
			if(Config.Harass.EHitchance ~= 0)then E:Cast(target) return end
			local SpellData = {}
			SpellData.castPosition, SpellData.hitChance, SpellData.position = E:GetPrediction(target)
			if(SpellData.hitChance >= Config.Harass.EHitchance)then
				E:__Cast(SpellData.castPosition.x, SpellData.castPosition.z)
			end
		end
		if(Config.Harass.Q and Q:IsReady() and GetDistance(target) < Q.range)then Q:Cast(target) end
		if(Config.Harass.W and W:IsReady() and GetDistance(target) < W.range)then W:Cast(target) end
	end
end

function HarassToggle()
	if(IsManaLow(Config.HarassT.LimitMana)) then return end
	local target = STS:GetTarget(R.range)
	if(target~=nil)then
		if(Config.HarassT.Q)then Q:Cast(target) end
		if(Config.HarassT.W)then W:Cast(target) end
		if(Config.HarassT.E)then E:Cast(target) end
	end
end

function LastHit()
	if(not Config.LastHit.Q)then return end
	if(IsManaLow(Config.LastHit.LimitMana))then return end
	enemyMinion:update()
	if(Config.LastHit.SafeMode)then
		for index, enemy in ipairs(GetEnemyHeroes()) do
			if(GetDistance(enemy) < Config.LastHit.SafeModeRange)then return end
		end
	end
	for index, minion in ipairs(enemyMinion.objects) do
		if(DLib:IsKillable(minion,{_Q}) and GetDistance(minion) < Q.range ) then 
			local CastPosition, Hitchance, position = Q:GetPrediction(minion)
			if(CastPosition ~= nil)then
				Q:Cast(CastPosition.x, CastPosition.z)
			end
		end
	end
end

function LineClear()
	if(IsManaLow(Config.LineClear.LimitMana))then return end
	enemyMinion:update()
	if(Config.LineClear.Q) then
		local BestPos, BestHit, BestObj = GetBestLineFarmPosition(Q.range, 100, enemyMinion.objects, myHero)
		if(BestPos ~= nil)then
			Q:Cast(BestPos.x, BestPos.z)
		end
	end
	if(Config.LineClear.W and CountObjectsNearPos(myHero, 70, 70, enemyMinion.objects) > 1) then
		W:Cast(minion) 
	end
	if(Config.LineClear.E) then 
		--E:Cast(minion) 
	end
end

--JungleClear

function JungleClear()
	if(IsManaLow(Config.JungleClear.LimitMana))then return end
	enemyJungle:update()
	if(Config.JungleClear.Q) then
		local BestPos, BestHit, BestObj = GetBestLineFarmPosition(Q.range, 100, enemyJungle.objects, myHero)
		if(BestPos ~= nil)then
			Q:Cast(BestPos.x, BestPos.z)
		end
	end
	if(Config.JungleClear.W and CountObjectsNearPos(myHero, 70, 70, enemyJungle.objects) > 1) then
		W:Cast(minion) 
	end
	if(Config.JungleClear.E) then 
		--E:Cast(minion) 
	end
end


function KillSteal()
	local target = STS:GetTarget(Q.range, 1, STS_LOW_HP_PRIORITY)
	if(Config.KSMode.Q and DLib:IsKillable(target,{_Q}) and Q:IsReady() and GetDistance(target) < Q.range) then Q:Cast(target) end
	if(Config.KSMode.W and DLib:IsKillable(target,{_W}) and W:IsReady() and GetDistance(target) < W.range) then W:Cast(target) end
	if(Config.KSMode.E and DLib:IsKillable(target,{_E}) and E:IsReady() and GetDistance(target) < E.range) then E:Cast(target) end
end

function IsManaLow(per)
	if per == nil then return false end
	return ((myHero.mana / myHero.maxMana * 100) <= per)
end

function Free()
	myHero:MoveTo(mousePos.x, mousePos.z)
	length, overWall = GetWallData(Vector(myHero), Vector(mousePos), 450)
	--GetWallLength(Vector(myHero), Vector(mousePos))
	--overWall = IsOverWall(Vector(myHero), Extends2(myHero, mousePos, 450))
	target = STS:GetTarget(Q.range, 1, STS_CLOSEST)
	
	if(Config.Free.Q)then
		if(target~=nil)then
			Q:Cast(target)
		else
			pos = Extends(Vector(myHero), mousePos, Q.range)
			Q:Cast(pos.x, pos.z)
		end
	end
	
	if(overWall and Config.Free.R)then
		local pos = Extends(Vector(myHero), mousePos, R.range)
		R:Cast(pos.x, pos.z)
	end
	
	if(Config.Free.E)then
		local collection = {}
		for index, enemy in ipairs(GetEnemyHeroes())do
			if(GetDistance(enemy) < E.range)then
				table.insert(collection, enemy)
			end
		end
	
		table.sort(collection, function(a, b) return GetDistance(a) < GetDistance(b) end)
		for index, enemy in ipairs(collection)do
			E:Cast(enemy)
		end
	end
end

function GetWallData(sPos, ePos, limitCheck)
	distance = GetDistance(sPos, ePos)
	Boolean = false
	fPos = 0
	lPos = 0
	for i = 0, distance, 10 do
		tempPos = Extends(sPos, ePos, i)
		if(IsWall(D3DXVECTOR3(tempPos.x, tempPos.y, tempPos.z)) and fPos == 0)then
			fPos = tempPos
		end
		lPos = tempPos
		if(not IsWall(D3DXVECTOR3(lPos.x, lPos.y, lPos.z)) and fPos ~= 0)then
			if(i < limitCheck)then Boolean = true end
			break
		end
	end
	if(fPos ==0 ) then fPos = Vector(0, 0, 0) end
	return GetDistance(fPos, lPos), Boolean
end

function GetWallPoint(startPos, endPos)
	distance = GetDistance(startPos, endPos)
	for i = 0, distance, 10 do
		tempPos = Extends(startPos, endPos, i)
		if(IsWall(D3DXVECTOR3(tempPos.x, tempPos.y, tempPos.z)))then
			return Extends(tempPos, startPos, -35)
		end
	end
end

function IsOverWall(sPos, ePos)
	distance = GetDistance(sPos, ePos)
	fPos = 0
	lPos = 0
	for i = 0, distance, 10 do
		tempPos = Extends(sPos, ePos, i)
		if(IsWall(D3DXVECTOR3(tempPos.x, tempPos.y, tempPos.z)) and fPos == 0)then
			fPos = tempPos
		end
		lPos = tempPos
		if(not IsWall(D3DXVECTOR3(lPos.x, lPos.y, lPos.z)) and fPos ~= 0)then
			return true
		end
	end
	return false
end

function GetWallLength(sPos, ePos)
	distance = GetDistance(sPos, ePos)
	fPos = 0
	lPos = 0
	for i = 0, distance, 10 do
		tempPos = Extends(sPos, ePos, i)
		if(IsWall(D3DXVECTOR3(tempPos.x, tempPos.y, tempPos.z)) and fPos == 0)then
			fPos = tempPos
		end
		lPos = tempPos
		if(not IsWall(D3DXVECTOR3(lPos.x, lPos.y, lPos.z)) and fPos ~= 0)then
			break
		end
	end
	if(fPos ==0 ) then fPos = Vector(0, 0, 0) end
	return GetDistance(fPos, lPos)
end

function GetFirstWallPoint(sPos, ePos)
	distance = GetDistance(sPos, ePos)
	for i = 0, distance, 10 do
		tempPos = Extends(sPos, ePos, i)
		if(IsWall(D3DXVECTOR3(tempPos.x, tempPos.y, tempPos.z)))then
			return Extends(tempPos, sPos, -35)
		end
	end
	return Vector(0, 0, 0)
end

function Extends(v1, v2, v3)
	return Vector(v1) + (Vector(v2) - Vector(v1)):normalized() * v3
end

function Extends2(v1, v2, v3)
	return Vector(v1) + (Vector(v2) - Vector(v1)):normalized() * (GetDistance(v1, v2)+v3)
end

function GetBestCircularFarmPosition(range, radius, objects)
    local BestPos 
    local BestHit = 0
    for i, object in ipairs(objects) do
        local hit = CountObjectsNearPos(object.pos or object, range, radius, objects)
        if hit > BestHit then
            BestHit = hit
            BestPos = Vector(object)
            if BestHit == #objects then
               break
            end
         end
    end
    return BestPos, BestHit
end

function GetBestLineFarmPosition(range, width, objects, from)
    local BestPos 
	local _from = from or myHero
    local BestHit = 0
    for i, object in ipairs(objects) do
        local EndPos = Vector(_from.pos) + range * (Vector(object) - Vector(_from.pos)):normalized()
        local hit = CountObjectsOnLineSegment(_from.pos, EndPos, width, objects)
        if hit > BestHit then
            BestHit = hit
            BestPos = Vector(object)
			BestObj = object
            if BestHit == #objects then
               break
            end
         end
    end
    return BestPos, BestHit, BestObj
end

function CountObjectsOnLineSegment(StartPos, EndPos, width, objects)
    local n = 0
    for i, object in ipairs(objects) do
        local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(StartPos, EndPos, object)
        if isOnSegment and GetDistanceSqr(pointSegment, object) < width * width then
            n = n + 1
        end
    end
    return n
end

function CountObjectsNearPos(pos, range, radius, objects)
    local n = 0
    for i, object in ipairs(objects) do
        if GetDistanceSqr(pos, object) <= radius * radius then
            n = n + 1
        end
    end
    return n
end