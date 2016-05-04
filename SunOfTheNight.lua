local Addon = CreateFrame("FRAME");

local sunNight;

local arctan2 = math.atan2;
local width, height = GetScreenWidth(), GetScreenHeight();
local pi = math.pi;
local abs = math.abs;

--util table to know when to use st,nd,rd or th
local days = {
	[1] = "st",
	[2] = "nd",
	[3] = "rd",
	[21] = "st",
	[22] = "nd",
	[23] = "rd",
	[31] = "st",
};

local pairs = pairs;
local GetCursorPosition = GetCursorPosition;

--table of options
local options = {};

local function createBackground()
	sunNight.background = CreateFrame("FRAME", "SunOfTheNightBackground", WorldFrame);
	SetSize(sunNight.background, GetScreenWidth(), GetScreenHeight());
	sunNight.background:SetAllPoints(WorldFrame);
	sunNight.background.texture = sunNight.background:CreateTexture();
	sunNight.background.texture:SetAllPoints(sunNight.background);
	sunNight.background.texture:SetTexture("Interface\\AddOns\\SunOfTheNight\\Textures\\bg.blp");
	
	sunNight.background:SetFrameStrata("DIALOG");
	
	sunNight.background:SetAlpha(0.3);
	
	sunNight.background:SetAlpha(0);
	sunNight.background:Hide();
	
	
	--BottomPanel with info
	sunNight.bottomPanel = {};
	
	--Background Panel
	sunNight.bottomPanel.bottom = sunNight:CreateTexture();
	sunNight.bottomPanel.bottom:SetTexture(0.02,0.02,0.02,0.6);
	SetSize(sunNight.bottomPanel.bottom, GetScreenWidth(), 150);
	sunNight.bottomPanel.bottom:SetPoint("BOTTOM", sunNight.background, 0, 0);
	
	--Thin upper line
	sunNight.bottomPanel.bottomLine = sunNight:CreateTexture(nil, "OVERLAY");
	sunNight.bottomPanel.bottomLine:SetTexture(0.4,0.4,0.4,0.9);
	SetSize(sunNight.bottomPanel.bottomLine, GetScreenWidth(), 2);
	sunNight.bottomPanel.bottomLine:SetPoint("BOTTOM", sunNight.background, 0, 145);
	
	--Experience bar
	sunNight.bottomPanel.experienceBar = sunNight:CreateTexture(nil, "OVERLAY");
	sunNight.bottomPanel.experienceBar:SetTexture("Interface\\AddOns\\SunOfTheNight\\Textures\\smallBar.blp");
	SetSize(sunNight.bottomPanel.experienceBar, 512*0.7, 64*0.7);
	sunNight.bottomPanel.experienceBar:SetPoint("BOTTOM", sunNight.background, 0, 95);
	
	--Experience fill bar
	sunNight.bottomPanel.experienceBarFill = CreateFrame("StatusBar", "SunNightExperienceBar", sunNight);
	sunNight.bottomPanel.experienceBarFill:SetStatusBarTexture("Interface\\AddOns\\SunOfTheNight\\Textures\\smallTextureBar.blp");
	SetSize(sunNight.bottomPanel.experienceBarFill, 187, 14);
	sunNight.bottomPanel.experienceBarFill:SetPoint("BOTTOM", sunNight.background, 1, 110);
	sunNight.bottomPanel.experienceBarFill:SetStatusBarColor(0.65,0.65,1,1);
	
	--Level label
	sunNight.bottomPanel.levelLabel = sunNight:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	sunNight.bottomPanel.levelLabel:SetFont("Interface\\AddOns\\SunOfTheNight\\Futura-Condensed-Normal.TTF", 16, "OUTLINE");
	sunNight.bottomPanel.levelLabel:SetTextColor(0.6, 0.6, 0.6, 1);
	sunNight.bottomPanel.levelLabel:SetText("LEVEL");
	sunNight.bottomPanel.levelLabel:SetShadowColor(0, 0, 0, 0.5);
	sunNight.bottomPanel.levelLabel:SetShadowOffset(2, -2);
	sunNight.bottomPanel.levelLabel:SetPoint("BOTTOM", sunNight.background, -170, 109);
	
	--Level number
	sunNight.bottomPanel.levelNumber = sunNight:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	sunNight.bottomPanel.levelNumber:SetFont("Interface\\AddOns\\SunOfTheNight\\Futura-Condensed-Normal.TTF", 28, "OUTLINE");
	sunNight.bottomPanel.levelNumber:SetTextColor(1, 1, 1, 1);
	sunNight.bottomPanel.levelNumber:SetText(UnitLevel("player"));
	sunNight.bottomPanel.levelNumber:SetShadowColor(0, 0, 0, 0.5);
	sunNight.bottomPanel.levelNumber:SetShadowOffset(2, -2);
	sunNight.bottomPanel.levelNumber:SetPoint("BOTTOM", sunNight.background, -140, 103);
	
	--Date hour
	sunNight.bottomPanel.time = sunNight:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	sunNight.bottomPanel.time:SetFont("Interface\\AddOns\\SunOfTheNight\\Futura-Condensed-Normal.TTF", 22, "OUTLINE");
	sunNight.bottomPanel.time:SetTextColor(1, 1, 1, 1);
	local day = days[date("%d")]
	if(not days[date("%d")]) then
		day = "th";
	end
	sunNight.bottomPanel.time:SetText(date("%A, %I:%M %p, %d"..day.." of %B, %Y"));
	sunNight.bottomPanel.time:SetShadowColor(0, 0, 0, 0.5);
	sunNight.bottomPanel.time:SetShadowOffset(2, -2);
	sunNight.bottomPanel.time:SetPoint("BOTTOM", sunNight.background, 450, 105);
	
	
