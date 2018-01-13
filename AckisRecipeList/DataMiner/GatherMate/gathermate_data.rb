#!/usr/bin/env ruby -I../ -w
require "wowdb_maps"

# our map of Zones to internal ID's
$zone_map = {
  "Arathi Highlands" => 1,
	"Orgrimmar" => 2,
	"Eastern Kingdoms" => 3,
	"Undercity" => 4,
	"The Barrens" => 5,
	"Darnassus" => 6,
	"Azuremyst Isle" => 7,
	"Un'Goro Crater" => 8,
	"Burning Steppes" => 9,
	"Wetlands" => 10,
	"Winterspring" => 11,
	"Dustwallow Marsh" => 12,
	"Darkshore" => 13,
	"Loch Modan" => 14,
	"Blade's Edge Mountains" => 15,
	"Durotar" => 16,
	"Silithus" => 17,
	"Shattrath City" => 18,
	"Ashenvale" => 19,
	"Azeroth" => 20,
	"Nagrand" => 21,
	"Terokkar Forest" =>22,
	"Eversong Woods" =>23,
	"Silvermoon City" => 24,
	"Tanaris" => 25,
	"Stormwind City" => 26,
	"Swamp of Sorrows" => 27,
  "Eastern Plaguelands" => 28,
	"Blasted Lands" => 29,
	"Elwynn Forest" => 30,
	"Deadwind Pass" => 31,
	"Dun Morogh" => 32,
	"The Exodar" => 33,
	"Felwood" => 34,
	"Silverpine Forest" => 35,
	"Thunder Bluff" => 36,
	"The Hinterlands" => 37,
	"Stonetalon Mountains" => 38,
	"Mulgore" => 39,
	"Hellfire Peninsula" => 40,
	"Ironforge" => 41,
	"Thousand Needles" => 42,
	"Stranglethorn Vale" => 43,
	"Badlands" => 44,
	"Teldrassil" => 45,
	"Moonglade" => 46,
	"Shadowmoon Valley" =>47,
	"Tirisfal Glades" => 48,
	"Azshara" => 49,
	"Redridge Mountains" => 50,
	"Bloodmyst Isle" => 51,
	"Western Plaguelands" => 52,
	"Alterac Mountains" => 53,
	"Westfall" => 54,
	"Duskwood" => 55,
	"Netherstorm" => 56,
	"Ghostlands" => 57,
	"Zangarmarsh" => 58,
	"Desolace" => 59,
	"Kalimdor" => 60,
	"Searing Gorge" => 61,
	"Outland" => 62,
	"Feralas" => 63,
	"Hillsbrad Foothills" => 64,
	"Isle of Quel'Danas" => 65,
	"Borean Tundra" => 67,
	"Dragonblight" => 68,
	"Grizzly Hills" => 69,
	"Howling Fjord" => 70,
	"Icecrown" => 71,
	"Sholazar Basin" => 72,
	"The Storm Peaks" => 73,
	"Zul'Drak" => 74,
	"Crystalsong Forest" => 77,
}
# rare item mappings, NEEDS Wrath updates
$rare_map = {
  	204 => [202,203], # silver
  	205 => [203,206], # gold
  	208 => [206,214,215], # truesilver
  	209 => [212,213,207], # oozed covered silver
  	210 => [212,213,207], # ooze covered gold
  	211 => [212,213,207], # oozed covered true silver
  	217 => [206,214,215], # dark iron
  	224 => [222,223,221], # khorium
  	223 => [222],
  	441 => [440] #flame cap
}
$rare_src = {
  202 => [204,203],
  203 => [204,205],
  206 => [208,217,205],
  214 => [208,217],
  215 => [208,217],
  207 => [209,210,211],
  212 => [209,210,211],
  213 => [209,210,211],
  440 => [441],
  222 => [224,223],
  223 => [224],
  221 => [224]
}
# mieral viens
mineral_map = {
  "Copper Vein"                     => 201,
  "Incendicite Mineral Vein"        => 219,
  "Tin Vein"                        => 202,
  "Lesser Bloodstone Deposit"       => 218,
  "Iron Deposit"                    => 203,
  "Mithril Deposit"                 => 206,
  "Ooze Covered Mithril Deposit"    => 207,
  "Small Thorium Vein"              => 214,
  "Ooze Covered Thorium Vein"       => 213,
  "Rich Thorium Vein"               => 215,
  "Fel Iron Deposit"                => 221,
  "Adamantite Deposit"              => 222,
  "Rich Adamantite Deposit"         => 223,
  "Khorium Vein"                    => 224,
  "Nethercite Deposit"              => 227,
  # rare nodes below
  "Silver Vein"                     => 204,
  "Ooze Covered Silver Vein"        => 209,
  "Ooze Covered Rich Thorium Vein"  => 212,
  "Dark Iron Deposit"               => 217,
  "Truesilver Deposit"              => 208,
  "Ooze Covered Truesilver Deposit" => 211,
  "Gold Vein"                       => 205,
  "Ooze Covered Gold Vein"          => 210,
# "Cobalt Node"						          => 228,
#	"Rich Cobalt Node"				        => 229,
#	"Titanium Node"					          => 230,
#	"Saronite Node"					          => 231,
#	"Rich Saronite Node"				      => 232,
}
  # Herbs
