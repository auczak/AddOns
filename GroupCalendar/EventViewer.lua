GroupCalendar._EventViewer = {}

GroupCalendar._EventViewer.Widgets =
{
	EventFrame =
	{
		"Title",
		"DateTime",
		"Levels",
		"Desc",
		"CharacterMenu",
		RoleMenu = {"Title"},
		"Yes",
		"No",
		"Maybe",
		"Comment",
		"Status",
		"Background"
	},
	EditFrame =
	{
		"TypeMenu",
		"Title",
		"SubTitle",
		"Background",
		"Time",
		"DurationMenu",
		"MinLevel",
		"MaxLevel",
		DescriptionFrame =
		{
			ScrollFrame =
			{
				"Limit",
				ScrollChildFrame = {"Description"},
			},
		},
		GuildOnly = {"Text"},
	},
	"AttendanceFrame",
	"AttendanceFrameList",
	"DeleteButton",
	"Parchment",
	"Tab1",
	"Tab2",
	"Tab3",
}

StaticPopupDialogs.CONFIRM_CALENDAR_EVENT_DELETE =
{
	text = TEXT(CalendarEvent_cConfirmDeleteMsg),
	button1 = TEXT(CalendarEvent_cDelete),
	button2 = TEXT(CANCEL),
	OnAccept = function() GroupCalendar.EventViewer:DeleteEvent() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}

StaticPopupDialogs.CONFIRM_CALENDAR_RSVP_DELETE =
{
	text = TEXT(GroupCalendar_cConfirmDeleteRSVP),
	button1 = TEXT(CalendarEvent_cDelete),
	button2 = TEXT(CANCEL),
	OnAccept = function() GroupCalendar.EventViewer:DeleteRSVP() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}

GroupCalendar.cStatusCodeStrings =
{
	N = CalendarEvent_cNotAttending,
	Y = CalendarEvent_cConfirmed,
	D = CalendarEvent_cDeclined,
	S = CalendarEvent_cStandby,
	P = CalendarEvent_cPending,
	M = CalendarEvent_cMaybe,
	["-"] = CalendarEvent_cBanned,
}

