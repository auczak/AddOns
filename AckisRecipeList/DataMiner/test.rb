require "core"
require "wowdb_maps"
require "wowdb_recipes"
require "wowdb_pets_and_mounts"
require "wowdb_factions"

class Test
  include JsonHelper
  def doit(d)
    from_json(d)
  end
end
$testmaps = false
$testrecipes = true
$testpets = false
$testdbc = false
$test_factions = false
d = Test.new()


if $testmaps
# Azermist isle mape data
f = File::open("wowdb-mapdata.txt")
m = f.read()
tbl = d.doit(m)
puts tbl[0][:mapLabel]
end

# Elixir of wisdom
if $testrecipes
r = File.open("recipe-list.txt")
n = r.read()
mbl = d.doit(n)
puts "#{mbl[20].inspect}"
end
# For RIGHT NOW not adding the dbc parser till can be discussed.
# require "dbc_file"
# test DBCFile and generate width,height for Silithus
# NOTE: test requires you to adjust the path to the dbc file, as this is copyright blizz and not
# able to check it into src control
if $testdbc
require "dbc_file"
d = DBCFile.new("/Users/washu/Downloads/WorldMapArea-2.dbc","iiisffffI")
r = d.get_record(40)
puts "#{r[3]} = {#{(r[5].to_f - r[4].to_f).abs},#{(r[7].to_f-r[6].to_f).abs}},"
end
# test wowdb map base class, handles herbs, minerals, pickable chest, normla containers, fish schools
# as list of name ot wowdb ID
if $testmaps
nodes = WoWDBMaps.new
results = nodes.get_map_locations(1617)
puts results["Westfall"].inspect

puts "Testing npc locations"
npc = nodes.get_npc_locations(2412)
puts npc.inspect

nodes.get_raid_maps.each_pair do |id,name|
  puts "Map #{id} is #{name[:name]}"
end
end
if $testrecipes
recipes = WoWDBRecipes.new
maps = WoWDBMaps.new
results = recipes.get_blacksmithing_list
thunder = results['Light Earthforged Blade']
#recipes.add_recipe_details(thunder)
#puts "Light Earthforged Blade: #{recipes.get_speciality('Blacksmithing',thunder[:specialty])} #{thunder[:profession]} #{thunder[:is_weapon]}"

pots = recipes.get_alchemy_list
#dream = pots['Discolored Healing Potion']
#recipes.add_recipe_details(dream)
#puts "Discolored Healing Potion #{dream.inspect}"
#quest_info = maps.get_quest_map_info(dream[:method_quests].first[:id])
#puts "Quest info #{quest_info.inspect}"
#puts "Elixir of Major Shadow Power rarity: #{dream[:recipe_binds]} produces #{dream[:item_binds]} Rarity #{dream[:rarity]}"

eng = recipes.get_tailoring_list
goggles = eng['Frozen Shadoweave Shoulders']
recipes.populate_receipe_details(goggles)
puts "NEW CODE: #{goggles.inspect}"
#recipes.add_recipe_details(goggles)
#puts "Mantle: #{goggles[:profession]} #{goggles[:is_armor]} #{goggles[:armor_slot]} #{goggles[:armor_type]}"

vest = eng['Blue Linen Vest']
#recipes.add_recipe_details(vest)
#puts "Vest #{vest.inspect}"

mining = recipes.get_mining_list
#mining.each_pair do |k,v|
#  puts "Skill #{k}"
#end


cooking = recipes.get_cooking_list
#puts "Cooking #{cooking.size}"

enchants = recipes.get_enchanting_list
#puts "Enchanting count #{enchants.size}"

claw = cooking['Sagefish Delight']
#recipes.add_recipe_details(claw)
#first_vendor = claw[:method_vendors].first
#puts "First vendor #{first_vendor.inspect}"

#mapdata = maps.get_npc_locations(first_vendor[:id])
#puts "First pass #{mapdata.inspect}"
#first_map = mapdata[mapdata.keys[1]]
#puts "First map #{first_map.inspect} avergaed to #{maps.average_location(first_map).inspect}"

jc = recipes.get_jewelcrafting_list
hear = jc['Ornate Tigerseye Necklace']
#recipes.add_recipe_details(hear)

engl = recipes.get_engineering_list
#engl.each_pair do |k,val|
#  puts "Getting details for #{k}"
#  recipes.add_recipe_details(val)
#end
seaform = engl['Small Seaforium Charge']
#recipes.add_recipe_details(seaform)
cgoogle = engl['Deathblow X11 Goggles']
#recipes.add_recipe_details(cgoogle)
#puts "Deathblow X11 Goggles #{cgoogle.inspect}"

philstone = pots['Alchemist\'s Stone']
#recipes.add_recipe_details(philstone)
#puts philstone.inspect

bandaids = recipes.get_firstaid_list
#bandaids.each_pair do |k,v|
#recipes.add_recipe_details(v)
#puts "Bandage: #{k} is #{v[:recipe_binds]} produces #{v[:item_binds]} Rarity #{v[:rarity]}"
#end


end

if $testpets
  list = WoWDBPetsAndMounts.new
  pets = list.get_pet_list
  data = pets['Lifelike Mechanical Toad']
  #pets.each_pair do |name,data|
    list.add_item_details(data)
    puts "Pet: #{data.inspect}"
  #end
  #pdata = pets['Dragon Kite']
  #list.add_item_details(pdata)
  #puts "\nPet: #{pdata.inspect}\n\n"
  mounts = list.get_mount_list
  data = mounts['Reins of the Veridian Netherwing Drake']
  #mounts.each_pair do |name,data|
  list.add_item_details(data)
  puts "Mount: #{data.inspect}"
  questonly = mounts['Black Qiraji Resonating Crystal']
  list.add_item_details(questonly)
  puts "Mount: #{questonly.inspect}"
  #end
end
if $test_factions
  # Get the list of reputations 	 
  	factions = WoWDBFactions.new 
  	reputations = factions.get_faction_list   	  
    reputations.keys.sort_by {|k|reputations[k] = reputations[k][:id];reputations[k]}.each do |k|
      puts "Faction: (#{reputations[k]}) #{k}"  
    end
end