end

local function updateBottomPanel()
	
	--update XP
	sunNight.bottomPanel.levelNumber:SetText(UnitLevel("player"));
	local currentXP, nextLevelXP = UnitXP("player"), UnitXPMax("player");
	sunNight.bottomPanel.experienceBarFill:SetMinMaxValues(0, nextLevelXP);
	sunNight.bottomPanel.experienceBarFill:SetValue(currentXP);
	
	--update time
	local day = days[date("%d")]
	if(not days[date("%d")]) then
		day = "th";
	end
	sunNight.bottomPanel.time:SetText(date("%A, %I:%M %p, %d"..day.." of %B, %Y"));
	
end


local function createSmokeEffect()

	if not sunNight.smokeFX then
    	sunNight.smokeFX = CreateFrame("FRAME", "SunOfTheNightSmokeFXFrame", sunNight.background);
    	sunNight.smokeFX.model = CreateFrame("PlayerModel", "SunOfTheNightSmokeFXFrameModel", sunNight.smokeFX);
    	
    	SetSize(sunNight.smokeFX.model, GetScreenWidth(), GetScreenHeight());
        sunNight.smokeFX.model:SetAllPoints(sunNight.smokeFX);
    
        sunNight.smokeFX.model:ClearModel();
    	
    	sunNight.smokeFX:SetFrameStrata("DIALOG");
    	SetSize(sunNight.smokeFX, GetScreenWidth(), GetScreenHeight());
    	sunNight.smokeFX:SetAllPoints();
	end
	
	sunNight.smokeFX.model:SetModel("World\\Environment\\doodad\\generaldoodads\\elementalrifts\\firerift.m2");
	--sunNight.smokeFX.model:SetPortraitZoom(0);
    --sunNight.smokeFX.model:SetCamDistanceScale(1);
    sunNight.smokeFX.model:SetPosition(-9,0,-6.1);
    --sunNight.smokeFX.model:SetRotation(0);
    
	sunNight.smokeFX:Show();
	
end


local function removeAllLightFrame()
	for num, fontFrame in pairs(options) do
		fontFrame.glow:SetAlpha(0);
		fontFrame.font:SetTextColor(0.5, 0.5, 0.5, 1);
	end
end

local function highlightFrame(fontFrame)
	removeAllLightFrame();
	fontFrame.glow:SetAlpha(0.5);
	fontFrame.font:SetTextColor(1, 1, 1, 1);
end


local function optionInsideAngle(angle)
	toggleSunNight();
	if (abs(angle) > 5/6*pi) then
		 SpellbookMicroButton:Click();
	elseif (angle > 2/3*pi) then
		ToggleCharacter("PaperDollFrame");
		CharacterFrameTab3:Click();
	elseif (angle > pi/3) then
		TalentMicroButton:Click();
	elseif (angle > pi/6) then
		ToggleCharacter("PaperDollFrame");
		CharacterFrameTab5:Click();
	elseif (abs(angle) < pi/6) then
		ToggleCharacter("PaperDollFrame");
	elseif (angle < -2/3*pi) then
		SocialsMicroButton:Click();
		FriendsFrameTab3:Click();
	elseif (angle < -pi/3) then
		WorldMapMicroButton:Click();
	else
		QuestLogMicroButton:Click();
	end
end

