

local didLoad, o = LoadLibrary1("ItemDB_VendorPrices", 101, nil, nil, "CommonParsingTooltip1", "EventsManager1");



if (didLoad == true) then
	o.EventsManager1 = EventsManager1;
	
	do
		local success, reason = LoadAddOn("Lib-ItemDB_VendorPrices1_SavedVariables");
		if (success == nil) then
			error(("ItemDB_VendorPrices1: Failed to load saved variables stub Lib-ItemDB_VendorPrices1_SavedVariables, for the following reason: %s. The addon will attempt to continue operating normally, but errata cannot be saved."):format(tostring(getglobal(reason) or reason)));
		end
	end
end

