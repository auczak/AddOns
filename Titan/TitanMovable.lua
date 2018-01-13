TITAN_PANEL_PLACE_TOP = 1;
TITAN_PANEL_PLACE_BOTTOM = 2;

TitanMovable = {};
TitanMovableData = {
	PlayerFrame = {frameName = "PlayerFrame", frameArchor = "TOPLEFT", xArchor = "LEFT", y = -4, position = TITAN_PANEL_PLACE_TOP},
	TargetFrame = {frameName = "TargetFrame", frameArchor = "TOPLEFT", xArchor = "LEFT", y = -4, position = TITAN_PANEL_PLACE_TOP},
	PartyMemberFrame1 = {frameName = "PartyMemberFrame1", frameArchor = "TOPLEFT", xArchor = "LEFT", y = -128, position = TITAN_PANEL_PLACE_TOP},
	TicketStatusFrame = {frameName = "TicketStatusFrame", frameArchor = "TOPRIGHT", xArchor = "RIGHT", y = 0, position = TITAN_PANEL_PLACE_TOP},
	TemporaryEnchantFrame = {frameName = "TemporaryEnchantFrame", frameArchor = "TOPRIGHT", xArchor = "RIGHT", y = -13, position = TITAN_PANEL_PLACE_TOP},
	MinimapCluster = {frameName = "MinimapCluster", frameArchor = "TOPRIGHT", xArchor = "RIGHT", y = 0, position = TITAN_PANEL_PLACE_TOP},
	WorldStateAlwaysUpFrame = {frameName = "WorldStateAlwaysUpFrame", frameArchor = "TOP", xArchor = "CENTER", y = -15, position = TITAN_PANEL_PLACE_TOP},
	MainMenuBar = {frameName = "MainMenuBar", frameArchor = "BOTTOM", xArchor = "CENTER", y = 0, position = TITAN_PANEL_PLACE_BOTTOM},
	MultiBarRight = {frameName = "MultiBarRight", frameArchor = "BOTTOMRIGHT", xArchor = "RIGHT", y = 98, position = TITAN_PANEL_PLACE_BOTTOM},
	CT_PlayerFrame_Drag = {frameName = "CT_PlayerFrame_Drag", frameArchor = "TOPLEFT", xArchor = "LEFT", y = -25, position = TITAN_PANEL_PLACE_TOP},
	CT_TargetFrame_Drag = {frameName = "CT_TargetFrame_Drag", frameArchor = "TOPLEFT", xArchor = "LEFT", y = -25, position = TITAN_PANEL_PLACE_TOP},
	Gypsy_PlayerFrameCapsule = {frameName = "Gypsy_PlayerFrameCapsule", frameArchor = "TOPLEFT", xArchor = "LEFT", y = 14, position = TITAN_PANEL_PLACE_TOP},
	Gypsy_TargetFrameCapsule = {frameName = "Gypsy_TargetFrameCapsule", frameArchor = "TOPLEFT", xArchor = "LEFT", y = 16, position = TITAN_PANEL_PLACE_TOP},
}

function TitanMovableFrame_OnLoad()
	-- Overwrite Blizzard Frame positioning functions
	hooksecurefunc("TicketStatusFrame_OnEvent", Titan_TicketStatusFrame_OnEvent)
	hooksecurefunc("FCF_UpdateDockPosition", Titan_FCF_UpdateDockPosition)
	hooksecurefunc("FCF_UpdateCombatLogPosition", Titan_FCF_UpdateCombatLogPosition)
	hooksecurefunc("updateContainerFrameAnchors", Titan_ContainerFrames_Relocate)
	hooksecurefunc(WorldMapFrame, "Hide", Titan_ManageFramesNew)
	hooksecurefunc("UIParent_ManageFramePositions", Titan_ManageFramesNew)
	this:RegisterEvent("UPDATE_TICKET");

	-- invalid hook, to be removed
	--if TitanPanelGetVar("CastingBar") then
		--hooksecurefunc("CastingBarFrame_UpdatePosition", Titan_CastingBarFrame_UpdatePosition)
	--end
	
	--WoW_UIParent_ManageRightSideFrames = UIParent_ManageRightSideFrames;
	--UIParent_ManageRightSideFrames = Titan_UIParent_ManageRightSideFrames;
