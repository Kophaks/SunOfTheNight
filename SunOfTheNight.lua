local Addon = CreateFrame("FRAME");

local sunNight;

local arctan2 = math.atan2;
local width, height = GetScreenWidth(), GetScreenHeight();
local pi = math.pi;
local abs = math.abs;

local pairs = pairs;
local GetCursorPosition = GetCursorPosition;


local function createBackground()
	sunNight.background = CreateFrame("FRAME", "SunOfTheNightBackground", WorldFrame);
	sunNight.background:SetSize(GetScreenWidth(), GetScreenHeight());
	sunNight.background:SetAllPoints(WorldFrame);
	sunNight.background.texture = sunNight.background:CreateTexture();
	sunNight.background.texture:SetAllPoints(sunNight.background);
	sunNight.background.texture:SetTexture("Interface\\AddOns\\SunOfTheNight\\bg.blp");
	
	sunNight.background:SetFrameStrata("DIALOG");
	
	sunNight.background:SetAlpha(0.3);
	
	sunNight.background:SetAlpha(0);
	sunNight.background:Hide();
	
end


local function createSmokeEffect()

	if not sunNight.smokeFX then
    	sunNight.smokeFX = CreateFrame("FRAME", "SunOfTheNightSmokeFXFrame", sunNight.background);
    	sunNight.smokeFX.model = CreateFrame("PlayerModel", "SunOfTheNightSmokeFXFrameModel", sunNight.smokeFX);
    	
    	sunNight.smokeFX.model:SetSize(GetScreenWidth(), GetScreenHeight());
        sunNight.smokeFX.model:SetAllPoints(sunNight.smokeFX);
    
        sunNight.smokeFX.model:ClearModel();
    	
    	sunNight.smokeFX:SetFrameStrata("DIALOG");
    	sunNight.smokeFX:SetSize(GetScreenWidth(), GetScreenHeight());
    	sunNight.smokeFX:SetAllPoints();
	end
	sunNight.smokeFX.model:SetModel("Spells\\Dragonbreath_frost.m2");
	sunNight.smokeFX.model:SetPortraitZoom(0);
    sunNight.smokeFX.model:SetCamDistanceScale(1);
    sunNight.smokeFX.model:SetPosition(5,2,-5);
    sunNight.smokeFX.model:SetRotation(0);
	sunNight.smokeFX:Show();
	
end


local function removeAllLightFrame()
	local options = { sunNight:GetChildren() };
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
		LFDMicroButton:Click();
	elseif (angle > pi/3) then
		TalentMicroButton:Click();
	elseif (angle > pi/6) then
		TogglePVPFrame();
	elseif (abs(angle) < pi/6) then
		ToggleCharacter("PaperDollFrame");
	elseif (angle < -2/3*pi) then
		GuildMicroButton:Click();
	elseif (angle < -pi/3) then
		MiniMapWorldMapButton:Click();
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
			if (self:GetAlpha() == 0) then
				self:SetScript("OnUpdate", nil);
				self.background:Hide();
				self:Hide();
			end
		end);
		UIParent:SetAlpha(1);
	else
		sunNight:EnableMouse(true);
		sunNight:Show();
		sunNight.background:Show();
		createSmokeEffect();
		UIFrameFadeOut(UIParent, UIParent:GetAlpha(), UIParent:GetAlpha(), 0);
		UIFrameFadeIn(sunNight, 1-sunNight:GetAlpha(), sunNight:GetAlpha(), 1);
		UIFrameFadeIn(sunNight.background, 1-sunNight.background:GetAlpha(), sunNight.background:GetAlpha(), 0.3);
	end	
end

local function createFontFrame(name, parent, framePoint, posX, posY, fontPoint, onClick, direction, glowX, glowY, rotation)
	local fontFrame = CreateFrame("FRAME", "SunOfTheNight" .. name, parent);
	fontFrame:SetSize(128,32);
	fontFrame:SetPoint(framePoint, posX, posY);

	
	fontFrame.glow = fontFrame:CreateTexture("SunOfTheNight" .. name .. "Glow");
	fontFrame.glow:SetPoint(framePoint, sunNight, glowX, glowY);
	fontFrame.glow:SetTexture("Interface\\AddOns\\SunOfTheNight\\" .. direction .. "Glow.blp");
	fontFrame.glow:SetBlendMode("ADD");
	fontFrame.glow:SetVertexColor(1, 1, 1, 0.7);
	fontFrame.glow:SetRotation(rotation);
	fontFrame.glow:SetAlpha(0);
	
	
	fontFrame.font = fontFrame:CreateFontString("SunOfTheNight" .. name .. "Font", "OVERLAY", "GameFontNormal");
	fontFrame.font:SetFont("Interface\\AddOns\\Rising\\Futura-Condensed-Normal.TTF", 30, "OUTLINE");
	fontFrame.font:SetTextColor(0.6, 0.6, 0.6, 1);
	fontFrame.font:SetText(name);
	fontFrame.font:SetShadowColor(0, 0, 0, 0.5);
	fontFrame.font:SetShadowOffset(2, -2);
	fontFrame.font:SetPoint(fontPoint, 0, 0);
	
	
	fontFrame:SetScript("OnMouseUp", onClick);
	

	return fontFrame;