function toggleSunNight()
	if (sunNight:IsShown() or sunNight:GetAlpha() > 0) then
		sunNight:EnableMouse(false);
		UIFrameFadeIn(UIParent, 1-UIParent:GetAlpha(), UIParent:GetAlpha(), 1);
		UIFrameFadeOut(sunNight, sunNight:GetAlpha(), sunNight:GetAlpha(), 0);
		UIFrameFadeOut(sunNight.background, sunNight.background:GetAlpha(), sunNight.background:GetAlpha(), 0);
		sunNight:SetScript("OnUpdate", function(self, elapsed)
			if (sunNight:GetAlpha() == 0) then
				sunNight:SetScript("OnUpdate", nil);
				sunNight.background:Hide();
				sunNight:Hide();
			end
		end);
		UIParent:SetAlpha(1);
		
		BuffFrame:Show();
	else
		sunNight:EnableMouse(true);
		sunNight:Show();
		sunNight.background:Show();
		createSmokeEffect();
		UIFrameFadeOut(UIParent, UIParent:GetAlpha(), UIParent:GetAlpha(), 0);
		UIFrameFadeIn(sunNight, 1-sunNight:GetAlpha(), sunNight:GetAlpha(), 1);
		UIFrameFadeIn(sunNight.background, 1-sunNight.background:GetAlpha(), sunNight.background:GetAlpha(), 0.3);
		
		updateBottomPanel();
		
		BuffFrame:Hide();
	end	
end

local function createFontFrame(name, parent, framePoint, posX, posY, fontPoint, onClick, direction, glowX, glowY, rotation)
	local fontFrame = CreateFrame("FRAME", "SunOfTheNight" .. name, parent);
	SetSize(fontFrame, 128,32);
	fontFrame:SetPoint(framePoint, posX, posY);

	
	fontFrame.glow = fontFrame:CreateTexture("SunOfTheNight" .. name .. "Glow");
	fontFrame.glow:SetPoint(framePoint, sunNight, glowX, glowY);
	fontFrame.glow:SetTexture("Interface\\AddOns\\SunOfTheNight\\Textures\\" .. direction .. "Glow.blp");
	fontFrame.glow:SetBlendMode("ADD");
	fontFrame.glow:SetVertexColor(1, 1, 1, 0.7);
	SetRotation(fontFrame.glow, rotation);
	fontFrame.glow:SetAlpha(0);
	
	
	fontFrame.font = fontFrame:CreateFontString("SunOfTheNight" .. name .. "Font", "OVERLAY", "GameFontNormal");
	fontFrame.font:SetFont("Interface\\AddOns\\SunOfTheNight\\Futura-Condensed-Normal.TTF", 30, "OUTLINE");
	fontFrame.font:SetTextColor(0.6, 0.6, 0.6, 1);
	fontFrame.font:SetText(name);
	fontFrame.font:SetShadowColor(0, 0, 0, 0.5);
	fontFrame.font:SetShadowOffset(2, -2);
	fontFrame.font:SetPoint(fontPoint, 0, 0);
	
	fontFrame:EnableMouse(true);
	fontFrame:SetScript("OnMouseUp", onClick);
	
	table.insert(options, fontFrame);
	
	return fontFrame;
end


local function createOptions()

	sunNight.map = 			createFontFrame("Map", 				sunNight, "BOTTOM", 0, -25, "BOTTOM", 	function() toggleSunNight(); WorldMapMicroButton:Click(); end, "vertical", 0, -25, 0);
	sunNight.charInfo = 	createFontFrame("Character Info", 	sunNight, "RIGHT", 125,	 2, "RIGHT", 	function() toggleSunNight(); ToggleCharacter("PaperDollFrame"); end, "horizontal", 50, 1, 0);
	sunNight.talents = 		createFontFrame("Talents", 			sunNight, "TOP", 	0, 	25, "TOP", 		function() toggleSunNight(); TalentMicroButton:Click(); end, "vertical", 0, 25, 180);
	sunNight.spellbook = 	createFontFrame("Spellbook", 		sunNight, "LEFT", -80, 	 2, "LEFT", 	function() toggleSunNight(); SpellbookMicroButton:Click(); end, "horizontal", -50, 1, 180);

	sunNight.questLog = 	createFontFrame("Quest Log", 		sunNight, "BOTTOMRIGHT", -50, 10, "CENTER", function() toggleSunNight(); QuestLogMicroButton:Click(); end, "diagonal", -165, 37, -90);
	sunNight.guild = 		createFontFrame("Guild",	 		sunNight, "BOTTOMLEFT", 75, 10, "CENTER", 	function() toggleSunNight(); SocialsMicroButton:Click(); FriendsFrameTab3:Click(); end, "diagonal", 165, 37, 180);
	sunNight.pvp = 			createFontFrame("PvP", 				sunNight, "TOPRIGHT", -75, -10, "CENTER", 	function() toggleSunNight(); ToggleCharacter("PaperDollFrame"); CharacterFrameTab5:Click(); end, "diagonal", -165, -37, 0);
	sunNight.reputation = 		createFontFrame("Reputation", 	sunNight, "TOPLEFT", 25, -10, "CENTER", 	function() toggleSunNight(); ToggleCharacter("PaperDollFrame"); CharacterFrameTab3:Click(); end, "diagonal", 165, -37, 90);

