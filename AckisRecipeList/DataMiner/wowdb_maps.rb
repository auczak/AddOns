require "wowdb_helper"

#
# Please note for any given 'list' max returned items is 200
#
class WoWDBMaps
  include JsonHelper
  include WoWDBHelper
  def initialize()
    @@herbs = Hash.new
    @@minerals = Hash.new
    @@containers = Hash.new
    @@pickable = Hash.new
    @@fishes = Hash.new
    @@npcs = Hash.new
  end
  def get_fish_list
    # Fish schools http://www.wowdb.com/search.aspx?browse=5.25
    if @@fishes.length == 0
      fish = search_list("5.25")
      fish.each do |h|
          @@fishes[h[:name]] = h[:id]
      end      
    end
    return @@fishes
  end
  def get_pickable_list
    # Pickable http://www.wowdb.com/search.aspx?browse=5.-3
    if @@pickable.length == 0
      picks = search_list("5.-3")
      picks.each do |h|
        if not h[:skill].nil? and h[:skill] > 0
          @@pickable[h[:name]] = h[:id]
        end
      end      
    end
    return @@pickable
  end
  def get_container_list
    #http://www.wowdb.com/search.aspx?browse=5.3
    if @@containers.length == 0
      chests = search_list("5.3")
      chests.each do |h|
        if not h[:locs].nil?
          @@containers[h[:name]] = h[:id]
        end
      end      
    end
    return @@containers
  end
  # return the full list of herbs you can pick
  def get_herb_list
    # Herb http://www.wowdb.com/search.aspx?browse=5.-2
    if @@herbs.length == 0
      herbs = search_list("5.-2")
      herbs.each do |h|
        if not h[:skill].nil? and h[:skill] > 0
          @@herbs[h[:name]] = h[:id]
        end
      end      
    end
    return @@herbs
  end
  # return a full list of nodes you can mine
  def get_mineral_list
    # Mineral http://www.wowdb.com/search.aspx?browse=5.-1
    if @@minerals.length == 0
      minerals = search_list("5.-1")
      minerals.each do |m|
        if not m[:skill].nil? and m[:skill] > 0
          @@minerals[m[:name]] = m[:id]
        end
      end
    end
    return @@minerals
  end
  
  def get_maps(object_name)
    if @@herbs.has_key?(object_name)
      return get_map_locations(@@herbs[object_name])
    end
    if @@minerals.has_key?(object_name)
        return get_map_locations(@@minerals[object_name])
    end
    if @@containers.has_key?(object_name)
        return get_map_locations(@@containers[object_name])
    end
    if @@pickable.has_key?(object_name)
        return get_map_locations(@@pickable[object_name])
    end
    if @@fishes.has_key?(object_name)
        return get_map_locations(@@fishes[object_name])
    end
    raise "Maps not found for #{object_name} either you mis-spelled the name or you have fetched the list yet"
  end
  def get_dungeon_maps
     return search_list("3.3")
     maps = {}
     list.each do |entry|
       maps[entry[:id]] = entry
     end
     return maps
  end
  def get_raid_maps
    list = search_list("3.4")
    maps = {}
    list.each do |entry|
      maps[entry[:id]] = entry
    end
    return maps
  end
  def get_quest_map_info(quest_id)
    response = Net::HTTP.get(URI.parse("http://www.wowdb.com/quest.aspx?id=#{quest_id}"))
    unless response
      raise "Data not available for quest #{quest_id}"
    end
    lst = response.scan(/<script>addMapLocations\((.*)\)<\/script>/).first
    if lst.nil?
      raise "No map data for #{quest_id}"
    end
    mapdata = from_json(lst.first)
    zone= []
    starting_npc = response.match(/Starting NPC: <a href=\"npc.aspx\?id=(\d+)\">/)
    unless starting_npc.nil? or starting_npc.length == 0
      starting_npc = starting_npc[1].to_i
    else
      starting_npc = 0
    end    
    ending_npc = response.match(/Finishing NPC: <a href=\"npc.aspx\?id=(\d+)\">/)
    unless ending_npc.nil? or ending_npc.length == 0
      ending_npc = ending_npc[1].to_i
    else
      ending_npc = 0
    end
    
    mapdata.each do |entry|
      zone << entry[:mapLabel]
    end
    return {:quest_zones => zone, :quest_starter => starting_npc, :quest_finisher=> ending_npc}
  end
  
  def get_npc_locations(npc_id)
    if @@npcs.has_key?(npc_id)
      return @@npcs[npc_id]
    end
    response = Net::HTTP.get(URI.parse("http://www.wowdb.com/npc.aspx?id=#{npc_id}"))
    unless response
      raise "Data not available for object #{npc_id}"
    end
    lst = response.scan(/<script>addMapLocations\((.*)\)<\/script>/).first
    if lst.nil?
      raise "No map data for #{npc_id}"
    end
    data = from_json(lst.first)
    # sort data into a map
    results = Hash.new
    data.each do |entry|
      zone = entry[:mapLabel]
      coords = entry[:coords]
      coords.each do |coordset|
        coordset.delete_if do |record|
          record.kind_of?(String)
        end
      end
      results[zone] = coords
    end
    @@npcs[npc_id] = results
    return results
  end
  def average_location(locations)
    if locations.length == 0
      return [0,0]
    end
    x, y = 0,0
    locations.each do |entry|
      x = x + entry[0]
      y = y + entry[1]
    end
    return [x/locations.length,y/locations.length]
  end
  # returns a Has keyed by Zone name, containing an array of coord arrays
  def get_map_locations(object_id)
    response = Net::HTTP.get(URI.parse("http://www.wowdb.com/object.aspx?id=#{object_id}"))
    unless response
      raise "Data not available for object #{object_id}"
    end
    lst = response.scan(/<script>addMapLocations\((.*)\)<\/script>/).first
    if lst.nil?
      raise "No map data for #{object_id}"
    end
    data = from_json(lst.first)
    # sort data into a map
    results = Hash.new
    data.each do |entry|
      zone = entry[:mapLabel]
      coords = entry[:coords]
      coords.each do |coordset|
        coordset.delete_if do |record|
          record.kind_of?(String)
        end
      end
      results[zone] = coords
    end
    return results
  end
  
  private
  # private method to generate the list of herbs and mineral veins
  # once fishing nodes and/or gas clouds are added to wowdb this will
  # be expanded.
end