end

function TitanMovableFrame_AdjustBlizzardFrames()
	if not InCombatLockdown() then
		Titan_FCF_UpdateDockPosition();
		Titan_FCF_UpdateCombatLogPosition();
		if TitanPanelGetVar("CastingBar") then
			Titan_CastingBarFrame_UpdatePosition();
		end

		--Titan_ContainerFrames_UpdatePosition();
		--Titan_UIParent_ManageRightSideFrames();
		Titan_ContainerFrames_Relocate();
	end
end

function TitanMovableFrame_CheckFrames(position)
	local top, bottom, panelYOffset, frameTop;
	
	TitanMovable = {};
		
	if (position == TITAN_PANEL_PLACE_TOP) then
	
		panelYOffset = TitanMovable_GetPanelYOffset(TITAN_PANEL_PLACE_TOP, TitanPanelGetVar("BothBars"));
		
		-- Move PlayerFrame
		if (CT_PlayerFrame_Drag) then
			frameTop = TitanMovableFrame_GetOffset(CT_PlayerFrame_Drag, "TOP");
			top = -25 + panelYOffset;
			TitanMovableFrame_CheckTopFrame(frameTop, top, CT_PlayerFrame_Drag:GetName());
		elseif (Gypsy_PlayerFrameCapsule) then
			frameTop = TitanMovableFrame_GetOffset(Gypsy_PlayerFrameCapsule, "TOP");
			top = 14 + panelYOffset;
			TitanMovableFrame_CheckTopFrame(frameTop, top, Gypsy_PlayerFrameCapsule:GetName());
		else
			frameTop = TitanMovableFrame_GetOffset(PlayerFrame, "TOP");
			top = -4 + panelYOffset;
			TitanMovableFrame_CheckTopFrame(frameTop, top, PlayerFrame:GetName())
		end
	
		-- Move TargetFrame
		if (CT_TargetFrame_Drag) then
			frameTop = TitanMovableFrame_GetOffset(CT_TargetFrame_Drag, "TOP");
			top = -25 + panelYOffset;
			TitanMovableFrame_CheckTopFrame(frameTop, top, CT_TargetFrame_Drag:GetName());
		elseif (Gypsy_TargetFrameCapsule) then
			frameTop = TitanMovableFrame_GetOffset(Gypsy_TargetFrameCapsule, "TOP");
			top = 14 + panelYOffset;
			TitanMovableFrame_CheckTopFrame(frameTop, top, Gypsy_TargetFrameCapsule:GetName());
		else
			frameTop = TitanMovableFrame_GetOffset(TargetFrame, "TOP");
			top = -4 + panelYOffset;
			TitanMovableFrame_CheckTopFrame(frameTop, top, TargetFrame:GetName())
		end

		-- Move PartyMemberFrame
		if (not CT_MovableParty1_Drag and not Gypsy_PartyFrameCapsule) then
			frameTop = TitanMovableFrame_GetOffset(PartyMemberFrame1, "TOP");
			top = -128 + panelYOffset;
			TitanMovableFrame_CheckTopFrame(frameTop, top, PartyMemberFrame1:GetName())
		end

		-- Move TicketStatusFrame
		frameTop = TitanMovableFrame_GetOffset(TicketStatusFrame, "TOP");
		top = 0 + panelYOffset;
		TitanMovableFrame_CheckTopFrame(frameTop, top, TicketStatusFrame:GetName())

		-- Move TemporaryEnchantFrame
		frameTop = TitanMovableFrame_GetOffset(TemporaryEnchantFrame, "TOP");
		if (TicketStatusFrame:IsVisible()) then
			top = 0 - TicketStatusFrame:GetHeight() + panelYOffset;
		else
			top = -13 + panelYOffset;
		end
		TitanMovableFrame_CheckTopFrame(frameTop, top, TemporaryEnchantFrame:GetName())
	
		-- Move MinimapCluster
		if (not CleanMinimap) then
		 if not TitanPanelGetVar("MinimapAdjust") then
		frameTop = TitanMovableFrame_GetOffset(MinimapCluster, "TOP");
		top = 0 + panelYOffset; 		
		TitanMovableFrame_CheckTopFrame(frameTop, top, MinimapCluster:GetName())
		 end
		end
		
		-- Move WorldStateAlwaysUpFrame
		frameTop = TitanMovableFrame_GetOffset(WorldStateAlwaysUpFrame, "TOP");
		top = -15 + panelYOffset; 		
		TitanMovableFrame_CheckTopFrame(frameTop, top, WorldStateAlwaysUpFrame:GetName());

	elseif (position == TITAN_PANEL_PLACE_BOTTOM) then

		panelYOffset = TitanMovable_GetPanelYOffset(TITAN_PANEL_PLACE_BOTTOM, TitanPanelGetVar("BothBars"));
		
		-- Move MainMenuBar
		if (not Gypsy_ActionBar and not BibActionBar1) then
			bottom = 0 + panelYOffset; 
			frameBottom = TitanMovableFrame_GetOffset(MainMenuBar, "BOTTOM");
			if (frameBottom >= 0) then
				TitanMovableFrame_CheckBottomFrame(frameBottom, bottom, MainMenuBar:GetName());
			end
		end
	
		-- Move MultiBarRight
		bottom = 98 + panelYOffset; 
		frameBottom = TitanMovableFrame_GetOffset(MultiBarRight, "BOTTOM");
		TitanMovableFrame_CheckBottomFrame(frameBottom, bottom, MultiBarRight:GetName());
	end	