end


local function initSunOfTheNight()

	sunNight = CreateFrame("FRAME", "SunOfTheNight");
	SetSize(sunNight, 512, 256);
	sunNight:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
	
	sunNight:SetFrameStrata("DIALOG");
	sunNight:SetFrameLevel(5);
	
	sunNight:SetAlpha(0);

	sunNight.starTexture = sunNight:CreateTexture("SunOfTheNightStarTexture");
	sunNight.starTexture:SetPoint("CENTER", sunNight);
	SetSize(sunNight.starTexture, 512, 256);
	sunNight.starTexture:SetTexture("Interface\\AddOns\\SunOfTheNight\\Textures\\star.blp");
	sunNight.starTexture:SetBlendMode("BLEND");
	sunNight.starTexture:SetVertexColor(1, 1, 1, 0.7);
	
	
	local oldTime, newTime = GetTime();
	sunNight:SetScript("OnShow", function(self)
		local total = 0;
		sunNight:SetScript("OnUpdate", function(self, elapsed)
			newTime = GetTime();
			elapsed = newTime - oldTime;
			oldTime = newTime;
			total = total + elapsed;
			if total > 0.01 then
				total = 0;
				local mouseX, mouseY = GetCursorPosition();
				local x,y = mouseX-width/2, mouseY-height/2;
				local angle = arctan2(y, x);
				--print(angle)
				
				--1st quarter
				if x > 0 and y > 0 then
					if angle < pi/6 then
						highlightFrame(sunNight.charInfo);
					elseif angle < pi/3 then
						highlightFrame(sunNight.pvp);
					else --if pi < pi/2 then
						highlightFrame(sunNight.talents);
					end
				--2nd quarter
				elseif x < 0 and y > 0 then
					if angle < 2/3*pi then
						highlightFrame(sunNight.talents);
					elseif angle < 5/6*pi then
						highlightFrame(sunNight.reputation);
					else --if angle < pi then
						highlightFrame(sunNight.spellbook);
					end				
				--3rd quarter
				elseif x < 0 and y < 0 then
					if -angle < 2/3*pi then
						highlightFrame(sunNight.map);
					elseif -angle < 5/6*pi then
						highlightFrame(sunNight.guild);
					else --if angle < pi then
						highlightFrame(sunNight.spellbook);
					end	
				--4th quarter
				else --x > 0 and y < 0 then
					if -angle < pi/6 then
						highlightFrame(sunNight.charInfo);
					elseif -angle < pi/3 then
						highlightFrame(sunNight.questLog);
					else --if pi < pi/2 then
						highlightFrame(sunNight.map);
					end
				end				
			end
		end);
	end);
	sunNight:SetScript("OnHide", function(self)
		sunNight:SetScript("OnUpdate", nil);
	end);
	
	sunNight:SetScript("OnMouseUp", function(self, button)
		local x, y = GetCursorPosition();
		optionInsideAngle(arctan2(y-height/2, x-width/2));
	end);

	sunNight:Hide();
	
end


Addon:SetScript("OnEvent", function(self, event)
	initSunOfTheNight();
	createBackground();
	createSmokeEffect();
	createOptions();
	
	Addon:UnregisterAllEvents();
end);

Addon:RegisterEvent("PLAYER_ENTERING_WORLD");



-- Binding Variables
BINDING_HEADER_HEADER = "Sun Of The Night";
BINDING_NAME_ENTRY = "Toggle Menu";




----------------------------
--Vanilla Missing Functions
----------------------------

function SetSize(frame, width, height)
	frame:SetHeight(height);
	frame:SetWidth(width);
end

local s2 = sqrt(2);
local cos, sin, rad = math.cos, math.sin, math.rad;
local function CalculateCorner(angle)
	local r = rad(angle);
	return 0.5 + cos(r) / s2, 0.5 + sin(r) / s2;
end
function SetRotation(texture, angle)
	local LRx, LRy = CalculateCorner(angle + 45);
	local LLx, LLy = CalculateCorner(angle + 135);
	local ULx, ULy = CalculateCorner(angle + 225);
	local URx, URy = CalculateCorner(angle - 45);
	
	texture:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
end
