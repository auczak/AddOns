--[[
	Persistent Data for RaidTracker, Saved Variables	
]]


--***********************************************************************************
-- Saved Variables

KARaidTrackerData = {
	_store = {	
		db = nil;
		name = nil;
		defaults = nil;
	}
};

function KARaidTrackerData:FindRawValue( db, name1, name2 )
	local val = nil;
	
	if name1 then
		for i,v in pairs(db) do
			if i == name1 then
				if name2 and type(v) == "table"  then
					for ii,vv in pairs(v) do
						if ii == name2 then
							val = vv
							break
						end
					end
				else
					val = v
					break
				end
				break
			end
		end
	end
	
	return val		
end

function KARaidTrackerData:PrintValue( name1, name2, val )
	local s = self._store;	
	local def = self:FindRawValue( s.defaults, name1, name2 )
	local db = self:FindRawValue( s.db, name1, name2 )
	KARaidTrackerUtility:SysMsg( "      ",name1,".",name2,"=",val,":",def,":",db )
end


function KARaidTrackerData:HookDB( )
	local s = self._store;
	if not s.name then return end
	
	-- init db and chain: self --> db --> defaults
	s.db = _G[s.name] or { }
	_G[s.name] = s.db
	for i,v in pairs(s.defaults) do
		if type(v) == "table"  then
			if not s.db[i] then	s.db[i] = { } end 
			setmetatable( s.db[i], {__index = s.defaults[i]} ); 	
		end
	end
	setmetatable( self, {__index=s.db} )
	setmetatable( s.db, {__index=s.defaults} )
end 

function KARaidTrackerData:RegisterDB( name, defaults )
	if not name then return end
	local s = self._store;
	
	s.name = name;
	s.defaults = defaults or { };
					
	self:HookDB( );
end 

function KARaidTrackerData:ImportToDB( dbitem, src, prefix, isMerge, names )
	if not names or not src then return end
	local dst = self._store.db;
	local util = KARaidTrackerUtility;
	
	if dbitem then 
		if not dst[dbitem] then dst[dbitem] = { }  end
		dst = dst[dbitem];
	end

	for i,v in pairs(names) do
		local srcname = prefix..v
		if type(i) == "number" then i = v end
		
		if src[srcname] then
			util:SysMsg( "  importing ",srcname," to ",dbitem,":",i );
			if isMerge then
				util:MergeDeep( dst[i], src[srcname] );
			else
				dst[i] = util:CopyDeep( src[srcname] );
			end
		end
	end
end


function KARaidTrackerData:OnVariablesLoaded( )
	self:HookDB( );

	if self.RunVersionFix then self:RunVersionFix() end;	
end

