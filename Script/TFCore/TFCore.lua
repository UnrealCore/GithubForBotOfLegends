
if myHero.charName ~= "TwistedFate" then return end

function Check(file_name)
	local file_found=io.open(file_name, "r")      

	if file_found==nil then
		return false
	else
		return true
	end
	return file_found
end

local SCRIPTNAME = "TFCore"

printMessage = function(message) print("<font color=\"#6699ff\"><b>" .. SCRIPTNAME .. ":</b></font> <font color=\"#FFFFFF\">" .. message .. "</font>") end
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

local VERSION = 1.0
SimpleUpdater("[TFCore]", VERSION, "raw.github.com" , "/UnrealCore/GithubForBotOfLegends/master/Script/TFCore/TFCore.lua" , SCRIPT_PATH .. "TFCore.lua" , "/UnrealCore/GithubForBotOfLegends/master/Script/TFCore/TFCore.version" ):CheckUpdate()

local OWM = OrbWalkManager(SCRIPTNAME)
local STS = SimpleTS()
local DLib = DamageLib()
local DM = DrawManager()
local CardSelecter = nil


function OnLoad()
	CardSelecter = Selecter()
	TF = TF()
end

class('TF')
function TF:__init()
	self.Qangle = 28*math.pi/180
	self:Initialization()
	AddTickCallback(function() self:Tick() end)
	AddDrawCallback(function() self:Draw() end)
	AddProcessSpellCallback(function(unit, spell) self:OnProcessSpell(unit, spell) end)
end