end


local function createOptions()

	sunNight.map = 			createFontFrame("Map", 				sunNight, "BOTTOM", 0, -25, "BOTTOM", 	function() toggleSunNight(); MiniMapWorldMapButton:Click(); end, "vertical", 0, -25, 0);
	sunNight.charInfo = 	createFontFrame("Character Info", 	sunNight, "RIGHT", 125,	 2, "RIGHT", 	function() toggleSunNight(); ToggleCharacter("PaperDollFrame"); end, "horizontal", 50, 1, 0);
	sunNight.talents = 		createFontFrame("Talents", 			sunNight, "TOP", 	0, 	25, "TOP", 		function() toggleSunNight(); TalentMicroButton:Click(); end, "vertical", 0, 25, pi);
	sunNight.spellbook = 	createFontFrame("Spellbook", 		sunNight, "LEFT", -80, 	 2, "LEFT", 	function() toggleSunNight(); SpellbookMicroButton:Click(); end, "horizontal", -50, 1, pi);

	sunNight.questLog = 	createFontFrame("Quest Log", 		sunNight, "BOTTOMRIGHT", -50, 10, "CENTER", function() toggleSunNight(); QuestLogMicroButton:Click(); end, "diagonal", -165, 37, -pi/2);
	sunNight.guild = 		createFontFrame("Guild",	 		sunNight, "BOTTOMLEFT", 75, 10, "CENTER", 	function() toggleSunNight(); GuildMicroButton:Click(); end, "diagonal", 165, 37, pi);
	sunNight.pvp = 			createFontFrame("PvP", 				sunNight, "TOPRIGHT", -75, -10, "CENTER", 	function() toggleSunNight(); TogglePVPFrame(); end, "diagonal", -165, -37, 0);
	sunNight.dungeon = 		createFontFrame("Dungeon Finder", 	sunNight, "TOPLEFT", 25, -10, "CENTER", 	function() toggleSunNight(); LFDMicroButton:Click(); end, "diagonal", 165, -37, pi/2);

end


local function initSunOfTheNight()

	sunNight = CreateFrame("FRAME", "SunOfTheNight");
	sunNight:SetSize(512, 256);
	sunNight:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
	
	sunNight:SetFrameStrata("DIALOG");
	sunNight:SetFrameLevel(5);
	
	sunNight:SetAlpha(0);

	sunNight.starTexture = sunNight:CreateTexture("SunOfTheNightStarTexture");
	sunNight.starTexture:SetAllPoints(sunNight);
	sunNight.starTexture:SetTexture("Interface\\AddOns\\SunOfTheNight\\star.blp");
	sunNight.starTexture:SetBlendMode("BLEND");
	sunNight.starTexture:SetVertexColor(1, 1, 1, 0.7);
	
	

	sunNight:SetScript("OnShow", function(self)
		local total = 0;
		self:SetScript("OnUpdate", function(self, elapsed)
			total = total + elapsed;
			if total > 0.05 then
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
						highlightFrame(sunNight.dungeon);
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
		self:SetScript("OnUpdate", nil);
	end);
	
	sunNight:SetScript("OnMouseUp", function(self, button)
		if (button == "LeftButton") then
			local x, y = GetCursorPosition();
			optionInsideAngle(arctan2(y-height/2, x-width/2));
		end
	end);

	sunNight:Hide();
	
end





Addon:SetScript("OnEvent", function(self, event)
	initSunOfTheNight();
	createBackground();
	createSmokeEffect();
	createOptions();
end);

Addon:RegisterEvent("PLAYER_ENTERING_WORLD");



-- Binding Variables
BINDING_HEADER_HEADER = "Sun Of The Night";
BINDING_NAME_ENTRY = "Toggle Menu";