end

function TitanMovableFrame_MoveFrames(position, override)
	local frameData, frame, frameName, frameArchor, xArchor, y, xOffset, yOffset, panelYOffset;
	
	if not InCombatLockdown() then
		for index, value in pairs(TitanMovable) do
			frameData = TitanMovableData[value];
			frame = getglobal(frameData.frameName);
			frameName = frameData.frameName;
			frameArchor = frameData.frameArchor;

			--if (not frame:IsUserPlaced()) then
				xArchor = frameData.xArchor;
				y = frameData.y;
				
				panelYOffset = TitanMovable_GetPanelYOffset(frameData.position, TitanPanelGetVar("BothBars"), override);
		
				xOffset = TitanMovableFrame_GetOffset(frame, xArchor);		
				if (frameName == "TemporaryEnchantFrame" and TicketStatusFrame:IsVisible()) then
					yOffset = (-TicketStatusFrame:GetHeight()) + panelYOffset;
				else
					yOffset = y + panelYOffset;	
				end
				
				-- adjust the MainMenuBar according to its scale
				if (frameName == "MainMenuBar" and MainMenuBar:IsVisible()) then
				local framescale = MainMenuBar:GetScale() or 1;
				    yOffset =  yOffset / framescale;
				end
				
				-- account for Reputation Status Bar (doh)
				local playerlevel = UnitLevel("player");
				if (frameName == "MultiBarRight" and ReputationWatchStatusBar:IsVisible() and playerlevel < MAX_PLAYER_LEVEL) then
		  	yOffset = yOffset + 8;
		  	end
				
				frame:ClearAllPoints();		
				frame:SetPoint(frameArchor, "UIParent", frameArchor, xOffset, yOffset);
			--else
				--Leave frame where it is as it has been moved by a user
			--end
			updateContainerFrameAnchors();
		end
	end
end

function TitanMovableFrame_GetOffset(frame, point)
	if (frame and point) then
		if (point == "LEFT" and frame:GetLeft() and UIParent:GetLeft()) then
			return frame:GetLeft() - UIParent:GetLeft();
		elseif (point == "RIGHT" and frame:GetRight() and UIParent:GetRight()) then
			return frame:GetRight() - UIParent:GetRight();			
		elseif (point == "TOP" and frame:GetTop() and UIParent:GetTop()) then
			return frame:GetTop() - UIParent:GetTop();
		elseif (point == "BOTTOM" and frame:GetBottom() and UIParent:GetBottom()) then
			return frame:GetBottom() - UIParent:GetBottom();
		elseif (point == "CENTER" and frame:GetLeft() and frame:GetRight() and UIParent:GetLeft() and UIParent:GetRight()) then
		   local framescale = frame and frame.GetScale and frame:GetScale() or 1;
			return (frame:GetLeft()* framescale + frame:GetRight()* framescale - UIParent:GetLeft() - UIParent:GetRight()) / 2;
		end
	end	
	return 0;
