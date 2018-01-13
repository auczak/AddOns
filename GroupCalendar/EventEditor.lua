GroupCalendar.EventEditor = {}

GroupCalendar.EventEditor.ShowScheduleEditor = false
GroupCalendar.EventEditor.Active = false

GroupCalendar.EventEditor.Database = nil
GroupCalendar.EventEditor.Event = nil
GroupCalendar.EventEditor.IsNewEvent = false

GroupCalendar.EventEditor.PreviousEventType = nil

GroupCalendar.EventEditor.EventPanelIndex = 1
GroupCalendar.EventEditor.AttendancePanelIndex = 2

GroupCalendar.EventEditor.CurrentPanel = GroupCalendar.EventEditor.EventPanelIndex
GroupCalendar.EventEditor.UsingLocalTime = false
GroupCalendar.EventEditor.EventDate = nil
GroupCalendar.EventEditor.EventTime = nil
GroupCalendar.EventEditor.EventDateIsLocal = false

GroupCalendar.cNumAttendanceItems = 12
GroupCalendar.cNumAutoConfirmAttendanceItems = 11
GroupCalendar.cNumPlainAttendanceItems = 16
GroupCalendar.cAttendanceItemHeight = 16

GroupCalendar.EventEditor.cPanelFrames =
{
	"CalendarEventEditorEventFrame",
	"CalendarEventEditorAttendanceFrame",
}

StaticPopupDialogs.CONFIRM_CALENDAR_EVENT_DELETE =
{
	text = TEXT(CalendarEventEditor_cConfirmDeleteMsg),
	button1 = TEXT(CalendarEventEditor_cDelete),
	button2 = TEXT(CANCEL),
	OnAccept = function() GroupCalendar.EventEditor:DeleteEvent() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}

StaticPopupDialogs.CONFIRM_CALENDAR_RSVP_DELETE =
{
	text = TEXT(GroupCalendar_cConfrimDeleteRSVP),
	button1 = TEXT(CalendarEventEditor_cDelete),
	button2 = TEXT(CANCEL),
	OnAccept = function() GroupCalendar.EventEditor:DeleteRSVP() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}

StaticPopupDialogs.CONFIRM_CALENDAR_CLEAR_WHISPERS =
{
	text = TEXT(GroupCalendar_cConfirmClearWhispers),
	button1 = TEXT(GroupCalendar_cClear),
	button2 = TEXT(CANCEL),
	OnAccept = function() GroupCalendar.WhisperLog:Clear() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}

function GroupCalendar.EventEditor:EditEvent(pDatabase, pEvent, pIsNewEvent)
	self.Database = pDatabase
	self.Event = pEvent
	self.IsNewEvent = pIsNewEvent
	self.UsingLocalTime = gGroupCalendar_Settings.ShowEventsInLocalTime
	CalendarEventEditorAttendance.NewClassLimits = nil
	
	CalendarEventEditorAttendance:SetEvent(pDatabase, pEvent)
	
	self.EventDateIsLocal = self.UsingLocalTime
	
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
	
	if not self.EventDate then
		GroupCalendar:DebugMessage("Date not found")
		GroupCalendar:DebugTable("Event", pEvent)
	end
	
	CalendarEventEditorFrameSubTitle:SetText(GroupCalendar.GetLongDateString(self.EventDate))
	
	self:UpdateControlsFromEvent(pEvent)
	
	ShowUIPanel(CalendarEventEditorFrame)
	
	if pIsNewEvent then
		CalendarEventTitle:SetFocus()
		CalendarEventTitle:HighlightText()
	else
		CalendarEventTitle:HighlightText(0, 0)
	end
	
	self.ShowScheduleEditor = false
	self.Active = true
end

