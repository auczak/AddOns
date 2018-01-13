require "core"
require "net/http"
=begin rdoc
 Some WoWDB constants
 NPC types:
  1 - Beast
  2 - Dragonkin
  3 - Demon
  4 - Elemental
  5 - Giant
  6 - Undead 
  7 - Humanoid
  8 - Critter
  9 - Mechanical
  10 - Unknown
  11 - Totem
  12 - Non Combat Pet
  13 - Gas Cloud
 Rarity levels:
  5 - Legendary
  4 - Epic
  3 - Rare
  2 - Uncommon
  1 - Common
 NPC Classifications:
  1 - Elite
  3 - Boss
  4 - Rare
 Reaction Types:
  0 - Unknown
  1 - Hated
  2 - Neutral
  3 - Friendly
 Quest Sides:
  1 - Both
  2 - Alliance
  4 - Horde
 Quest Types:
  0 - normal
  62 - Raid
  60 - PVP
  81 - Dungeon
  Item Stat IDs:
  1 - Strength
  2 - Agility
  3 - Stamina
  4 - Intellect
  5 - Spirit
  6 - Armor
  19 - Secondary damage/healing
  20 - Damage and Healing
  21 - Spell Hit
  22 - Spell Crit
  33 - Fire Resist
  
  
=end
module WoWDBHelper
  include JsonHelper
  def search_list(search_id)
    response = Net::HTTP.get(URI.parse("http://www.wowdb.com/search.aspx?browse=#{search_id}"))
    unless response
      raise "Data not available for #{search_id}"
    end
    lst = response.scan(/cg_json_1=(.*);/).first
    if lst.nil?
      raise "No search results found"
    end
    data = lst.first
    return from_json(data)
  end
  def parse_html_response(response)
    if response.nil?
      return nil
    end
    cgData = get_tooltips(response)
    jsData = get_json_items(response)
    tabs = get_tabs(response)
    return cgData,jsData,tabs
  end
  # ask the website for an item
  # return an array Tooltips,Json_items,Tabs
  def get_item_data(item_id)
    response = Net::HTTP.get(URI.parse("http://www.wowdb.com/item.aspx?id=#{item_id}"))
    return parse_html_response(response)
  end
  # ask the website for a spell
  # return an array Tooltips,Json_items,Tabs
  def get_spell_data(spell_id)
    response = Net::HTTP.get(URI.parse("http://www.wowdb.com/spell.aspx?id=#{spell_id}"))
    return parse_html_response(response)
  end
  # Get the json data objects form a response
  def get_json_items(response)
    json_data = Hash.new
    items = response.scan(/(cg_json_\d)=(.*);/)
    unless items.nil?
      items.each do |item|
        json_data[item[0]] = from_json(item[1])
      end
    end
    return json_data
  end
  # get teh tab data forma response
  def get_tabs(response)
    data = []
    response.gsub!(/;/,";\n")
    tabs = response.scan(/DataGrid\((.*)\);/)
    unless tabs.nil?
      tabs.each do |tabd|
        tab = tabd.first
        tab.gsub!(/cg_primaryTabGroup/,"'cg_primaryTabGroup'")
        tab.gsub!(/Curse.DataGrid.Utility.processCounts/,"'preprocess'")
        tab.gsub!(/cg_json_(.)/,'\'cg_json_\1\'')
        tab.gsub!(/cg_comments(.)/,'\'cg_comments\'\1')
        tab.gsub!(/cg_screenshots(.)/,'\'cg_screenshots\'\1')
        tab.gsub!(/\[\,/,"[")
        data << from_json(tab)
      end
    end
    return data
  end
  
  # find all tooltips in the response
  def get_tooltips(response)
    response.gsub!(/\[\,/,"[")
    data_line = response.scan(/cg_items.addData\((.*)\);/).first
    cgData = {}
    unless data_line.nil?
      data_line = from_json(data_line.first)
      # check for specialities
      data_line.each do |line|
        #puts "Processing line #{line.inspect}"
        if line.has_key?(:id) and line.has_key?(:tooltip)
          cgData[line[:id]] = line[:tooltip]
          cgData["#{line[:id]}_stats"] = line[:stats]
        end
      end
    end
    return cgData    
  end
end