end

function TitanMovable_GetPanelYOffset(framePosition, bothbars, override)
	local barPosition = TitanPanelGetVar("Position");
	local barnumber = 0;

	if override then
		if framePosition == TITAN_PANEL_PLACE_TOP then
			if TitanPanelGetVar("ScreenAdjust") then
				return 0;
			end
		elseif framePosition == TITAN_PANEL_PLACE_BOTTOM and bothbars == nil then
			if TitanPanelGetVar("ScreenAdjust") then
				return 0;
			end
		elseif framePosition == TITAN_PANEL_PLACE_BOTTOM and bothbars == 1 then
			if TitanPanelGetVar("AuxScreenAdjust") then
				return 0;
			end
		else
			return 0;
		end
	end
	
	if bothbars ~= nil then
		barPosition = framePosition;
	else
		barPosition = TitanPanelGetVar("Position");
	end
	
	barnumber = TitanUtils_GetDoubleBar(bothbars, framePosition);
	
	local scale = TitanPanelGetVar("Scale");
	if (scale and framePosition and barPosition and framePosition == barPosition) then
		if (framePosition == TITAN_PANEL_PLACE_TOP) then
			return (-24 * scale)*(barnumber);
		elseif (framePosition == TITAN_PANEL_PLACE_BOTTOM) then
			return (24 * scale)*(barnumber);
		end
	end
	return 0;
end

function TitanMovableFrame_CheckTopFrame(frameTop, top, frameName)
	table.insert(TitanMovable, frameName);
end

function TitanMovableFrame_CheckBottomFrame(frameBottom, bottom, frameName)
	table.insert(TitanMovable, frameName);
end

function Titan_TicketStatusFrame_OnEvent(self, event, ...)
	local panelYOffset = TitanMovable_GetPanelYOffset(TITAN_PANEL_PLACE_TOP, TitanPanelGetVar("BothBars"));
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		GetGMTicket();
	elseif ( event == "UPDATE_TICKET" ) then
		local category = ...;
		if ( category ) then		
			this:Show();
			TemporaryEnchantFrame:SetPoint("TOPRIGHT", this:GetParent():GetName(), "TOPRIGHT", -205, 0 - this:GetHeight() + panelYOffset); -- ATTN
			refreshTime = GMTICKET_CHECK_INTERVAL;
		else
			this:Hide();
			TemporaryEnchantFrame:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -205, -13 + panelYOffset); -- ATTN
		end
	end	
end

function Titan_FCF_UpdateDockPosition()
	if not InCombatLockdown() then
		local panelYOffset = TitanMovable_GetPanelYOffset(TITAN_PANEL_PLACE_BOTTOM, TitanPanelGetVar("BothBars"));

		if ( DEFAULT_CHAT_FRAME:IsUserPlaced() ) then
			if ( SIMPLE_CHAT ~= "1" ) then
				return;
			end
		end
		
		local chatOffset = 85 + panelYOffset;
		if ( GetNumShapeshiftForms() > 0 or HasPetUI() or PetHasActionBar() ) then
			if ( MultiBarBottomLeft:IsVisible() or BOTTOMBAR_OFFSET_Y ) then
				chatOffset = chatOffset + 55;
			else
				chatOffset = chatOffset + 15;
			end
		elseif ( MultiBarBottomLeft:IsVisible() or BOTTOMBAR_OFFSET_Y ) then
			chatOffset = chatOffset + 15;
		end
		DEFAULT_CHAT_FRAME:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 32, chatOffset);
		FCF_DockUpdate();
	end
end

function Titan_FCF_UpdateCombatLogPosition()
	if not InCombatLockdown() then
		local panelYOffset = TitanMovable_GetPanelYOffset(TITAN_PANEL_PLACE_BOTTOM, TitanPanelGetVar("BothBars"));