herb_map = {
  "Silverleaf" 			    => 402,
  "Peacebloom" 			    => 401,
  "Bloodthistle"		    => 436,
  "Earthroot"			    	=> 403,
  "Mageroyal" 		    	=> 404,
  "Briarthorn" 		    	=> 405,
  "Stranglekelp" 		  	=> 407,
  "Bruiseweed" 			    => 408,
  "Wild Steelbloom" 		=> 409,
  "Grave Moss" 			    => 410,
  "Kingsblood" 			    => 411,
  "Liferoot" 				    => 412,
  "Fadeleaf" 				    => 413,
  "Goldthorn" 				  => 414,
  "Khadgar's Whisker" 	=> 415,
  "Wintersbite" 			  => 416,
  "Firebloom" 				  => 417,
  "Purple Lotus" 			  => 418,
  "Arthas' Tears" 			=> 420,
  "Sungrass" 				    => 421,
  "Blindweed" 				  => 422,
  "Ghost Mushroom" 		  => 423,
  "Gromsblood" 			    => 424,
  "Golden Sansam" 			=> 425,
  "Dreamfoil" 				  => 426,
  "Mountain Silversage" => 427,
  "Plaguebloom" 			  => 428,
  "Icecap" 				      => 429,
  "Black Lotus" 			  => 431,
  "Felweed" 				    => 432,
  "Dreaming Glory" 		  => 433,
  "Terocone" 			  	  => 434,
  "Ragveil" 				    => 440,
  "Flame Cap" 			  	=> 441,
  "Netherbloom" 		  	=> 438,
  "Nightmare Vine" 	  	=> 439,
  "Mana Thistle" 		  	=> 437,
  "Netherdust Bush"     => 442,
#	"Adder's Tongue"			=> 443,
#	"Constrictor Grass"		=> 444,
#	"Deadnettle"					=> 445,
#	"Goldclover"					=> 446,
#	"Icethorn"						=> 447,
#	"Lickbloom"						=> 448,
#	"Talandra's Rose"			=> 449,
#	"Tiger Lily"					=> 450,
}  
treasure_map = {
  "Giant Clam" 						    => [2744,501],
	"Battered Chest" 				    => [2843,502],
	"Tattered Chest" 				    => [2844,503],
	"Solid Chest" 					    => [2850,504],
	"Large Iron Bound Chest"    => [74447,505],
	"Large Solid Chest" 			  => [74448,506],
	"Large Battered Chest"		  => [75293,507],
	"Buccaneer's Strongbox" 	  => [123330,508],
	"Large Mithril Bound Chest" => [153468,509],
	"Large Darkwood Chest" 			=> [131979,510],
	"Un'Goro Dirt Pile" 				=> [157936,511],
	"Bloodpetal Sprout" 				=> [164958,512],
	"Blood of Heroes" 				  => [176213,513],
	"Practice Lockbox" 			  	=> [178244,514],
	"Battered Footlocker" 		  => [179488,515],
	"Waterlogged Footlocker" 	  => [179487,516],
	"Dented Footlocker" 			  => [179496,517],
	"Mossy Footlocker" 				  => [179497,518],
	"Scarlet Footlocker" 			  => [179498,519],
	"Burial Chest" 					    => [181665,520],
	"Fel Iron Chest" 					  => [181798,521],
	"Heavy Fel Iron Chest" 		  => [181800,522],
	"Adamantite Bound Chest" 	  => [181802,523],
	"Felsteel Chest" 					  => [181804,524],
	"Glowcap" 						      => [182053,525],
	"Wicker Chest" 					    => [184740,526],
	"Primitive Chest" 				  => [184793,527],
	"Solid Fel Iron Chest" 		  => [184930,528],
	"Bound Fel Iron Chest" 		  => [184931,529],
	"Bound Adamantite Chest" 	  => [184936,530],
	"Netherwing Egg" 					  => [185915,531],
}
# utility function to convert to GM format
def gather_coords(x,y)
  if y == 100
    y = 99.9
  end
  if x == 100
    x = 99.9
  end
  id = (x * 10000 + 0.5).floor * 10000 + (y * 10000 + 0.5).floor
  return id/100