function GroupCalendar._EventViewer:Construct()
	self.ShowScheduleEditor = false
	self.Active = false

	self.Database = nil
	self.Event = nil
	self.SelectedPlayerDatabase = nil
	
	self.EventPanelIndex = 1
	self.EditPanelIndex = 2
	self.AttendancePanelIndex = 3
	
	self.Widgets.EditFrame.Description = self.Widgets.EditFrame.DescriptionFrame.ScrollFrame.ScrollChildFrame.Description
	
	self.PanelFrames =
	{
		self.Widgets.EventFrame,
		self.Widgets.EditFrame,
		self.Widgets.AttendanceFrame,
	}
	
	self.CurrentPanel = 0
	
	-- Tabs
	
	PanelTemplates_SetNumTabs(self, #self.PanelFrames)
	PanelTemplates_UpdateTabs(self)
	
	self.Widgets.EventFrame.CharacterMenu.ChangedValueFunc = function (...) self:SelectedCharacterChanged(...) end
	self.Widgets.EventFrame.RoleMenu.Title:Hide()
end

function GroupCalendar._EventViewer:ViewEvent(pDatabase, pEvent, pEditable, pIsNewEvent)
	self.Database = pDatabase
	self.Event = pEvent
	self.Editable = pEditable
	self.IsNewEvent = pIsNewEvent
	
	self.UsingLocalTime = gGroupCalendar_Settings.ShowEventsInLocalTime
	self.EventDateIsLocal = self.UsingLocalTime
	
	self.SelectedPlayerDatabase = GroupCalendar.UserDatabase
	
	self.Widgets.AttendanceFrameList.NewClassLimits = nil
	self.Widgets.AttendanceFrameList:SetEvent(pDatabase, pEvent)
	self.Widgets.AttendanceFrameList:SetCanEdit(pEditable)
	
	if pIsNewEvent then
		-- New events have their date in whatever time zone is
		-- selected for display
		
		self.EventDate = pEvent.mDate
		self.EventTime = pEvent.mTime
	else
		-- Existing events have their date in server time so
		-- convert to a local date if necessary
		
		if self.EventDateIsLocal then
			self.EventDate, self.EventTime = MCDateLib:GetLocalDateTimeFromServerDateTime(pEvent.mDate, pEvent.mTime)
		else
			self.EventDate = pEvent.mDate
			self.EventTime = pEvent.mTime
		end
	end
	
	self.Widgets.EditFrame.SubTitle:SetText(GroupCalendar.GetLongDateString(self.EventDate))
	
	self:UpdateEditPanelFromEvent(self.Event)
	self:UpdateEventPanelFromEvent(self.Event)
	self:UpdateAttendancePanelFromEvent(self.Event)
	
	ShowUIPanel(self)
	
	self.ShowScheduleEditor = false
	self.Active = true
end

function GroupCalendar._EventViewer:DoneViewing()
	if not self.Active then
		return
	end
	
	if self.Editable then
		self:SaveEvent()
	end
	
	self:SaveAttendance()
	
	self:Close(true)
end

function GroupCalendar._EventViewer:SetEnabledTabs(pEnableEdit, pEnableAttendance)
	local vTabIndex = self.EventPanelIndex + 1
	
	if pEnableEdit then
		local vTab = self.Widgets["Tab"..vTabIndex]
		
		self.EditPanelIndex = vTabIndex
		self.PanelFrames[vTabIndex] = self.Widgets.EditFrame
		vTab:SetText(GroupCalendar_cEdit)
		vTab:Show()
		
		vTabIndex = vTabIndex + 1
	else
		self.EditPanelIndex = nil
		self.Widgets.EditFrame:Hide()
	end
	
	if pEnableAttendance then
		local vTab = self.Widgets["Tab"..vTabIndex]
		
		self.AttendancePanelIndex = vTabIndex
		self.PanelFrames[vTabIndex] = self.Widgets.AttendanceFrame
		vTab:SetText(GroupCalendar_cAttendance)
		vTab:Show()
		
		vTabIndex = vTabIndex + 1
	else
		self.AttendancePanelIndex = nil
		self.Widgets.AttendanceFrame:Hide()
	end
	
	for vIndex = vTabIndex, 3 do
		self.Widgets["Tab"..vIndex]:Hide()
		self.PanelFrames[vTabIndex] = nil
	end

	PanelTemplates_SetNumTabs(self, #self.PanelFrames)
	PanelTemplates_UpdateTabs(self)
end

function GroupCalendar._EventViewer:ScheduleChanged(pDate)
	if self.Active and self.Event.mDate == pDate then
		self.Widgets.AttendanceFrameList:EventChanged(self.Database, self.Event)
		self:UpdateEventPanelFromEvent(self.Event, true)
		self:UpdateAttendancePanelFromEvent(self.Event)
		self:UpdateEventPanelFromEvent(self.Event)
	end
end

function GroupCalendar._EventViewer:MajorDatabaseChange()
	if not self.Active then return end
	
	self:EventChanged(self.Event) -- Force the attendance to update, can come from multiple sources so just always update
	
	if self.UsingLocalTime ~= gGroupCalendar_Settings.ShowEventsInLocalTime then
		self.UsingLocalTime = gGroupCalendar_Settings.ShowEventsInLocalTime
		
		self.EventTime = self:GetTimeControlValue(self.Widgets.EditFrame.Time)
		
		if self.UsingLocalTime then
			self.EventDate, self.EventTime = MCDateLib:GetLocalDateTimeFromServerDateTime(self.EventDate, self.EventTime)
		else
			self.EventDate, self.EventTime = MCDateLib:GetServerDateTimeFromLocalDateTime(self.EventDate, self.EventTime)
		end
		
		self:SetTimeControlValue(self.Widgets.EditFrame.Time, self.EventTime)
		if gGroupCalendar_Settings.ShowEventsInLocalTime then
			self.Widgets.EditFrame.TimeZone:SetText("local")
		else
			self.Widgets.EditFrame.TimeZone:SetText("server")
		end
	end
end

function GroupCalendar._EventViewer:EventChanged(pEvent)
	if pEvent ~= self.Event then
		return
	end
	
	self.Widgets.AttendanceFrameList:EventChanged(self.Database, self.Event)
	
	self:UpdateEventPanelFromEvent(self.Event, true)
	self:UpdateAttendancePanelFromEvent(self.Event)
end

function GroupCalendar._EventViewer:SaveAttendance()
	-- Save attendance feedback
	
	if GroupCalendar.Database.EventTypeUsesAttendance(self.Event.mType)
	and GroupCalendar.Database.PlayerIsQualifiedForEvent(self.Event, self.SelectedPlayerDatabase.PlayerLevel) then
		local vPendingRSVP = GroupCalendar.Database.FindLastRSVPRequestData(self.SelectedPlayerDatabase, self.Database.UserName, self.Event.mID)
		local vEventRSVP = GroupCalendar.Database.FindEventRSVP(self.Database.UserName, self.Event, self.SelectedPlayerDatabase.UserName)
		local vChanged = false
		local vStatus
		local vComment
		
		if vEventRSVP and vEventRSVP.mStatus == "-" then
			return -- Don't do anything for a banned player
		end
		
		if not vPendingRSVP then
			if vEventRSVP then
				vStatus = vEventRSVP.mStatus
				vComment = vEventRSVP.mComment
				vRole = vEventRSVP.mRole
			else
				vStatus = nil
				vComment = ""
			end
		else
			vStatus = vPendingRSVP.mStatus
			vComment = vPendingRSVP.mComment
			vRole = vPendingRSVP.mRole
		end
		
		if not vComment then
			vComment = ""
		end
		
		if not vRole then
			vRole = "?"
		end
		
		-- Update the status
		
		local vNewStatus = self:GetStatusFromControls()
		
		if not vNewStatus and (vPendingRSVP or vEventRSVP) then
			vNewStatus = "C" -- Cancel the existing request
		end
		
		if vNewStatus ~= vStatus then
			vStatus = vNewStatus
			vChanged = true
		end
		
		-- Update the role
		
		if vNewStatus then
			local vNewRole = UIDropDownMenu_GetSelectedValue(self.Widgets.EventFrame.RoleMenu)
			
			if vRole ~= vNewRole then
				vRole = vNewRole
				vChanged = true
			end
		end
		
		-- Update the comment
		
		if vNewStatus then
			local vNewComment = GroupCalendar.EscapeString(self.Widgets.EventFrame.Comment:GetText())
			
			if vComment ~= vNewComment then
				vComment = vNewComment
				vChanged = true
			end
		end
		
		-- Add a new RSVP if it's changed
		
		if vChanged then
			local vRSVP = GroupCalendar.Database.CreatePlayerRSVP(
									self.Database,
									self.Event,
									self.SelectedPlayerDatabase.UserName,
									self.SelectedPlayerDatabase.PlayerRaceCode,
									self.SelectedPlayerDatabase.PlayerClassCode,
									self.SelectedPlayerDatabase.PlayerLevel,
									vRole,
									vStatus,
									vComment,
									GroupCalendar.PlayerGuild,
									GroupCalendar.PlayerGuildRank,
									GroupCalendar.PlayerCharacters)
			
			GroupCalendar.Database.AddRSVP(self.SelectedPlayerDatabase, vRSVP)
			
			-- Update the UI
			
			self.Widgets.AttendanceFrameList:EventChanged(self.Database, self.Event)

			self:UpdateEventPanelFromEvent(self.Event)
			self:UpdateEditPanelFromEvent(self.Event)
			self:UpdateAttendancePanelFromEvent(self.Event)
			
			-- Note the change in the chat window
			-- TODO: Turning this off for now, I don't think it'll be necessary with the
			-- new network code in GC4
						
			-- GroupCalendar:NoteMessage(GroupCalendar_cAttendanceNote, GroupCalendar.Database.GetEventDisplayName(self.Event))
		end
		
		-- Save the preferred role
		
		if vRole ~= "?" then
			self.SelectedPlayerDatabase.DefaultRole = vRole
		end
	end
end

function GroupCalendar._EventViewer:GetStatusFromControls()
	if self.Widgets.EventFrame.Yes:GetChecked() then
		return "Y"
	elseif self.Widgets.EventFrame.No:GetChecked() then
		return "N"
	elseif self.Widgets.EventFrame.Maybe:GetChecked() then
		return "S"
	end
end

function GroupCalendar._EventViewer:Close(pShowScheduleEditor)
	self.Active = false
	
	self.ShowScheduleEditor = pShowScheduleEditor
	HideUIPanel(self)
end

function GroupCalendar._EventViewer:CopyTemplateFields(pFromEvent, rToEvent)
	rToEvent.mType = pFromEvent.mType
	rToEvent.mTitle = pFromEvent.mTitle
	rToEvent.mDescription = pFromEvent.mDescription
	rToEvent.mTime = pFromEvent.mTime
	rToEvent.mDuration = pFromEvent.mDuration
	rToEvent.mMinLevel = pFromEvent.mMinLevel
	rToEvent.mMaxLevel = pFromEvent.mMaxLevel
	
	rToEvent.mManualConfirm = pFromEvent.mManualConfirm
	rToEvent.mRoleConfirm = pFromEvent.mRoleConfirm
	rToEvent.mClosed = pFromEvent.mClosed
	rToEvent.mLimits = GroupCalendar.DuplicateTable(pFromEvent.mLimits)
	rToEvent.mGuild = pFromEvent.mGuild
end

function GroupCalendar._EventViewer:OnShow()
	PlaySound("igCharacterInfoOpen")
	
	self.Widgets.EditFrame.TypeMenu.ChangedValueFunc = function () self:EventTypeChanged(self.Widgets.EditFrame.TypeMenu, UIDropDownMenu_GetSelectedValue(self.Widgets.EditFrame.TypeMenu)) end
	self.Widgets.AttendanceFrameList.Widgets.MainView.AutoConfirm.Menu.ChangedValueFunc = function (...) self:SetAutoConfirmMode(...) end
	
	-- Determine which panel should be shown initially
	
	local vPanelIndex
	
	if not self.Editable then
		-- Always show the Event panel for non-editable events
		
		vPanelIndex = self.EventPanelIndex
	else
		-- Show the Attendance panel for existing events which use attendance
		
		if not self.IsNewEvent and self.AttendancePanelIndex then
			vPanelIndex = self.AttendancePanelIndex
		
		-- Otherwise show the Edit panel
		
		else
			vPanelIndex = self.EditPanelIndex
		end
	end
	
	self:ShowPanel(vPanelIndex)
end

function GroupCalendar._EventViewer:OnHide()
	PlaySound("igCharacterInfoClose")
	
	CalendarAddPlayer_Cancel() -- Force the dialog to close if it's open
	
	if not self.ShowScheduleEditor then -- If they close the window using the close box, save the settings
		self:SaveEvent()
		self:SaveAttendance()
		HideUIPanel(CalendarEditorFrame)
	end
	
	self.Database = nil
	self.Event = nil
	self.Editable = nil
	self.NewEvent = nil
	
	if self.CurrentPanel > 0 then
		self.PanelFrames[self.CurrentPanel]:Hide()
		self.CurrentPanel = 0
	end
	
	self.Active = false
end

function GroupCalendar._EventViewer:SelectedCharacterChanged(pMenuFrame, pValue)
	self.SelectedPlayerDatabase = GroupCalendar.Database.GetDatabase(pValue, false)
	
	self:UpdateEventPanelFromEvent(self.Event)
	self:UpdateEditPanelFromEvent(self.Event)
	self:UpdateAttendancePanelFromEvent(self.Event)
end

function GroupCalendar._EventViewer:UpdateControlsFromEvent(pEvent, pSkipAttendanceFields)
	self:UpdateEventPanelFromEvent(pEvent, pSkipAttendanceFields)
	self:UpdateEditPanelFromEvent(pEvent, pSkipAttendanceFields)
	self:UpdateAttendancePanelFromEvent(pEvent, pSkipAttendanceFields)
end

function GroupCalendar._EventViewer:UpdateEventPanelFromEvent(pEvent, pSkipAttendanceFields)
	-- Update the title
	
	self.Widgets.EventFrame.Title:SetText(GroupCalendar.Database.GetEventDisplayName(pEvent))
	
	-- Update the date and time
	
	local vDateTimeString
	
	if pEvent.mTime ~= nil then
		local vTime
		local vDate = pEvent.mDate
		
		if gGroupCalendar_Settings.ShowEventsInLocalTime then
			vDate, vTime = MCDateLib:GetLocalDateTimeFromServerDateTime(pEvent.mDate, pEvent.mTime)
		else
			vTime = pEvent.mTime
		end
		
		local vDateString = GroupCalendar.GetLongDateString(vDate)
		
		if pEvent.mDuration ~= nil
		and pEvent.mDuration ~= 0 then
			local vEndTime = math.fmod(vTime + pEvent.mDuration, 1440)
			
			vDateTimeString = string.format(
								GroupCalendar_cTimeDateRangeFormat,
								vDateString,
								GroupCalendar.GetShortTimeString(vTime),
								GroupCalendar.GetShortTimeString(vEndTime))
		else
			vDateTimeString = string.format(
								GroupCalendar_cSingleTimeDateFormat,
								vDateString,
								GroupCalendar.GetShortTimeString(vTime))
		end
	else
		vDateTimeString = GroupCalendar.GetLongDateString(pEvent.mDate)
	end
	
	self.Widgets.EventFrame.DateTime:SetText(vDateTimeString)
	
	-- Update the level range
	
	if GroupCalendar.Database.EventTypeUsesLevelLimits(pEvent.mType) then
		if pEvent.mMinLevel ~= nil then
			if pEvent.mMaxLevel ~= nil then
				if pEvent.mMinLevel == pEvent.mMaxLevel then
					self.Widgets.EventFrame.Levels:SetText(string.format(CalendarEventViewer_cSingleLevel, pEvent.mMinLevel))
				else
					self.Widgets.EventFrame.Levels:SetText(string.format(CalendarEventViewer_cLevelRangeFormat, pEvent.mMinLevel, pEvent.mMaxLevel))
				end
			else
				if pEvent.mMinLevel == 70 then
					self.Widgets.EventFrame.Levels:SetText(string.format(CalendarEventViewer_cSingleLevel, pEvent.mMinLevel))
				else
					self.Widgets.EventFrame.Levels:SetText(string.format(CalendarEventViewer_cMinLevelFormat, pEvent.mMinLevel))
				end
			end
			
			self.Widgets.EventFrame.Levels:Show()
		else
			if pEvent.mMaxLevel ~= nil then
				self.Widgets.EventFrame.Levels:SetText(string.format(CalendarEventViewer_cMaxLevelFormat, pEvent.mMaxLevel))
			else
				self.Widgets.EventFrame.Levels:SetText(CalendarEventViewer_cAllLevels)
			end
			
			self.Widgets.EventFrame.Levels:Show()
		end
		
		if GroupCalendar.Database.PlayerIsQualifiedForEvent(self.Event, self.SelectedPlayerDatabase.PlayerLevel) then
			self.Widgets.EventFrame.Levels:SetTextColor(1.0, 0.82, 0)
		else
			self.Widgets.EventFrame.Levels:SetTextColor(1.0, 0.2, 0.2)
		end
	else
		self.Widgets.EventFrame.Levels:Hide()
	end
	
	-- Update the description
	
	if pEvent.mDescription then
		self.Widgets.EventFrame.Desc:SetText(GroupCalendar.UnescapeString(pEvent.mDescription))
		self.Widgets.EventFrame.Desc:Show()
	else
		self.Widgets.EventFrame.Desc:Hide()
	end

	if not pSkipAttendanceFields then
		self.Widgets.EventFrame.CharacterMenu:SetSelectedValue(self.SelectedPlayerDatabase.UserName)
	end

	if pEvent.mType ~= nil then
		self.Widgets.EventFrame.Background:SetTexture(GroupCalendar.GetEventTypeIconPath(pEvent.mType))
		
		if pEvent.mType == "Birth" then
			self.Widgets.EventFrame.Background:SetVertexColor(1, 1, 1, 0.8)
		else
			self.Widgets.EventFrame.Background:SetVertexColor(1, 1, 1, 0.19)
		end
	else
		self.Widgets.EventFrame.Background:SetTexture("")
	end
	
	--
	
	if GroupCalendar.Database.EventTypeUsesAttendance(pEvent.mType) then
		local vIsAttending = false
		local vIsStandby = false
		local vIsMaybe = false
		local vIsNotAttending = false
		local vAttendanceComment = ""
		local vRole = GroupCalendar.GetMemberDefaultRole(self.SelectedPlayerDatabase.UserName)
		
		self:SetAttendanceVisible(true)
		self:SetAttendanceEnabled(GroupCalendar.Database.PlayerIsQualifiedForEvent(self.Event, self.SelectedPlayerDatabase.PlayerLevel))
		
		if GroupCalendar.Database.PlayerIsQualifiedForEvent(self.Event, self.SelectedPlayerDatabase.PlayerLevel) then
			local vPendingRSVP = GroupCalendar.Database.FindLastRSVPRequestData(self.SelectedPlayerDatabase, self.Database.UserName, self.Event.mID)
			local vEventRSVP = GroupCalendar.Database.FindEventRSVP(self.Database.UserName, self.Event, self.SelectedPlayerDatabase.UserName)
			local vRSVP
			
			if (vEventRSVP and vEventRSVP.mStatus == "-")
			or not vPendingRSVP then
				vRSVP = vEventRSVP
			else
				vRSVP = vPendingRSVP
			end
			
			if vRSVP then
				vIsAttending = vRSVP.mStatus == "Y"
				vIsNotAttending = vRSVP.mStatus == "N"
				vIsStandby = vRSVP.mStatus == "S"
				vIsMaybe = vRSVP.mStatus == "M"
				
				if vRSVP.mComment then
					vAttendanceComment = GroupCalendar.UnescapeString(vRSVP.mComment)
				end
				
				if vRSVP.mRole and vRSVP.mRole ~= "?" then
					vRole = vRSVP.mRole
				end
			end
			
			self:SetResponseStatus(vPendingRSVP, vEventRSVP)
			
			if vEventRSVP and vEventRSVP.mStatus == "-" then
				self.Widgets.EventFrame.Yes:Hide()
				self.Widgets.EventFrame.No:Hide()
				self.Widgets.EventFrame.Maybe:Hide()
				self.Widgets.EventFrame.Comment:Hide()
				self.Widgets.EventFrame.CharacterMenu:Hide()
				self.Widgets.EventFrame.RoleMenu:Hide()
			else
				self.Widgets.EventFrame.Yes:Show()
				self.Widgets.EventFrame.No:Show()
				self.Widgets.EventFrame.Maybe:Show()
				self.Widgets.EventFrame.Comment:Show()
				self.Widgets.EventFrame.CharacterMenu:Show()
				self.Widgets.EventFrame.RoleMenu:Show()
				
				if pEvent.mLimits then
					self.Widgets.EventFrame.RoleMenu.RoleLimits = pEvent.mLimits.mRoleLimits
				else
					self.Widgets.EventFrame.RoleMenu.RoleLimits = nil
				end
			end
			
			--
			
			if pSkipAttendanceFields then
				local vNewStatus = self:GetStatusFromControls()
				
				if self.PreviousStatus == vNewStatus then
					self.Widgets.EventFrame.Yes:SetChecked(vIsAttending or vIsStandby)
					self.Widgets.EventFrame.No:SetChecked(vIsNotAttending)
					self.Widgets.EventFrame.Maybe:SetChecked(vIsMaybe)
					self.Widgets.EventFrame.RoleMenu:SetSelectedValue(vRole)
				end
			else
				self.Widgets.EventFrame.Yes:SetChecked(vIsAttending or vIsStandby)
				self.Widgets.EventFrame.No:SetChecked(vIsNotAttending)
				self.Widgets.EventFrame.Maybe:SetChecked(vIsMaybe)
				self.Widgets.EventFrame.RoleMenu:SetSelectedValue(vRole)
				
				self.Widgets.EventFrame.Comment:SetText(vAttendanceComment)
				self:UpdateCommentEnable()
			end
			
			if vRSVP then
				self.PreviousStatus = vRSVP.mStatus
			else
				self.PreviousStatus = nil
			end
		end
	else
		self:SetAttendanceVisible(false)
	end
end
	
function GroupCalendar._EventViewer:UpdateEditPanelFromEvent(pEvent, pExistingValuesOnly)
	if not pExistingValuesOnly
	or pEvent.mType then
		self.Widgets.EditFrame.TypeMenu:SetSelectedValue(pEvent.mType or "NONE")
	end
	
	if pEvent.mTitle and pEvent.mTitle ~= "" then
		self.Widgets.EditFrame.Title:SetText(GroupCalendar.UnescapeString(pEvent.mTitle))
	elseif not pExistingValuesOnly
	or pEvent.mType then
		local vEventName = GroupCalendar.Database.GetEventNameByID(pEvent.mType)
		
		if vEventName ~= nil then
			self.Widgets.EditFrame.Title:SetText(vEventName)
		else
			self.Widgets.EditFrame.Title:SetText("")
		end
	end
	
	if not pExistingValuesOnly
	or self.EventTime then
		self:SetTimeControlValue(self.Widgets.EditFrame.Time, self.EventTime)
	end
	
	if not pExistingValuesOnly
	or pEvent.mDuration then
		self.Widgets.EditFrame.DurationMenu:SetSelectedValue(pEvent.mDuration)
	end
	
	if pEvent.mDescription then
		self.Widgets.EditFrame.Description:SetText(GroupCalendar.UnescapeString(pEvent.mDescription))
	elseif not pExistingValuesOnly then
		self.Widgets.EditFrame.Description:SetText("")
	end
	
	if pEvent.mMinLevel then
		self.Widgets.EditFrame.MinLevel:SetText(pEvent.mMinLevel)
	elseif not pExistingValuesOnly then
		self.Widgets.EditFrame.MinLevel:SetText("")
	end

	if pEvent.mMaxLevel then
		self.Widgets.EditFrame.MaxLevel:SetText(pEvent.mMaxLevel)
	elseif not pExistingValuesOnly then
		self.Widgets.EditFrame.MaxLevel:SetText("")
	end
	
	if not pExistingValuesOnly
	or pEvent.mType then
		self.PreviousEventType = pEvent.mType
		self:SetEventType(pEvent.mType)
	end
	
	if self.Database.Guild
	and not GroupCalendar.Database.IsPrivateEventType(pEvent.mType) then
		self.Widgets.EditFrame.GuildOnly:SetChecked(pEvent.mGuild == self.Database.Guild)
		self.Widgets.EditFrame.GuildOnly:Show()
	else
		self.Widgets.EditFrame.GuildOnly:Hide()
	end
	
	if pEvent.mType ~= nil then
		self.Widgets.EditFrame.Background:SetTexture(GroupCalendar.GetEventTypeIconPath(pEvent.mType))
		if pEvent.mType == "Birth" then
			self.Widgets.EditFrame.Background:SetVertexColor(1, 1, 1, 0.8)
		else
			self.Widgets.EditFrame.Background:SetVertexColor(1, 1, 1, 0.19)
		end
	else
		self.Widgets.EditFrame.Background:SetTexture("")
	end
end

function GroupCalendar._EventViewer:UpdateAttendancePanelFromEvent(pEvent, pSkipAttendanceFields)
	-- Control logic for determining the actual confirmation type.  This logic is kind
	-- of complex due to having to work backwards from the actual stored values.
	
	-- TODO: Rework event confirmation mode to a single field.  Leave the existing booleans
	-- so that downgrading doesn't affect existing events, though new events will not have
	-- those and downgrading will cause existing events to show the default Automatic mode
	
	if pEvent.mManualConfirm then
		self.Widgets.AttendanceFrameList.Widgets.MainView.AutoConfirm.Menu:SetSelectedValue("MAN")
	elseif pEvent.mClosed then
		self.Widgets.AttendanceFrameList.Widgets.MainView.AutoConfirm.Menu:SetSelectedValue("CLOSED")
	elseif pEvent.mRoleConfirm then
		self.Widgets.AttendanceFrameList.Widgets.MainView.AutoConfirm.Menu:SetSelectedValue("ROLE")
	else
		self.Widgets.AttendanceFrameList.Widgets.MainView.AutoConfirm.Menu:SetSelectedValue("AUT")
	end
end

function GroupCalendar._EventViewer:UpdateEventField(pFieldName, pValue, rEvent, rChangedFields)
	if rEvent[pFieldName] == pValue then
		return false
	end
	
	rEvent[pFieldName] = pValue
	rChangedFields[pFieldName] = {op = "UPD", val = pValue}
	return true
end

function GroupCalendar._EventViewer:UpdateEventNumberField(pFieldName, pValue, rEvent, rChangedFields)
	if pValue and pValue ~= "" then
		pValue = tonumber(pValue)
		
		if pValue == 0 then
			pValue = nil
		end
	else
		pValue = nil
	end
	
	return self:UpdateEventField(pFieldName, pValue, rEvent, rChangedFields)
end

function GroupCalendar._EventViewer:UpdateEventFromControls(rEvent, rChangedFields)
	local vChanged = false
	local vValue
	
	-- Type
	
	vChanged = self:UpdateEventField("mType", self:GetDropdownEventType(), rEvent, rChangedFields) or vChanged
	vChanged = self:UpdateEventField("mPrivate", GroupCalendar.Database.IsPrivateEventType(vValue), rEvent, rChangedFields) or vChanged
	
	-- Title
	
	vValue = self.Widgets.EditFrame.Title:GetText()
	
	if vValue == GroupCalendar.Database.GetEventNameByID(rEvent.mType)
	or vValue == "" then
		vValue = nil
	else
		vValue = GroupCalendar.EscapeString(vValue)
	end
	
	if vValue and string.len(vValue) > GroupCalendar_cMaxFieldLength then
		vValue = string.sub(vValue, 1, GroupCalendar_cMaxFieldLength)
	end
	
	vChanged = self:UpdateEventField("mTitle", vValue, rEvent, rChangedFields) or vChanged
	
	-- Time
	
	local vDate, vTime = nil, nil
	
	if GroupCalendar.Database.EventTypeUsesTime(rEvent.mType) then
		vDate, vTime = self.EventDate, self:GetTimeControlValue(self.Widgets.EditFrame.Time)
		
		if self.UsingLocalTime then
			vDate, vTime = MCDateLib:GetServerDateTimeFromLocalDateTime(vDate, vTime)
		end
	else
		vDate = self.EventDate
	end
	
	vChanged = self:UpdateEventField("mDate", vDate, rEvent, rChangedFields) or vChanged
	vChanged = self:UpdateEventField("mTime", vTime, rEvent, rChangedFields) or vChanged
	
	-- Duration
	
	if GroupCalendar.Database.EventTypeUsesTime(rEvent.mType) then
		vValue = UIDropDownMenu_GetSelectedValue(self.Widgets.EditFrame.DurationMenu)
	else
		vValue = nil
	end
	
	if vValue == 0 then
		vValue = nil
	end
	
	vChanged = self:UpdateEventField("mDuration", vValue, rEvent, rChangedFields) or vChanged
	
	-- Description
	
	vValue = self.Widgets.EditFrame.Description:GetText()
	
	if vValue == "" then
		vValue = nil
	else
		vValue = GroupCalendar.EscapeString(vValue)
	end
	
	if vValue and string.len(vValue) > GroupCalendar_cMaxFieldLength then
		vValue = string.sub(vValue, 1, GroupCalendar_cMaxFieldLength)
	end
	
	vChanged = self:UpdateEventField("mDescription", vValue, rEvent, rChangedFields) or vChanged
	
	-- MinLevel
	
	if GroupCalendar.Database.EventTypeUsesLevelLimits(rEvent.mType) then
		vValue = self.Widgets.EditFrame.MinLevel:GetText()
	else
		vValue = nil
	end
	
	vChanged = self:UpdateEventNumberField("mMinLevel", vValue, rEvent, rChangedFields) or vChanged
	
	-- MaxLevel
	
	if GroupCalendar.Database.EventTypeUsesTime(rEvent.mType) then
		vValue = self.Widgets.EditFrame.MaxLevel:GetText()
	else
		vValue = nil
	end
	
	vChanged = self:UpdateEventNumberField("mMaxLevel", vValue, rEvent, rChangedFields) or vChanged
	
	-- Automatic confirmations
	
	local vManualConfirm, vRoleConfirm, vClosedEvent
	
	if GroupCalendar.Database.IsQuestingEventType(rEvent.mType) then
		local vAutoConfirmValue = UIDropDownMenu_GetSelectedValue(self.Widgets.AttendanceFrameList.Widgets.MainView.AutoConfirm.Menu)
		
		if vAutoConfirmValue == "CLOSED" then
			vClosedEvent = true
		elseif vAutoConfirmValue == "MAN" then
			vManualConfirm = true
		elseif vAutoConfirmValue == "ROLE" then
			vRoleConfirm = true
		end
	else
		-- Non-questing events are always auto-confirm (ie meetings)
		
		vManualConfirm = nil
	end
	
	vChanged = self:UpdateEventField("mClosed", vClosedEvent, rEvent, rChangedFields) or vChanged
	vChanged = self:UpdateEventField("mManualConfirm", vManualConfirm, rEvent, rChangedFields) or vChanged
	vChanged = self:UpdateEventField("mRoleConfirm", vRoleConfirm, rEvent, rChangedFields) or vChanged
	
	local vGuild = nil
	
	if self.Widgets.EditFrame.GuildOnly:GetChecked() then
		vGuild = self.Database.Guild
	end
	
	vChanged = self:UpdateEventField("mGuild", vGuild, rEvent, rChangedFields) or vChanged
	
	if GroupCalendar.Database.IsQuestingEventType(rEvent.mType) then
		if self.Widgets.AttendanceFrameList.NewClassLimits
		and not GroupCalendar.LimitsAreEqual(rEvent.mLimits, self.Widgets.AttendanceFrameList.NewClassLimits) then
			vChanged = self:UpdateEventField("mLimits", self.Widgets.AttendanceFrameList.NewClassLimits, rEvent, rChangedFields) or vChanged
		end
	else
		-- No limits on non-questing event types (ie, meetings)
		
		vChanged = self:UpdateEventField("mLimits", nil, rEvent, rChangedFields) or vChanged
	end
	
	-- Done
	
	return vChanged
end

function GroupCalendar._EventViewer:SetEventType(pEventType)
	-- CalendarEventEditorEventTypeMenu:Show()
	-- CalendarEventTitle:Show()
	-- CalendarEventDescription:Show()
	
	CalendarDropDown_SetSelectedValue(self.Widgets.EditFrame.TypeMenu, pEventType or "NONE")
	
	local vTitleText = self.Widgets.EditFrame.Title:GetText()
	local vEventName = GroupCalendar.Database.GetEventNameByID(self.PreviousEventType)
	local vTitleWasEventName = vTitleText == vEventName or vTitleText == ""
	
	if GroupCalendar.Database.EventTypeUsesTime(pEventType) then
		self.Widgets.EditFrame.Time:Show()
		self.Widgets.EditFrame.DurationMenu:Show()
	else
		self.Widgets.EditFrame.Time:Hide()
		self.Widgets.EditFrame.DurationMenu:Hide()
	end
	
	if GroupCalendar.Database.EventTypeUsesLevelLimits(pEventType) then
		self.Widgets.EditFrame.MinLevel:Show()
		self.Widgets.EditFrame.MaxLevel:Show()
	else
		self.Widgets.EditFrame.MinLevel:Hide()
		self.Widgets.EditFrame.MaxLevel:Hide()
	end
	
	self:SetAttendanceVisible(GroupCalendar.Database.EventTypeUsesAttendance(pEventType))
	
	if vTitleWasEventName then
		self.Widgets.EditFrame.Title:SetText(GroupCalendar.Database.GetEventNameByID(pEventType) or "")
		self.Widgets.EditFrame.Title:SetFocus()
	end
	
	-- Update the sample icon
	
	self.Widgets.EditFrame.Background:SetTexture(GroupCalendar.GetEventTypeIconPath(pEventType))
	
	if pEventType == "Birth" then
		self.Widgets.EditFrame.Background:SetVertexColor(1, 1, 1, 0.4)
	else
		self.Widgets.EditFrame.Background:SetVertexColor(1, 1, 1, 0.19)
	end

	--
	
	self.PreviousEventType = pEventType
end

function GroupCalendar._EventViewer:DeleteEvent()
	if not self.IsNewEvent then
		GroupCalendar.Database.DeleteEvent(self.Database, self.Event)
	end
	
	self:Close(true)
end

function GroupCalendar._EventViewer:DeleteRSVP()
	if not self.RSVPToDelete then
		return
	end
	
	self.RSVPToDelete.mStatus = "C"
	
	GroupCalendar.Database.AddEventRSVP(
			self.Database,
			self.Event,
			self.RSVPToDelete.mName,
			self.RSVPToDelete)
	
	self.RSVPToDelete = nil
end

function GroupCalendar._EventViewer:UpdateCommentEnable()
	local vEnable = self.Widgets.EventFrame.Yes:GetChecked()
	               or self.Widgets.EventFrame.No:GetChecked()
	               or self.Widgets.EventFrame.Maybe:GetChecked()
	
	GroupCalendar.SetEditBoxEnable(self.Widgets.EventFrame.Comment, vEnable)
end

function GroupCalendar._EventViewer:SetAttendanceEnabled(pEnable)
	GroupCalendar.SetCheckButtonEnable(self.Widgets.EventFrame.Yes, pEnable)
	GroupCalendar.SetCheckButtonEnable(self.Widgets.EventFrame.No, pEnable)
	GroupCalendar.SetCheckButtonEnable(self.Widgets.EventFrame.Maybe, pEnable)
	GroupCalendar.SetEditBoxEnable(self.Widgets.EventFrame.Comment, pEnable)
	
	if pEnable then
		self.Widgets.EventFrame.Status:Show()
	else
		self.Widgets.EventFrame.Status:Hide()
	end
end

function GroupCalendar._EventViewer:SetAttendanceVisible(pVisible)
	if pVisible then
		self.Widgets.EventFrame.CharacterMenu:Show()
		self.Widgets.EventFrame.RoleMenu:Show()
		self.Widgets.EventFrame.Yes:Show()
		self.Widgets.EventFrame.No:Show()
		self.Widgets.EventFrame.Maybe:Show()
		self.Widgets.EventFrame.Comment:Show()
		self.Widgets.EventFrame.Status:Show()
		
		self.Widgets.EditFrame.GuildOnly:Show()
	else
		self.Widgets.EventFrame.CharacterMenu:Hide()
		self.Widgets.EventFrame.RoleMenu:Hide()
		self.Widgets.EventFrame.Yes:Hide()
		self.Widgets.EventFrame.No:Hide()
		self.Widgets.EventFrame.Maybe:Hide()
		self.Widgets.EventFrame.Comment:Hide()
		self.Widgets.EventFrame.Status:Hide()
		
		self.Widgets.EditFrame.GuildOnly:Hide()
	end
	
	self:SetEnabledTabs(self.Editable, pVisible)
end

function GroupCalendar._EventViewer:GetDropdownEventType()
	vValue = UIDropDownMenu_GetSelectedValue(self.Widgets.EditFrame.TypeMenu)
	
	if vValue == "NONE" then
		return
	end
	
	return vValue
end

function GroupCalendar._EventViewer:CalculateResponseStatus(pPendingRSVP, pEventRSVP)
	if (pEventRSVP and pEventRSVP.mStatus == "-") then
		return 6 -- Banned
	elseif pPendingRSVP then
		return 2 -- Pending
	elseif pEventRSVP then
		if pEventRSVP.mStatus == "Y" then
			return 3
		elseif pEventRSVP.mStatus == "S" then
			return 4
		elseif pEventRSVP.mStatus == "N" then
			return 5
		elseif pEventRSVP.mStatus == "M" then
			return 7
		end
	else
		return 1
	end
end

function GroupCalendar._EventViewer:SetResponseStatus(pPendingRSVP, pEventRSVP)
	local vStatus = self:CalculateResponseStatus(pPendingRSVP, pEventRSVP)
	
	self.Widgets.EventFrame.Status:SetText(CalendarEventViewer_cResponseMessage[vStatus])
end

function GroupCalendar._EventViewer:ShowPanel(pPanelIndex)
	if self.CurrentPanel > 0
	and self.CurrentPanel ~= pPanelIndex then
		self:HidePanel(self.CurrentPanel)
	end
	
	-- NOTE: Don't check for redundant calls since this function
	-- will be called to reset the field values as well as to 
	-- actuall show the panel when it's hidden
	
	self.CurrentPanel = pPanelIndex
	
	-- Update the control values
	
	if pPanelIndex == self.EventPanelIndex then
		-- Event panel

		self.Widgets.Parchment:Show()
		self.Widgets.DeleteButton:Hide()
		
		self:UpdateEventPanelFromEvent(self.Event, true) -- Update the event details in case they changed, but leave attendance selections alone
		
	elseif pPanelIndex == self.EditPanelIndex then
		-- Edit panel
		
		self.Widgets.Parchment:Hide()
		self.Widgets.DeleteButton:Show()
		
		if self.Database.Guild then
			self.Widgets.EditFrame.GuildOnly.Text:SetText(string.format(GroupCalendar_cGuildOnly, self.Database.Guild))
		end
		
	elseif pPanelIndex == self.AttendancePanelIndex then
		-- Attendance panel
		
		self.Widgets.Parchment:Hide()
		self.Widgets.DeleteButton:Hide()
		
		if GroupCalendar.Database.IsQuestingEventType(self.Event.mType) then
			self.Widgets.AttendanceFrameList:SetTotalsVisible(true, self.Editable)
		else
			self.Widgets.AttendanceFrameList:SetTotalsVisible(false, false)
		end
	else
		GroupCalendar:DebugMessage("EventViewer:ShowPanel: Unknown index (%s)", pPanelIndex or "nil")
	end
	
	GroupCalendar:DebugMessage("Showing panel %s", pPanelIndex or "nil")
	
	self.PanelFrames[pPanelIndex]:Show()
	
	PanelTemplates_SetTab(self, pPanelIndex)
	
	self:Update()
end

function GroupCalendar._EventViewer:HidePanel(pFrameIndex)
	if self.CurrentPanel ~= pFrameIndex
	or self.CurrentPanel == 0 then
		return
	end
	
	if self.CurrentPanel == self.EventPanelIndex then
		if not self.IsNewEvent then
			self:SaveAttendance()
		end
	elseif self.CurrentPanel == self.EditPanelIndex then
		if not self.IsNewEvent then
			self:SaveEvent()
		else
			local vChangedFields = {}
			
			self:UpdateEventFromControls(self.Event, vChangedFields)
		end
	end
	
	if not self.PanelFrames[pFrameIndex] then
		GroupCalendar:DebugMessage("HidePanel on nil panel at index %s", pFrameIndex or "nil")
	end
	
	self.PanelFrames[pFrameIndex]:Hide()
	self.CurrentPanel = 0
end

function GroupCalendar._EventViewer:Update()
	if self.CurrentPanel == self.EventPanelIndex then
		-- Event panel
		
	elseif self.CurrentPanel == self.EditPanelIndex then
		-- Edit panel
	
	elseif self.CurrentPanel == self.AttendancePanelIndex then
		-- Attendance panel
		
		self.Widgets.AttendanceFrameList:Update()
	end
end

function GroupCalendar._EventViewer:SaveEvent()
	-- Update the event
	
	local vChangedFields = {}
	
	self:UpdateEventFromControls(self.Event, vChangedFields)
	
	if not self.IsNewEvent
	and GroupCalendar.ArrayIsEmpty(vChangedFields) then
		return
	end
	
	-- Save the event if it's new
	
	if self.IsNewEvent then
		if (self.Event.mTitle ~= nil and self.Event.mTitle ~= "")
		or self.Event.mType ~= nil then
			GroupCalendar.Database.AddEvent(self.Database, self.Event)
		end
	else
		GroupCalendar.Database.EventChanged(self.Database, self.Event, vChangedFields)
	end
	
	-- Save a template for the event
	
	if self.Event.mType
	and self.Event.mType ~= "Birth" then
		local vEventTemplate = {}
		
		self:CopyTemplateFields(self.Event, vEventTemplate)
		
		-- TODO: Save selected character/role for self attend
		-- vEventTemplate.mSelfAttend = self:GetSelfAttend()
		
		GroupCalendar.SaveEventTemplate(vEventTemplate)
	end
end

function GroupCalendar._EventViewer:SetTimeControlValue(pFrame, pTime)
	if pTime == nil then
		return
	end
	
	local vFrameName = pFrame:GetName()
	
	local vHourFrame = getglobal(vFrameName.."Hour")
	local vMinuteFrame = getglobal(vFrameName.."Minute")
	local vAMPMFrame = getglobal(vFrameName.."AMPM")
	
	if TwentyFourHourTime then
		local vHour, vMinute = GroupCalendar.ConvertTimeToHM(pTime)
		
		CalendarDropDown_SetSelectedValue(vHourFrame, vHour)
		CalendarDropDown_SetSelectedValue(vMinuteFrame, vMinute)
		vAMPMFrame:Hide()
	else
		local vHour, vMinute, vAMPM = GroupCalendar.ConvertTimeToHMAMPM(pTime)
		
		CalendarDropDown_SetSelectedValue(vHourFrame, vHour)
		CalendarDropDown_SetSelectedValue(vMinuteFrame, vMinute)
		
		vAMPMFrame:Show()
		CalendarDropDown_SetSelectedValue(vAMPMFrame, vAMPM)
	end
end

function GroupCalendar._EventViewer:GetTimeControlValue(pFrame)
	local vFrameName = pFrame:GetName()
	
	local vHourFrame = getglobal(vFrameName.."Hour")
	local vMinuteFrame = getglobal(vFrameName.."Minute")
	local vAMPMFrame = getglobal(vFrameName.."AMPM")
	
	local vHour = UIDropDownMenu_GetSelectedValue(vHourFrame) or 0
	local vMinute = UIDropDownMenu_GetSelectedValue(vMinuteFrame) or 0
	
	if TwentyFourHourTime then
		return GroupCalendar.ConvertHMToTime(vHour, vMinute)
	else
		local vAMPM = UIDropDownMenu_GetSelectedValue(vAMPMFrame) or 0
		
		return GroupCalendar.ConvertHMAMPMToTime(vHour, vMinute, vAMPM)
	end
end

function GroupCalendar._EventViewer:LoadEventDefaults(pTemplate)
	-- Set the default limits for this dungeon (the template will
	-- override this if it's present)

	local vEventInfo = GroupCalendar.Database.GetEventInfoByID(self:GetDropdownEventType())
	
	if vEventInfo then
		if vEventInfo.limits then
			self.Event.mLimits = vEventInfo.limits
		end
		
		if vEventInfo.minLevel then	
			self.Event.mMinLevel = vEventInfo.minLevel
		end
	end
	
	-- Copy of template values
	
	local vTemplate = pTemplate
	
	if not vTemplate and vEventInfo then
		vTemplate = GroupCalendar.FindEventTemplateByTitle(vEventInfo.name)
	end
	
	if vTemplate then
		self:CopyTemplateFields(vTemplate, self.Event)
		
		-- Convert the date/time to local
		
		if vTemplate.mTime and self.EventDateIsLocal then
			_, self.Event.mTime = MCDateLib:GetLocalDateTimeFromServerDateTime(self.Event.mDate, self.Event.mTime)
		end
		
		self.EventTime = self.Event.mTime
		
		-- TODO: Restore self-attend memory
	end
	
	self:UpdateEventPanelFromEvent(self.Event, true)
	self:UpdateEditPanelFromEvent(self.Event, true)
	self:UpdateAttendancePanelFromEvent(self.Event)
end

function GroupCalendar._EventViewer:EventTypeChanged(pMenuFrame, pValue)
	self:SetEventType(pValue)
	
	-- Set the templated field values if available
	
	if self.IsNewEvent then
		self:LoadEventDefaults()
	end
end

function GroupCalendar._EventViewer:SetAutoConfirmMode(pMenuFrame, pValue)
	pMenuFrame.AttendanceViewer:SetAutoConfirmMode(pValue)
end

function GroupCalendar._EventViewer:AskDeleteEvent()
	-- If it's new just kill it without asking
	
	if self.IsNewEvent then
		self:DeleteEvent()
	else
		-- Update an event record so we can display a meaningful name
		
		local vChangedFields = {}
		local vEvent = {}
		
		self:UpdateEventFromControls(vEvent, vChangedFields)
		
		StaticPopupDialogs.CONFIRM_CALENDAR_EVENT_DELETE.OnAccept = function () self:DeleteEvent() end
		StaticPopup_Show("CONFIRM_CALENDAR_EVENT_DELETE", GroupCalendar.Database.GetEventDisplayName(vEvent))
	end
end

function GroupCalendar._EventViewer:AttendanceMenuItemSelected(pOwner, pValue)
	local vAttendanceItem = pOwner:GetParent()
	local vLineIndex = vAttendanceItem:GetID()
	local vAttendanceList = vAttendanceItem:GetParent()
	
	local vItem = vAttendanceList:GetIndexedItem(vLineIndex)
	
	if not vItem then
		GroupCalendar:ErrorMessage("Internal error: AttendanceMenuItemSelected couldn't get item for ID %s", vLineIndex or "nil")
		return
	end
	
	if pValue == "DELETE" then
		if vItem.mType == "Whisper" then
			GroupCalendar.WhisperLog:RemovePlayer(vItem.mName)
		else
			self.RSVPToDelete = vItem
			StaticPopup_Show("CONFIRM_CALENDAR_RSVP_DELETE", vItem.mName or "unknown")
		end
	elseif pValue == "ADD" then
		if vItem.mType == "Whisper" then
			CalendarAddPlayer_OpenWhisper(vItem.mName, vItem.mDate, vItem.mTime, vItem.mWhispers)
		end
	elseif pValue == "EDIT" then
		CalendarAddPlayer_EditRSVP(vItem)
	elseif pValue == "INVITE" then
		InviteByName(vItem.mName)
	else
		vItem.mStatus = pValue
		
		GroupCalendar.Database.AddEventRSVP(
				self.Database,
				self.Event,
				vItem.mName,
				vItem)
	end
end

function GroupCalendar._EventViewer:SaveClassLimits(pLimits)
	self.Widgets.AttendanceFrameList.NewClassLimits = pLimits
end

function GroupCalendar._EventViewer:UpdateDescriptionCounter(pText)
	local vCurLength = string.len(GroupCalendar.EscapeString(pText))
	
	self.Widgets.EditFrame.DescriptionFrame.ScrollFrame.Limit:SetText(vCurLength.."/"..GroupCalendar_cMaxFieldLength)

	-- Figure out the amount used in the description and color progress based on percentage
	
	local vPercentUsed = vCurLength / GroupCalendar_cMaxFieldLength
	
	if vPercentUsed <= 0.75 then
		self.Widgets.EditFrame.DescriptionFrame.ScrollFrame.Limit:SetVertexColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif vCurLength < GroupCalendar_cMaxFieldLength then
		self.Widgets.EditFrame.DescriptionFrame.ScrollFrame.Limit:SetVertexColor(0.9, 0.9, 0.05) -- Yellow
	else
		self.Widgets.EditFrame.DescriptionFrame.ScrollFrame.Limit:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	end
end