function GroupCalendar.EventEditor:MajorDatabaseChange()
	if not self.Active then return end
	
	self:EventChanged(self.Event) -- Force the attendance to update, can come from multiple sources so just always update
	
	if self.UsingLocalTime ~= gGroupCalendar_Settings.ShowEventsInLocalTime then
		self.UsingLocalTime = gGroupCalendar_Settings.ShowEventsInLocalTime
		
		self.EventTime = self:GetTimeControlValue(CalendarEventEditorTime)
		
		if self.UsingLocalTime then
			self.EventDate, self.EventTime = MCDateLib:GetLocalDateTimeFromServerDateTime(self.EventDate, self.EventTime)
		else
			self.EventDate, self.EventTime = MCDateLib:GetServerDateTimeFromLocalDateTime(self.EventDate, self.EventTime)
		end
		
		self:SetTimeControlValue(CalendarEventEditorTime, self.EventTime)
		if gGroupCalendar_Settings.ShowEventsInLocalTime then
			CalendarEventEditorTimeZone:SetText("local")
		else
			CalendarEventEditorTimeZone:SetText("server")
		end
	end
end

function GroupCalendar.EventEditor:EventChanged(pEvent)
	if pEvent == self.Event then
		CalendarEventEditorAttendance:EventChanged(self.Database, pEvent)
		
		-- Don't update the control values since that'll overwrite whatever
		-- is currently being set up
		-- self:UpdateControlsFromEvent(pEvent)
	end
end