end
# process a mapline from wowhead player maps (Used for gas clouds)
def process_mapline(line,zoneid,node_id, map)
  offset = 0
  length = 6
  lineLength = line.length
  map[zoneid] = Hash.new
  count = 0
  while offset < lineLength
    x = "#{line[offset,2]}.#{line[offset+2,1]}"
    y = "#{line[offset+3,2]}.#{line[offset+5,1]}"
    offset = offset + 6
    map[zoneid][gather_coords(x.to_f,y.to_f)] = node_id
    count +=1
  end
  return count
end
# Create a saved variable file for import by gather mate
# interested list has 2 formats
# key = val and key = [wowdb id,val]
# this is needed since wowdb will only return at max a list of 200 items a lookup
def create_saved_vars(data_file,database,interested,variable)
  start = Time.now
  count = 0
  storage = Hash.new
  passed = true
  puts "Starting data extract for #{variable}"
  interested.each_pair do |key,val|
    puts "\tNode: #{key}"
    begin
      begin
        maps = database.get_maps(key)
      rescue Exception => noData
        maps = database.get_map_locations(val[0])
        val = val[1]
      end
      isRare = $rare_map.has_key?(val)
      maps.each_pair do |map,coords|
        puts "\t\tZone #{map}"
        zoneID = $zone_map[map]
        coords.each do |coord|
          x = coord[0]
          y = coord[1]
          gid = gather_coords(x,y)
          count += 1
          unless storage[zoneID]
            storage[zoneID] = Hash.new
          end
          if storage[zoneID].has_key?(gid) and not isRare # we already have a node at the location we are processing
            if $rare_src.has_key?(val) and $rare_src[val].include?(storage[zoneID][gid]) #
              storage[zoneID][gid] = val
            else
              # we have a conflict, this may be due to the fact wowhead only keps track of node to 1 decimal place and it really is a 1 yard difference
              # lets generate a new x,y shifting it by 10 yards
              while storage[zoneID].has_key?(gid)
                x += 0.1
                y += 0.1
                gid = gather_coords(x,y)
                puts "\t\t\tshifting x,y by 0.1"
              end
              storage[zoneID][gid] = val
            end
          else
            storage[zoneID][gid] = val
          end
        end
      end
    rescue Exception => e
      passed = false
      puts "Exception processing wowdbd data for #{variable} cause: #{e}"
    end
  end
  if passed then
    puts "Processed #{count} nodes in #{((Time.now).to_i-start.to_i) } seconds for #{variable}"
    file = File.new(data_file,modestring="w")
    file << "#{variable} = "
    file << storage.to_lua
    file.close
  else
    puts "Failed to fully process #{variable}, skipping update"
  end
  return count
end

db = WoWDBMaps.new
start_time = Time.now
# load up all lists
db.get_mineral_list
db.get_herb_list
count = 0
count += create_saved_vars("MiningData.lua",db,mineral_map,"GatherMateDataMineDB")
count += create_saved_vars("HerbalismData.lua",db,herb_map,"GatherMateDataHerbDB")
count += create_saved_vars("TreasureData.lua",db,treasure_map,"GatherMateDataTreasureDB")

####
## Manual Map Processing for Gas Clouds
## Staticly adding gas clouds as reported on Wowhead
####
gas_start = Time.now
gases = Hash.new
gas_sv_file = File.new("GasData.lua", modestring="w")
gas_sv_file << "GatherMateDataGasDB = "
count4 = 0
# windy cloud
count4 += process_mapline("284611580780620760220340490660300590340270300620563436659555542225250281384308409244518217541242625394571471641462704433686652512299453596361811593714702522338394519829672770645669676590651590287366310667428526322629551644610646720652418293722697492302655640265423496275681565476380373256680619650739313260595417",21,301,gases) 
#Arcane vortex
count4 += process_mapline("568330401619430751518600531871643580699440332652492184238425231768384766408687332601272588301382457252588339610374724394411524422568514532562570616582633601654594617633580803536266397316646363458180410254720351663514511557341545309434405166630485608345579460306407660304297530",56,303,gases)
#felmist
count4 += process_mapline("614587614592613583568460466470570461522210525222384419389420642466634466646471640474642470638474518208467521471535581455495330420426469537214327533341349344622631649612466378430490560540300450620374542506450380350450280360431729570190328378342412",47,304,gases)
#swamp gas
count4 += process_mapline("580520650730590350240560160200437533460580302504607549329309090510280240300210310320320380340420381589450560630660750830780790850490160240330621601530826726844312713347269359270433650685119458415584808792402623382631603462281481132621185687673658866458388520",58,302,gases)
gas_sv_file << gases.to_lua
gas_sv_file.close
puts "Processed #{count4} nodes in #{((Time.now).to_i-gas_start.to_i) } seconds for GatherMateDataGasDB"
puts "Total nodes processed: #{count + count4}, executed in #{Time.now.to_i - start_time.to_i} seconds"