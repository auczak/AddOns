-- Locals

function KA_RaidTracker_ItemOptions_ScrollBar_Update()
	table.sort(KARaidTrackerDB.ItemOptions, function(a1, a2) return a1["id"] < a2["id"]; end);
  local line;
  local lineplusoffset;
	local maxlines = getn(KARaidTrackerDB.ItemOptions);
	local text;
  FauxScrollFrame_Update(KA_RaidTracker_ItemOptions_ScrollBar, maxlines, 24, 14);
  for line=1, 24 do
  	local thisline = getglobal("KA_RaidTracker_ItemOptions_Entry"..line);
    lineplusoffset = line + FauxScrollFrame_GetOffset(KA_RaidTracker_ItemOptions_ScrollBar);
    if lineplusoffset <= maxlines then
    	local nameGIF, linkGIF, qualityGIF, LevelGIF, minLevelGIF, classGIF, subclassGIF, maxStackGIF, invtypeGIV, iconGIF = GetItemInfo(KARaidTrackerDB.ItemOptions[lineplusoffset]["id"]);
    	if(nameGIF) then
    		KARaidTrackerDB.ItemOptions[lineplusoffset]["name"] = nameGIF;
    		KARaidTrackerDB.ItemOptions[lineplusoffset]["quality"] = qualityGIF;
    	end
    	if(KARaidTrackerDB.ItemOptions[lineplusoffset]["name"]) then
    		local _, _, _, color = GetItemQualityColor(KARaidTrackerDB.ItemOptions[lineplusoffset]["quality"]);
    		text = color..KARaidTrackerDB.ItemOptions[lineplusoffset]["name"];
    	else
    		text = "Unknown (ID: "..KARaidTrackerDB.ItemOptions[lineplusoffset]["id"]..")";
    	end
    	thisline.id = lineplusoffset;
    	thisline.itemid = KARaidTrackerDB.ItemOptions[lineplusoffset]["id"];
			thisline:SetText(text);
			thisline:Show();
			if(KARaidTrackerDB.Options["ItemOptionsSelected"] == lineplusoffset) then
				getglobal("KA_RaidTracker_ItemOptions_Entry"..line.."MouseOver"):Show();
			else
				getglobal("KA_RaidTracker_ItemOptions_Entry"..line.."MouseOver"):Hide();
			end
    else
      thisline:Hide();
      getglobal("KA_RaidTracker_ItemOptions_Entry"..line.."MouseOver"):Hide();
    end
  end
end

function KA_RaidTracker_ItemOptions_SetFrame(id)
	KA_RaidTracker_ItemOptions_EditFrame.id = id;
	KA_RaidTracker_ItemOptions_EditFrame:Hide();
	local itemname;
	if(KARaidTrackerDB.ItemOptions[id]["name"]) then
		local _, _, _, color = GetItemQualityColor(KARaidTrackerDB.ItemOptions[id]["quality"]);
    itemname = color..KARaidTrackerDB.ItemOptions[id]["name"];
	else
		itemname = "Unknown (ID: "..KARaidTrackerDB.ItemOptions[id]["id"]..")";
	end
	KA_RaidTracker_ItemOptions_EditFrame_Item:SetText(itemname);
	KA_RaidTracker_ItemOptions_EditFrame:Show();
end

function KA_RaidTracker_ItemOptions_Delete(id)
	table.remove(KARaidTrackerDB.ItemOptions, id);
	if(KARaidTrackerDB.Options["ItemOptionsSelected"]) then
		if(KARaidTrackerDB.Options["ItemOptionsSelected"] == id) then
			KARaidTrackerDB.Options["ItemOptionsSelected"] = nil;
		elseif(KARaidTrackerDB.Options["ItemOptionsSelected"] > id) then
			KARaidTrackerDB.Options["ItemOptionsSelected"] = KARaidTrackerDB.Options["ItemOptionsSelected"] - 1;
		end
	end
	KA_RaidTracker_ItemOptions_EditFrame:Hide();
	KA_RaidTracker_ItemOptions_ScrollBar_Update();
end

function KA_RaidTracker_ItemOptions_Save()
	local id = this:GetParent().id;
	if(KA_RaidTracker_ItemOptions_EditFrame_TrackAlways:GetChecked()) then
		KARaidTrackerDB.ItemOptions[id]["status"] = 1;
	elseif(KA_RaidTracker_ItemOptions_EditFrame_TrackNever:GetChecked()) then
		KARaidTrackerDB.ItemOptions[id]["status"] = 0;
	else
		KARaidTrackerDB.ItemOptions[id]["status"] = nil;
	end
	if(KA_RaidTracker_ItemOptions_EditFrame_GroupAlways:GetChecked()) then
		KARaidTrackerDB.ItemOptions[id]["group"] = 1;
	elseif(KA_RaidTracker_ItemOptions_EditFrame_GroupNever:GetChecked()) then
		KARaidTrackerDB.ItemOptions[id]["group"] = 0;
	else
		KARaidTrackerDB.ItemOptions[id]["group"] = nil;
	end
	if(KA_RaidTracker_ItemOptions_EditFrame_CostsGrabbingAlways:GetChecked()) then
		KARaidTrackerDB.ItemOptions[id]["costsgrabbing"] = 1;
	elseif(KA_RaidTracker_ItemOptions_EditFrame_CostsGrabbingNever:GetChecked()) then
		KARaidTrackerDB.ItemOptions[id]["costsgrabbing"] = 0;
	else
		KARaidTrackerDB.ItemOptions[id]["costsgrabbing"] = nil;
	end
	if(KA_RaidTracker_ItemOptions_EditFrame_AskCostsAlways:GetChecked()) then
		KARaidTrackerDB.ItemOptions[id]["askcosts"] = 1;
	elseif(KA_RaidTracker_ItemOptions_EditFrame_AskCostsNever:GetChecked()) then
		KARaidTrackerDB.ItemOptions[id]["askcosts"] = 0;
	else
		KARaidTrackerDB.ItemOptions[id]["askcosts"] = nil;
	end
	KA_RaidTracker_ItemOptions_EditFrame:Hide();
end