function TF:Initialization()
	self.Q = Spell(_Q, 1450)
	self.Q:SetSkillshot(SKILLSHOT_LINEAR, 0.25, 40, 1000)
	
	DM:CreateCircle(myHero, self.Q.range, 1, {100, 255, 0, 0}, "Draw Q range")
	
	self.Config = scriptConfig(SCRIPTNAME, SCRIPTNAME)
	
	self.Config:addSubMenu("TargetSelector","TargetSelector")
		STS:AddToMenu(self.Config.TargetSelector)
	
	self.Config:addSubMenu("OrbWalkManager", "OrbWalkManager")
		OWM:AddToMenu(self.Config.OrbWalkManager)
	
	self.Config:addSubMenu("Skillshot", "Skillshot")
		self.Q:AddToMenu(self.Config.Skillshot)
	
	self.Config:addSubMenu("DamageLib", "DamageLib")
		DLib:AddToMenu(self.Config.DamageLib, {})
	
	self.Config:addSubMenu("Draw", "Draw")
		DM:AddToMenu(self.Config.Draw)
	
	self.Config:addSubMenu("Q - Wildcards", "Q")
		self.Config.Q:addParam("AutoQI", "Auto Q immobile", SCRIPT_PARAM_ONOFF, true)
		self.Config.Q:addParam("AutoQD", "Auto Q dashing", SCRIPT_PARAM_ONOFF, true)
		self.Config.Q:addParam("AutoQS", "Auto Q stuned", SCRIPT_PARAM_ONOFF, true)
		self.Config.Q:addParam("CastQ", "Cast Q (tap)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('U'))
	
	self.Config:addSubMenu("W - pick a card", "W")
		self.Config.W:addParam("SelectYellow", "Select Yellow", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('W'))
		self.Config.W:addParam("SelectBlue", "Select Blue", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('E'))
		self.Config.W:addParam("SelectRed", "Select Red", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('T'))
	
	self.Config:addSubMenu("R - Destiny", "R")
		self.Config.R:addParam("AutoY", "Select yellow card after r", SCRIPT_PARAM_ONOFF, true)
	
end

function TF:Tick()
	CardSelecter:Tick()
	if self.Config.W.SelectYellow or OWM:IsComboMode() then
		CardSelecter:StartSelecting(C_YELLOW)
	end
	if self.Config.W.SelectBlue then
		CardSelecter:StartSelecting(C_BLUE)
	end
	if self.Config.W.SelectRed then
		CardSelecter:StartSelecting(C_RED)
	end
	
	
	for _, enemy in ipairs(GetEnemyHeroes())do
		if GetDistance(enemy) > self.Q.range then return end
		local isImmobile, pos = IsImmobile(enemy, 0.25+0.07 + GetLatency()/2000, 40, 1000, myHero)
		local isDashing, canHit, position = IsDashing(enemy, 0.25+0.07 + GetLatency()/2000, 40, 1000, myHero)
		local isSturned = HaveStun(enemy)
		if self.Config.Q.AutoQI and isImmobile then -- Immibile
			self:CastQ(enemy)
		end
		if self.Config.Q.AutoQD and isDashing and canHit then
			self:CastQ(enemy) -- Dash
		end
		-- print(tostring(isSturned))
		if self.Config.Q.AutoQS and isSturned then
			self:CastQ(enemy)
			-- self.Q:Cast(enemy)
			-- CastSpell(_Q, enemy.x, enemy.z)
		end
    end
	if OWM:IsComboMode()then
	
	end
	
	if self.Config.Q.CastQ then
		target = STS:GetTarget(self.Q.range)
		if target ~= nil then
			self.Q:Cast(target)
		end
	end
	
end

function HaveStun(unit)
	for i = 1, unit.buffCount, 1 do      
		local buff = unit:getBuff(i) 
		if ValidTarget(unit, 1500) and buff.valid and buff.type == 5 then
			return true            
		end                    
	end
	return false
end

function HasBuff(unit, buffname)
    for i = 1, unit.buffCount do
        local tBuff = unit:getBuff(i)
        if tBuff.valid and BuffIsValid(tBuff) and tBuff.name == buffname then
            return true
        end
    end
    return false
end

function TF:Draw()
	-- pos = Extends(myHero, mousePos, 0)
	-- pos:rotateYaxis(math.rad(self.Qangle))
	-- pos:rotateZaxis(math.rad(self.Qangle))
	-- pos2 = (Vector(pos) * Vector(myHero)):normalized()
	-- pos2 = vec2(pos.x, pos.z):rotate(self.Qangle)
	-- pos3 = vec2(pos.x, pos.z):rotate(-self.Qangle)
	-- DrawCircle(pos.x, pos.y, pos.z, 100, ARGB(100, 255, 0, 0))
	-- DrawCircle(pos2.x, pos2.y, pos2.z, 100, ARGB(100, 255, 0, 0))
	-- DrawCircle(mainPos.x, mainPos.y, mainPos.z, 100, ARGB(100, 255, 0, 0))
	
	-- target = mousePos
	-- minTargets = minTarget or 0
	-- points = {mousePos}
	-- hitBoxes = {20}
	
	-- startPoint = Vector(myHero)
	-- originalDirection = Extends(myHero, target, 0)  -- self.Q.range * (Vector(target) - startPoint):normalized()
	
	-- for _, enemy in ipairs(GetEnemyHeroes())do
		-- if enemy.valid then
			-- pos, hit, pos2 = self.Q:GetPrediction(enemy)
			-- if(hit >= self.Q.hitChance)then
				-- table.insert(points, Vector(pos))
				-- table.insert(hitBoxes, enemy.boundingRadius)
			-- end
		-- end
	-- end
	
	-- posiblePositions = self:GetQCardDrawEndPoints(myHero, originalDirection)
	
	-- if(GetDistance(target) < 900)then
		-- for i = 1, 3 do
			-- pos = posiblePositions[i]
			-- direction = (pos - startPoint):normalized():perpendicular()
			-- k = (2/3*(20 + 40)) --target.boundingRadius
			-- table.insert(posiblePositions, startPoint - k * direction )
			-- table.insert(posiblePositions, startPoint + k * direction )
		-- end
	-- end
	
	-- bestPosition = nil
	-- bestHit = - 1
	
	-- for _ , position in ipairs(posiblePositions) do
		-- hit = self:CountHits(position, GetEnemyHeroes())
		-- if hit > bestHit then
			-- bestPosition = position
			-- bestHit = hit
		-- end
		-- DrawCircle(position.x, position.y, position.z, 100, ARGB(100, 255, 0, 0) )
	-- end
end

function TF:GetQCardDrawEndPoints(from, to)
	originalDirection = 1450 * (Vector(to) - Vector(from)):normalized()
	backup = originalDirection
	
	mainPos = (Vector(from) + Vector(originalDirection))
	-- originalDirection:rotateYaxis(self.Qangle)
	-- mainPos = 
	originalDirection:rotateYaxis(math.rad(28))
	p = (Vector(from) + Vector(originalDirection))
	
	originalDirection = backup
	originalDirection:rotateYaxis(math.rad(-56))
	p2 = (Vector(from) + Vector(originalDirection))
	value = {mainPos, p, p2}
	return value
end

function Extends(v1, v2, v3)
	return Vector(v1) + (Vector(v2) - Vector(v1)):normalized() * (GetDistance(v1, v2)+v3)
end

function TF:OnProcessSpell(object, data)
	if(object.isMe and data.name=="gate" and self.Config.R.AutoY)then
		CardSelecter:StartSelecting(C_YELLOW)
	end
	-- if object.isMe then
		-- print(data.name)
	-- end
end

function TF:CountHits(points, objects)
	-- result = 0
	-- for i = 1, #points+1 do
		-- point = points[i]
		-- endPoint = self:GetQCardDrawEndPoints(myHero, position)
		-- for k = 1, 3 do
			-- local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(myHero, endPoint[k], )
		-- end
	-- end
	
	result = 0
	-- poly = Polygon()
	selfPoint = {}
	secPoint = self:GetQCardDrawEndPoints(myHero, points)
	for _, secP in ipairs(secPoint) do
		from = Vector(myHero)
		to = Vector(secP)
		From = from + ( from - to ):normalized()
		FromL = From + ( to - from ):perpendicular():normalized() * 20
		FromR = From + ( to - from ):perpendicular2():normalized() * 20
		To = to + ( to - from ):normalized()
		ToL = To + ( to - from ):perpendicular():normalized() * 20
		ToR = To + ( to - from ):perpendicular2():normalized() * 20
		
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
	end
	return result
end

-- local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(StartPos, EndPos, object)
-- if isOnSegment and GetDistanceSqr(pointSegment, object) < width * width then
	-- n = n + 1
-- end

function TF:CastQ(target, minTarget)
	minTargets = minTarget or 0
	points = {}
	hitBoxes = {}
	
	startPoint = Vector(myHero)
	originalDirection = Extends(myHero, target, 0) -- self.Q.range * (Vector(target) - startPoint):normalized()
	
	for _, enemy in ipairs(GetEnemyHeroes())do
		if enemy.valid then
			pos, hit, pos2 = self.Q:GetPrediction(enemy)
			if(hit >= self.Q.hitChance)then
				table.insert(points, Vector(pos))
				table.insert(hitBoxes, enemy.boundingRadius)
			end
		end
	end
	
	posiblePositions = self:GetQCardDrawEndPoints(myHero, originalDirection)
	
	-- if(GetDistance(target) < 900)then
		-- for i = 1, 3 do
			-- pos = posiblePositions[i]
			-- direction = (pos - startPoint):normalized():perpendicular()
			-- k = (2/3*(target.boundingRadius + 40))
			-- table.insert(posiblePositions, startPoint - k * direction )
			-- table.insert(posiblePositions, startPoint + k * direction )
		-- end
	-- end
	
	bestPosition = nil
	bestHit = - 1
	
	for _ , position in ipairs(posiblePositions) do
		hit = self:CountHits(position, GetEnemyHeroes())
		if hit > bestHit then
			bestPosition = position
			bestHit = hit
		end
	end
	
	if(bestHit + 1 <= minTargets)then return end
	CastSpell(_Q, bestPosition.x, bestPosition.z)
	-- self.Q:Cast(target)
end


C_READY = 0
C_SELECTING = 1
C_SELECTED = 2
C_COOLDOWN = 3

C_RED = 10
C_BLUE = 11
C_YELLOW = 12
C_NONE = 13

class('Selecter')
function Selecter:__init()
	self.Status = nil
	self.Select = nil
	self.LastWSent = 0;
	self.LastSendWSend = 0;
end

function Selecter:StartSelecting(card)
	if myHero:GetSpellData(_W).name == "PickACard" and self.Status == C_READY then
		self.Select = card
		if(GetTickCount() - self.LastWSent > 170 + GetLatency() /2)then
			CastSpell(_W)
			self.LastWSent = GetTickCount()
		end
	end
end

function Selecter:Tick()
	wName = myHero:GetSpellData(_W).name
	wState = myHero:CanUseSpell(_W)
	if((wState == READY and wName == "PickACard" and (self.Status ~= C_SELECTING or GetTickCount() - self.LastWSent > 500)) or myHero.dead)then
		self.Status = C_READY
	else
		if(wState == COOLDOWN and wName == "PickACard")then
			self.Select = C_NONE
			self.Status = C_COOLDOWN
		else
			if(wState == SUPRESSED and not myHero.dead)then
				self.Status = C_SELECTED
			end
			if(self.Select == C_BLUE and wName == "bluecardlock")then
				CastSpell(_W)
			elseif(self.Select == C_RED and wName == "redcardlock")then
				CastSpell(_W)
			elseif(self.Select == C_YELLOW and wName == "goldcardlock")then
				CastSpell(_W)
			end
		end
	end
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

local BuffTypes = {
            --[3] = true, --DEBUFF
            [5] = true, --stun
            [7] = true, --Silence
            [8] = true, --taunt
            [10] = false, --SLOW
            [11] = true, --root        
            [21] = true, --fear
            [22] = true, --charm
            [24] = true, --suppress
            [28] = true, --flee
            [29] = true, --knockup
}

local TargetsImmobile = {}
local TargetsDashing = {}
local TargetsSlowed = {}
local TargetsStuned = {}

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

function IsSturned(unit)
	if TargetsStuned[unit.networkID] == true then
		return true
	end	
	return false
end

AddApplyBuffCallback(function(u, s, b) OnApplyBuff(u, s, b) end)
AddRemoveBuffCallback(function(u, b) OnRemoveBuff(u, b) end)

function OnApplyBuff(unit,sorce,buff)
	-- if unit and unit.team ~= myHero.team and unit.type == myHero.type then
		-- print(unit.charName .. " " .. buff.name)
	-- end
	-- if unit and buff.type == 5 then
		-- print(unit.charName .. " " ..buff.type)
		-- TargetsStuned[unit.networkID] = true
	-- end
end

function OnRemoveBuff(unit, buff)
	if unit and buff.type == 5 then
		TargetsStuned[unit.networkID] = false
	end
end


-- if not work i make vec class mather fucker

-- function Vec2Type(v)
	-- return v and v.x and type(v.x) == "number" and (v.y and type(v.y) == "number")
-- end

-- class('vec2')
-- function vec2:__init(v1, v2)
	-- if v1 == nil then
		-- self.x, self.y = 0.0, 0.0
	-- elseif v2 == nil then
		-- assert(Vec2Type(v1), "vec2 __init : wrong argument type (nil or <vec2> or 2 <num>)")
		-- self.x, self.y = v.x, v.y
	-- else
		-- assert(type(v1) == "number" and type(v2) == "number", "vec2 __init : wrong argument type (nil or <vec2> or 2 <num>)")
		-- self.x, self.y = v1, v2
	-- end
-- end
-- function vec2:__unm() return vec2(-self.x, self.y) end
-- function vec2:__add(v)
	-- if(type(v) == "number")then
		-- return vec2(self.x + v, self.y + v) 
	-- else
		-- assert(Vec2Type(v), "vec2 __add")
		-- return vec2(self.x + v.x, self.y + v.y) 
	-- end 
-- end
-- function vec2:__sub(v) 
	-- if(type(v) == "number")then
		-- return vec2(self.x - v, self.y - v) 
	-- else
		-- assert(Vec2Type(v), "vec2 __sub")
		-- return vec2(self.x - v.x, self.y - v.y) 
	-- end 
-- end
-- function vec2:__mul(v) 
	-- if(type(v) == "number")then
		-- return vec2(self.x * v, self.y * v) 
	-- else
		-- assert(Vec2Type(v), "vec2 __mul")
		-- return vec2(self.x * v.x, self.y * v.y) 
	-- end
-- end
-- function vec2:__div(v) 
	-- if(type(v) == "number")then
		-- return vec2(self.x / v, self.y / v) 
	-- else
		-- assert(Vec2Type(v), "vec2 __div")
		-- return vec2(self.x / v.x, self.y / v.y) 
	-- end
-- end
-- function vec2:__mod(v) 
	-- if(type(v) == "number")then
		-- return vec2(self.x % v, self.y % v) 
	-- else
		-- assert(Vec2Type(v), "vec2 __mod")
		-- return vec2(self.x % v.x, self.y % v.y) 
	-- end
-- end
-- function vec2:__pow(v) 
	-- if(type(v) == "number")then
		-- return vec2(self.x ^ v, self.y ^ v) 
	-- else
		-- assert(Vec2Type(v), "vec2 __pow")
		-- return vec2(self.x ^ v.x, self.y ^ v.y) 
	-- end
-- end
-- function vec2:__type() return "vec2" end
-- function vec2:__tostring() return string.format("(%s,%s)", self.x, self.y) end
-- function vec2:__le(v)
	-- assert(Vec2Type(v), "vec2 __le")
	-- return vec2(self.x <= v.x, self.y <= v.y) 
-- end
-- function vec2:__lt(v)
	-- assert(Vec2Type(v), "vec2 __lt")
	-- return vec2(self.x < v.x, self.y < v.y) 
-- end
-- function vec2:__eq(v)
	-- assert(Vec2Type(v), "vec2 __eq")
	-- return vec2(self.x == v.x, self.y == v.y) 
-- end

-- function vec2:len()
	-- return math.sqrt(self.x*self.x+self.y*self.y)
-- end
-- function vec2:angle_atan(v)
	-- return math.deg(math.atan2(v:len(), self:len()))
-- end
-- function vec2:distance(v)
	-- return math.abs(math.sqrt((self.x-v.x)^2+(self.y-v.y)^2))
-- end
-- function vec2:normalize()
	-- return vec2(self.x/self:len(), self.y/self:len())
-- end
-- function vec2:clone()
	-- return vec2(self.x, self.y)
-- end
-- function vec2:normalized()
	-- a = self:clone()
	-- a:normalize()
	-- return a
-- end
-- function vec2:rotate(ang)
	-- ang = math.rad(ang)
	-- c = math.cos(ang)
	-- s = math.sin(ang)
	-- return vec2(self.x*c-self.y*s, self.x*s+self.y*c)
-- end
-- function vec2:rotate_around_axis(ang, pos)
	-- ang = math.rad(ang)
	-- local c = math.cos(ang)
	-- local s = math.sin(ang)
	-- return vec2((pos.x+self.x)*c-(pos.y+self.y)*s, (pos.x+self.x)*s+(pos.y+self.y)*c)
-- end