local point1, _, relativePoint1, xOfs1, _ = ChatFrame1:GetPoint()
local point2, relativeTo, relativePoint2, xOfs2, yOfs2 = ChatFrame2:GetPoint()


		  if TitanPanelGetVar("LogAdjust") then
		  
			local xOffset = 0;
		  local yOffset = 85 + panelYOffset;
			local yOffset2 = 85 + panelYOffset;
			if MultiBarBottomLeft:IsVisible() then
				yOffset = yOffset + 20;
				yOffset2 = yOffset2 + 50;
				if GetNumShapeshiftForms() > 0 or HasPetUI() or PetHasActionBar() then 
				else
				yOffset2 = yOffset2 - 50;
				yOffset2 = yOffset2 + 15;
				end
			elseif MultiBarBottomRight:IsVisible() then
				yOffset = yOffset + 20;
				yOffset2 = yOffset2 + 50;
				if GetNumShapeshiftForms() > 0 or HasPetUI() or PetHasActionBar() then 
				else
				yOffset2 = yOffset2 - 50;
				yOffset2 = yOffset2 + 15;
				end
			else
				yOffset = yOffset + 5;
				yOffset2 = yOffset2 + 15;
			end
		 -- account for Reputation Status Bar (doh)
		  local playerlevel = UnitLevel("player");
			if ReputationWatchStatusBar:IsVisible() and playerlevel < MAX_PLAYER_LEVEL then
		  	yOffset = yOffset + 8;
				yOffset2 = yOffset2 + 8;
		  end
	
			if ( MultiBarLeft:IsVisible() ) then
				xOffset = xOffset - 88;
			elseif ( MultiBarRight:IsVisible() ) then
				xOffset = xOffset - 43;
			end
			--ChatFrame1:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 32, yOffset2);
			--ChatFrame2:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", xOffset, yOffset);
			if point1 == "BOTTOMLEFT" and relativePoint1 == "BOTTOMLEFT" then
			ChatFrame1:SetPoint(point1, "UIParent", relativePoint1, xOfs1, yOffset2);
			end
			if relativeTo == nil and point2 == "BOTTOMRIGHT" and relativePoint2 == "BOTTOMRIGHT" then
			ChatFrame2:SetPoint(point2, "UIParent", relativePoint2, xOfs2, yOffset);
			end
		  end
	end
end

function Titan_CastingBarFrame_UpdatePosition()
 if TitanPanelGetVar("CastingBar") then
	if not InCombatLockdown() then
		local panelYOffset = TitanMovable_GetPanelYOffset(TITAN_PANEL_PLACE_BOTTOM, TitanPanelGetVar("BothBars"));
		
		local castingBarPosition = 60 + panelYOffset;
		if ( PetActionBarFrame:IsVisible() or ShapeshiftBarFrame:IsVisible() ) then
			castingBarPosition = castingBarPosition + 40;
		end
		if ( MultiBarBottomLeft:IsVisible() or MultiBarBottomRight:IsVisible() ) then
			castingBarPosition = castingBarPosition + 40;
		end
		-- account for Reputation Status Bar (doh)
		local playerlevel = UnitLevel("player");
		if ReputationWatchStatusBar:IsVisible() and playerlevel < MAX_PLAYER_LEVEL then
		  castingBarPosition = castingBarPosition + 10;
		end
		CastingBarFrame:ClearAllPoints();
		CastingBarFrame:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, castingBarPosition);
	end
 end
end

-- this is no longer being used
--[[
function Titan_ContainerFrames_UpdatePosition()
	if not InCombatLockdown() then
		local panelYOffset = TitanMovable_GetPanelYOffset(TITAN_PANEL_PLACE_BOTTOM, TitanPanelGetVar("BothBars"));
		
		-- Update Bags
		if ( MultiBarBottomRight:IsVisible() or MultiBarBottomLeft:IsVisible() ) then
			ContainerFrame1:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 102 + panelYOffset);
		else
			ContainerFrame1:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 60 + panelYOffset);
		end
	end
 end
end
]]--