function GroupCalendar.EventEditor:OnLoad()
	-- Tabs
	
	PanelTemplates_SetNumTabs(this, #self.cPanelFrames)
	CalendarEventEditorFrame.selectedTab = self.CurrentPanel
	PanelTemplates_UpdateTabs(this)
end

function GroupCalendar.EventEditor:OnShow()
	PlaySound("igCharacterInfoOpen")
	
	CalendarEventEditorEventTypeMenu.ChangedValueFunc = function () GroupCalendar.EventEditor:EventTypeChanged(CalendarEventEditorEventTypeMenu, UIDropDownMenu_GetSelectedValue(CalendarEventEditorEventTypeMenu)) end
	CalendarEventEditorAttendance.Widgets.MainView.AutoConfirm.Menu.ChangedValueFunc = function (...) GroupCalendar.EventEditor:SetAutoConfirmMode(...) end
	
	self:ShowPanel(1) -- Always switch to the event view when showing the window
end

function GroupCalendar.EventEditor:OnHide()
	PlaySound("igCharacterInfoClose")
	
	CalendarAddPlayer_Cancel() -- Force the dialog to close if it's open
	
	if not self.ShowScheduleEditor then
		self:SaveEvent()
		HideUIPanel(CalendarEditorFrame)
	end
	
	self.Database = nil
	self.Event = nil
	self.Active = false
end

function GroupCalendar.EventEditor:DoneEditing()
	if not self.Active then
		return
	end
	
	self:SaveEvent()
	self:CloseEditor(true)
end

function GroupCalendar.EventEditor:UpdateControlsFromEvent(pEvent, pExistingValuesOnly)
	if not pExistingValuesOnly
	or pEvent.mType then
		CalendarEventEditorEventTypeMenu:SetSelectedValue(pEvent.mType or "NONE")
	end

	if pEvent.mTitle and pEvent.mTitle ~= "" then
		CalendarEventTitle:SetText(GroupCalendar.UnescapeString(pEvent.mTitle))
	elseif not pExistingValuesOnly
	or pEvent.mType then
		local vEventName = GroupCalendar.Database.GetEventNameByID(pEvent.mType)
		
		if vEventName ~= nil then
			CalendarEventTitle:SetText(vEventName)
		else
			CalendarEventTitle:SetText("")
		end
	end
	
	if not pExistingValuesOnly
	or self.EventTime then
		self:SetTimeControlValue(CalendarEventEditorTime, self.EventTime)
	end
	
	if not pExistingValuesOnly
	or pEvent.mDuration then
		CalendarEventEditorDurationMenu:SetSelectedValue(pEvent.mDuration)
	end

	if pEvent.mDescription then
		CalendarEventDescription:SetText(GroupCalendar.UnescapeString(pEvent.mDescription))
	elseif not pExistingValuesOnly then
		CalendarEventDescription:SetText("")
	end

	if pEvent.mMinLevel then
		CalendarEventMinLevel:SetText(pEvent.mMinLevel)
	elseif not pExistingValuesOnly then
		CalendarEventMinLevel:SetText("")
	end

	if pEvent.mMaxLevel then
		CalendarEventMaxLevel:SetText(pEvent.mMaxLevel)
	elseif not pExistingValuesOnly then
		CalendarEventMaxLevel:SetText("")
	end
	
	-- Control logic for determining the actual confirmation type.  This logic is kind
	-- of complex due to having to work backwards from the actual stored values.
	
	-- TODO: Rework event confirmation mode to a single field.  Leave the existing booleans
	-- so that downgrading doesn't affect existing events, though new events will not have
	-- those and downgrading will cause existing events to show the default Automatic mode
	
	if pEvent.mManualConfirm then
		CalendarEventEditorAttendance.Widgets.MainView.AutoConfirm.Menu:SetSelectedValue("MAN")
	elseif pEvent.mClosed then
		CalendarEventEditorAttendance.Widgets.MainView.AutoConfirm.Menu:SetSelectedValue("CLOSED")
	elseif pEvent.mRoleConfirm then
		CalendarEventEditorAttendance.Widgets.MainView.AutoConfirm.Menu:SetSelectedValue("ROLE")
	else
		CalendarEventEditorAttendance.Widgets.MainView.AutoConfirm.Menu:SetSelectedValue("AUT")
	end
	
	if not pExistingValuesOnly
	or pEvent.mType then
		self.PreviousEventType = pEvent.mType
		self:SetEventType(pEvent.mType)
	end
	
	if self.Database.Guild
	and not GroupCalendar.Database.IsPrivateEventType(pEvent.mType) then
		CalendarEventEditorGuildOnly:SetChecked(pEvent.mGuild == self.Database.Guild)
		CalendarEventEditorGuildOnly:Show()
	else
		CalendarEventEditorGuildOnly:Hide()
	end
end

function GroupCalendar.EventEditor:SaveClassLimits(pLimits)
	CalendarEventEditorAttendance.NewClassLimits = pLimits
end

function GroupCalendar.EventEditor:GetDropdownEventType()
	vValue = UIDropDownMenu_GetSelectedValue(CalendarEventEditorEventTypeMenu)
	
	if vValue == "NONE" then
		return
	end
	
	return vValue
end

function GroupCalendar.EventEditor:UpdateEventFromControls(rEvent, rChangedFields)
	local vChanged = false
	local vValue
	
	-- Type
	
	vValue = self:GetDropdownEventType()
	
	if rEvent.mType ~= vValue then
		rEvent.mType = vValue
		rChangedFields.mType = {op = "UPD", val = vValue}
		vChanged = true
	end
	
	local vPrivate = GroupCalendar.Database.IsPrivateEventType(vValue)
	
	if rEvent.mPrivate ~= vPrivate then
		rEvent.mPrivate = vPrivate
		rChangedFields.mPrivate = {op = "UPD", val = vPrivate}
		vChanged = true
	end
	
	-- Title
	
	vValue = CalendarEventTitle:GetText()
	
	if vValue == GroupCalendar.Database.GetEventNameByID(rEvent.mType)
	or vValue == "" then
		vValue = nil
	else
		vValue = GroupCalendar.EscapeString(vValue)
	end
	
	if vValue and string.len(vValue) > GroupCalendar_cMaxFieldLength then
		vValue = string.sub(vValue, 1, GroupCalendar_cMaxFieldLength)
	end
	
	if rEvent.mTitle ~= vValue then
		rEvent.mTitle = vValue
		rChangedFields.mTitle = "UPD"
		vChanged = true
	end
	
	-- Time
	
	local vDate, vTime = nil, nil
	
	if GroupCalendar.Database.EventTypeUsesTime(rEvent.mType) then
		vDate, vTime = self.EventDate, self:GetTimeControlValue(CalendarEventEditorTime)
		
		if self.UsingLocalTime then
			vDate, vTime = MCDateLib:GetServerDateTimeFromLocalDateTime(vDate, vTime)
		end
	else
		vDate = self.EventDate
	end
	
	if rEvent.mDate ~= vDate then
		rEvent.mDate = vDate
		rChangedFields.mDate = "UPD"
		vChanged = true
	end
	
	if rEvent.mTime ~= vTime then
		rEvent.mTime = vTime
		rChangedFields.mTime = "UPD"
		vChanged = true
	end
	
	-- Duration
	
	if GroupCalendar.Database.EventTypeUsesTime(rEvent.mType) then
		vValue = UIDropDownMenu_GetSelectedValue(CalendarEventEditorDurationMenu)
	else
		vValue = nil
	end
	
	if vValue == 0 then
		vValue = nil
	end
	
	if rEvent.mDuration ~= vValue then
		rEvent.mDuration = vValue
		rChangedFields.mDuration = "UPD"
		vChanged = true
	end
	
	-- Description
	
	vValue = CalendarEventDescription:GetText()
	
	if vValue == "" then
		vValue = nil
	else
		vValue = GroupCalendar.EscapeString(vValue)
	end
	
	if vValue and string.len(vValue) > GroupCalendar_cMaxFieldLength then
		vValue = string.sub(vValue, 1, GroupCalendar_cMaxFieldLength)
	end
	
	if rEvent.mDescription ~= vValue then
		rEvent.mDescription = vValue
		rChangedFields.mDescription = "UPD"
		vChanged = true
	end
	
	-- MinLevel
	
	if GroupCalendar.Database.EventTypeUsesLevelLimits(rEvent.mType) then
		vValue = CalendarEventMinLevel:GetText()
	else
		vValue = nil
	end
	
	if vValue and vValue ~= "" then
		vValue = tonumber(vValue)
		
		if vValue == 0 then
			vValue = nil
		end
	else
		vValue = nil
	end
	
	if rEvent.mMinLevel ~= vValue then
		rEvent.mMinLevel = vValue
		rChangedFields.mMinLevel = "UPD"
		vChanged = true
	end
	
	-- MaxLevel
	
	if GroupCalendar.Database.EventTypeUsesTime(rEvent.mType) then
		vValue = CalendarEventMaxLevel:GetText()
	else
		vValue = nil
	end
	
	if vValue and vValue ~= "" then
		vValue = tonumber(vValue)
		
		if vValue == 0 then
			vValue = nil
		end
	else
		vValue = nil
	end
	
	if rEvent.mMaxLevel ~= vValue then
		rEvent.mMaxLevel = vValue
		rChangedFields.mMaxLevel = "UPD"
		vChanged = true
	end
	
	-- Automatic confirmations
	
	local vManualConfirm, vRoleConfirm, vClosedEvent
	
	if GroupCalendar.Database.IsQuestingEventType(rEvent.mType) then
		local vAutoConfirmValue = UIDropDownMenu_GetSelectedValue(CalendarEventEditorAttendance.Widgets.MainView.AutoConfirm.Menu)
		
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
	
	if vClosedEvent ~= rEvent.mClosed then
		rEvent.mClosed = vClosedEvent
		rChangedFields.mClosed = {op = "UPD", val = vClosedEvent}
	end
	
	if vManualConfirm ~= rEvent.mManualConfirm then
		rEvent.mManualConfirm = vManualConfirm
		rChangedFields.mManualConfirm = {op = "UPD", val = vManualConfirm}
	end
	
	if vRoleConfirm ~= rEvent.mRoleConfirm then
		rEvent.mRoleConfirm = vRoleConfirm
		rChangedFields.mRoleConfirm = {op = "UPD", val = vRoleConfirm}
	end
	
	local vGuild = nil
	
	if CalendarEventEditorGuildOnly:GetChecked() then
		vGuild = self.Database.Guild
	end
	
	if vGuild ~= rEvent.mGuild then
		rEvent.mGuild = vGuild
		rChangedFields.mGuild = {op = "UPD", val = vGuild}
	end
	
	if GroupCalendar.Database.IsQuestingEventType(rEvent.mType) then
		if CalendarEventEditorAttendance.NewClassLimits
		and not GroupCalendar.LimitsAreEqual(rEvent.mLimits, CalendarEventEditorAttendance.NewClassLimits) then
			rEvent.mLimits = CalendarEventEditorAttendance.NewClassLimits
			rChangedFields.mLimits = {op = "UPD", val = rEvent.mLimits}
		end
	else
		-- No limits on non-questing event types (ie, meetings)
		
		if rEvent.mLimits then
			rEvent.mLimits = nil
			rChangedFields.mLimits = {op = "UPD", val = rEvent.mLimits}
		end
	end
	
	-- Done
	
	return vChanged
end

function GroupCalendar.EventEditor:SetEventType(pEventType)
	-- CalendarEventEditorEventTypeMenu:Show()
	-- CalendarEventTitle:Show()
	-- CalendarEventDescription:Show()
	
	CalendarDropDown_SetSelectedValue(CalendarEventEditorEventTypeMenu, pEventType or "NONE")
	
	local vTitleText = CalendarEventTitle:GetText()
	local vEventName = GroupCalendar.Database.GetEventNameByID(self.PreviousEventType)
	local vTitleWasEventName = vTitleText == vEventName or vTitleText == ""
	
	if GroupCalendar.Database.EventTypeUsesTime(pEventType) then
		CalendarEventEditorTime:Show()
		CalendarEventEditorDurationMenu:Show()
	else
		CalendarEventEditorTime:Hide()
		CalendarEventEditorDurationMenu:Hide()
	end
	
	if GroupCalendar.Database.EventTypeUsesLevelLimits(pEventType) then
		CalendarEventMinLevel:Show()
		CalendarEventMaxLevel:Show()
	else
		CalendarEventMinLevel:Hide()
		CalendarEventMaxLevel:Hide()
	end
	
	if GroupCalendar.Database.EventTypeUsesAttendance(pEventType) then
		CalendarEventEditorFrameTab2:Show()
		CalendarEventEditorSelfAttend:Show()
		CalendarEventEditorGuildOnly:Show()
	else
		CalendarEventEditorFrameTab2:Hide()
		CalendarEventEditorSelfAttend:Hide()
		CalendarEventEditorGuildOnly:Hide()
	end
	
	if vTitleWasEventName then
		CalendarEventTitle:SetText(GroupCalendar.Database.GetEventNameByID(pEventType) or "")
		CalendarEventTitle:SetFocus()
		CalendarEventTitle:HighlightText()
	end
	
	-- Update the sample icon
	
	CalendarEventEditorEventBackground:SetTexture(GroupCalendar.GetEventTypeIconPath(pEventType))
	if pEventType == "Birth" then
		CalendarEventEditorEventBackground:SetVertexColor(1, 1, 1, 0.4)
	else
		CalendarEventEditorEventBackground:SetVertexColor(1, 1, 1, 0.19)
	end

	--
	
	self.PreviousEventType = pEventType
end

function GroupCalendar.EventEditor:DeleteEvent()
	if not self.IsNewEvent then
		GroupCalendar.Database.DeleteEvent(self.Database, self.Event)
	end
	
	self:CloseEditor(true)
end

function GroupCalendar.EventEditor:DeleteRSVP()
	if not GroupCalendar.RSVPToDelete then
		return
	end
	
	GroupCalendar.RSVPToDelete.mStatus = "C"
	
	GroupCalendar.Database.AddEventRSVP(
			self.Database,
			self.Event,
			GroupCalendar.RSVPToDelete.mName,
			GroupCalendar.RSVPToDelete)
	
	GroupCalendar.RSVPToDelete = nil
end

function GroupCalendar.EventEditor:CloseEditor(pShowScheduleEditor)
	self.Active = false
	
	self.ShowScheduleEditor = pShowScheduleEditor
	HideUIPanel(CalendarEventEditorFrame)
end

function GroupCalendar.EventEditor:CopyTemplateFields(pFromEvent, rToEvent)
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

function GroupCalendar.EventEditor:SaveEvent()
	-- Update the event
	
	local vChangedFields = {}
	
	self:UpdateEventFromControls(self.Event, vChangedFields)
	
	if GroupCalendar.ArrayIsEmpty(vChangedFields) then
		return
	end
	
	-- Save the event if it's new
	
	if self.IsNewEvent then
		if (self.Event.mTitle ~= nil and self.Event.mTitle ~= "")
		or self.Event.mType ~= nil then
			GroupCalendar.Database.AddEvent(self.Database, self.Event)
			
			-- If self-attend is selected add the RSVP
			
			if CalendarEventEditorSelfAttend:GetChecked() then
				self:SetSelfAttend(true, true)
			end
		end
	else
		GroupCalendar.Database.EventChanged(self.Database, self.Event, vChangedFields)
	end
	
	-- Save a template for the event
	
	if self.Event.mType
	and self.Event.mType ~= "Birth" then
		local vEventTemplate = {}
		
		self:CopyTemplateFields(self.Event, vEventTemplate)
		vEventTemplate.mSelfAttend = self:GetSelfAttend()
		
		GroupCalendar.SaveEventTemplate(vEventTemplate)
	end
end

function GroupCalendar.EventEditor:SetTimeControlValue(pFrame, pTime)
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

function GroupCalendar.EventEditor:GetTimeControlValue(pFrame)
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

function GroupCalendar.EventEditor:LoadEventDefaults(pTemplate)
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
	
	if not vTemplate then
		vTemplate = GroupCalendar.FindEventTemplateByTitle(vEventInfo.name)
	end
	
	if vTemplate then
		self:CopyTemplateFields(vTemplate, self.Event)
		
		-- Convert the date/time to local
		
		if vTemplate.mTime and self.EventDateIsLocal then
			_, self.Event.mTime = MCDateLib:GetLocalDateTimeFromServerDateTime(self.Event.mDate, self.Event.mTime)
		end
		
		self.EventTime = self.Event.mTime
		
		self:UpdateControlsFromEvent(self.Event, true)
		
		if vTemplate.mSelfAttend then
			self:SetSelfAttend(vTemplate.mSelfAttend)
		end
	end
end

function GroupCalendar.EventEditor:EventTypeChanged(pMenuFrame, pValue)
	self:SetEventType(pValue)
	
	-- Set the templated field values if available
	
	if self.IsNewEvent then
		self:LoadEventDefaults()
	end
end

function GroupCalendar.EventEditor:SetAutoConfirmMode(pMenuFrame, pValue)
	pMenuFrame.AttendanceViewer:SetAutoConfirmMode(pValue)
end

function GroupCalendar.EventEditor:ShowPanel(pPanelIndex)
	CalendarAddPlayer_Cancel() -- Force the dialog to close if it's open
	
	if self.CurrentPanel > 0
	and self.CurrentPanel ~= pPanelIndex then
		self:HidePanel(self.CurrentPanel)
	end
	
	-- NOTE: Don't check for redundant calls since this function
	-- will be called to reset the field values as well as to 
	-- actuall show the panel when it's hidden
	
	self.CurrentPanel = pPanelIndex
	
	-- Update the control values
	
	if pPanelIndex == GroupCalendar.EventEditor.EventPanelIndex then
		-- Event panel
		
		CalendarEventEditorSelfAttend:SetChecked(self:GetSelfAttend())
		CalendarEventEditorSelfAttendText:SetText(string.format(GroupCalendar_cSelfWillAttend, GroupCalendar.PlayerName))
		
		if self.Database.Guild then
			CalendarEventEditorGuildOnlyText:SetText(string.format(GroupCalendar_cGuildOnly, self.Database.Guild))
		end
		
	elseif pPanelIndex == GroupCalendar.EventEditor.AttendancePanelIndex then
		-- Attendance panel
		
		if GroupCalendar.Database.IsQuestingEventType(self.PreviousEventType) then
			CalendarEventEditorAttendance:SetTotalsVisible(true, true)
		else
			CalendarEventEditorAttendance:SetTotalsVisible(false, false)
		end
	else
		GroupCalendar:DebugMessage("EventEditor:ShowPanel: Unknown index (%s)", pPanelIndex or "nil")
	end
	
	getglobal(self.cPanelFrames[pPanelIndex]):Show()
	
	PanelTemplates_SetTab(CalendarEventEditorFrame, pPanelIndex)
	
	self:Update()
end

function GroupCalendar.EventEditor:HidePanel(pFrameIndex)
	if self.CurrentPanel ~= pFrameIndex then
		return
	end
	
	getglobal(self.cPanelFrames[pFrameIndex]):Hide()
	self.CurrentPanel = 0
end

function GroupCalendar.EventEditor:Update()
	-- Event panel
	
	if self.CurrentPanel == GroupCalendar.EventEditor.EventPanelIndex then
	
	-- Attendance panel
	
	elseif self.CurrentPanel == GroupCalendar.EventEditor.AttendancePanelIndex then
		CalendarEventEditorAttendance:Update()
	end
end

GroupCalendar.cStatusCodeStrings =
{
	N = CalendarEventEditor_cNotAttending,
	Y = CalendarEventEditor_cConfirmed,
	D = CalendarEventEditor_cDeclined,
	S = CalendarEventEditor_cStandby,
	P = CalendarEventEditor_cPending,
	M = CalendarEventEditor_cMaybe,
	["-"] = CalendarEventEditor_cBanned,
}

function GroupCalendar.EventEditor:GetStatusString(pStatus)
	local vStatus1 = string.sub(pStatus, 1, 1)
	local vString = GroupCalendar.cStatusCodeStrings[vStatus1]
	
	if vString then	
		return vString
	else
		return format(CalendarEventEditor_cUnknownStatus, pStatus)
	end
end

function GroupCalendar.EventEditor:GetSelfAttend()
	return GroupCalendar.Database.FindEventRSVPString(self.Event, GroupCalendar.PlayerName) ~= nil
end

function GroupCalendar.EventEditor:SetSelfAttend(pWillAttend, pNewEventOverride)
	-- Don't do anything if it's a new event (it'll be handled during save)
	
	if self.IsNewEvent and not pNewEventOverride then
		return
	end
	
	-- Create or remove the RSVP request for the owner
	
	if pWillAttend then
		local vRSVP = GroupCalendar.Database.CreatePlayerRSVP(
								self.Database,
								self.Event,
								GroupCalendar.PlayerName,
								GroupCalendar.Database.GetRaceCodeByRaceID(GroupCalendar.UnitRaceID("PLAYER")),
								GroupCalendar.Database.GetClassCodeByClassID(GroupCalendar.UnitClassID("PLAYER")),
								GroupCalendar.PlayerLevel,
								GroupCalendar.GetPlayerDefaultRole(),
								"Y",
								nil,
								GroupCalendar.PlayerGuild,
								GroupCalendar.PlayerGuildRank,
								GroupCalendar.PlayerCharacters)
		
		GroupCalendar.Database.AddEventRSVP(
				self.Database,
				self.Event,
				GroupCalendar.PlayerName,
				vRSVP)
	else
		GroupCalendar.Database.RemoveEventRSVP(
				self.Database,
				self.Event,
				GroupCalendar.PlayerName)
	end
end

function GroupCalendar.EventEditor:AskDeleteEvent()
	-- If it's new just kill it without asking
	
	if self.IsNewEvent then
		self:DeleteEvent()
	else
		-- Update an event record so we can display a meaningful name
		
		local vChangedFields = {}
		local vEvent = {}
		
		self:UpdateEventFromControls(vEvent, vChangedFields)
		
		StaticPopup_Show("CONFIRM_CALENDAR_EVENT_DELETE", GroupCalendar.Database.GetEventDisplayName(vEvent))
	end
end

function GroupCalendar.EventEditor:AttendanceMenuItemSelected(pOwner, pValue)
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
			GroupCalendar.RSVPToDelete = vItem
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

function GroupCalendar.EventEditor:UpdateDescriptionCounter(pText)
	local vCurLength = string.len(GroupCalendar.EscapeString(pText))

	CalendarEventDescriptionLimit:SetText(vCurLength.."/"..GroupCalendar_cMaxFieldLength)

	-- Figure out the amount used in the description and color progress based on percentage
	
	local vPercentUsed = vCurLength / GroupCalendar_cMaxFieldLength
	
	if vPercentUsed <= 0.75 then
		CalendarEventDescriptionLimit:SetVertexColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif vCurLength < GroupCalendar_cMaxFieldLength then
		CalendarEventDescriptionLimit:SetVertexColor(0.9, 0.9, 0.05) -- Yellow
	else
		CalendarEventDescriptionLimit:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	end
end