-- this is no longer being used
--[[
function Titan_UIParent_ManageRightSideFrames()
	if not InCombatLockdown() then
		local panelYOffset = TitanMovable_GetPanelYOffset(TITAN_PANEL_PLACE_BOTTOM, TitanPanelGetVar("BothBars"));
		
		local anchorX = 0;
		local anchorY = 0 + panelYOffset;

		-- Update group loot frame anchor
		if ( MultiBarBottomRight:IsVisible() or MultiBarBottomLeft:IsVisible() ) then
			GroupLootFrame1:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 102 + panelYOffset);
		else
			GroupLootFrame1:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 60 + panelYOffset);
		end
		
		-- Update tutorial anchor
		if ( MultiBarBottomRight:IsVisible() or MultiBarBottomLeft:IsVisible() ) then
			TutorialFrameParent:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 94 + panelYOffset);
			FramerateLabel:SetPoint("BOTTOM", "WorldFrame", "BOTTOM", 0, 104 + panelYOffset);
		else
			TutorialFrameParent:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 52 + panelYOffset);
			FramerateLabel:SetPoint("BOTTOM", "WorldFrame", "BOTTOM", 0, 64 + panelYOffset);
		end
		
		-- Update bag anchor
		if ( MultiBarBottomRight:IsVisible() ) then
			CONTAINER_OFFSET_Y = 97 + panelYOffset;
		else
			CONTAINER_OFFSET_Y = 70 + panelYOffset;
		end
		-- Setup x anchor
		if ( MultiBarLeft:IsVisible() ) then
			CONTAINER_OFFSET_X = 90;
			anchorX = 90;
		elseif ( MultiBarRight:IsVisible() ) then
			CONTAINER_OFFSET_X = 45;
			anchorX = 45;
		else
			CONTAINER_OFFSET_X = 0;
			anchorX = 0;
		end
		-- Setup y anchors
		QuestTimerFrame:SetPoint("TOPRIGHT", "MinimapCluster", "BOTTOMRIGHT", -anchorX, anchorY);
		if ( QuestTimerFrame:IsVisible() ) then
			anchorY = anchorY - QuestTimerFrame:GetHeight();
		end
		DurabilityFrame:SetPoint("TOPRIGHT", "MinimapCluster", "BOTTOMRIGHT", -anchorX-20, anchorY);
		if ( DurabilityFrame:IsVisible() ) then
			anchorY = anchorY - DurabilityFrame:GetHeight();
		end
		QuestWatchFrame:SetPoint("TOPRIGHT", "MinimapCluster", "BOTTOMRIGHT", -anchorX, anchorY);
		
		-- Update combat log anchor
		--FCF_UpdateCombatLogPosition();
	end
end
]]--

function Titan_ContainerFrames_Relocate()
	--if not InCombatLockdown() then
		local panelYOffset = TitanMovable_GetPanelYOffset(TITAN_PANEL_PLACE_BOTTOM, TitanPanelGetVar("BothBars"), 1);
		
		-- Update bag anchor
		if MultiBarBottomRight:IsShown() then
			CONTAINER_OFFSET_Y = 100 + panelYOffset;
			--97
		else
			CONTAINER_OFFSET_Y = 70 + panelYOffset;
			--70
		end
		-- account for Reputation Status Bar (doh)
		local playerlevel = UnitLevel("player");
		if ReputationWatchStatusBar:IsVisible() and playerlevel < MAX_PLAYER_LEVEL then
		  CONTAINER_OFFSET_Y = CONTAINER_OFFSET_Y + 8;
		end
		
		if (MultiBarLeft:IsShown()) then
			CONTAINER_OFFSET_X = 93;
		elseif ( MultiBarRight:IsShown() ) then
			CONTAINER_OFFSET_X = 48;
			--45
		else
			CONTAINER_OFFSET_X = 0;
		end
	--end
end

function Titan_ManageFramesNew()
-- Move frames		   
 	Titan_CastingBarFrame_UpdatePosition();
 
		   if (TitanPanelGetVar("BothBars") and not TitanPanelGetVar("AuxScreenAdjust")) or (TitanPanelGetVar("Position") == 2 and not TitanPanelGetVar("ScreenAdjust")) then
		   TitanMovableFrame_CheckFrames(TITAN_PANEL_PLACE_BOTTOM);
			 TitanMovableFrame_MoveFrames(TITAN_PANEL_PLACE_BOTTOM, TitanPanelGetVar("AuxScreenAdjust"));
			 Titan_ContainerFrames_Relocate();
			 end
end