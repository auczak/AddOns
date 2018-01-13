require "wowdb_helper"

class WoWDBPetsAndMounts
  include JsonHelper
  include WoWDBHelper
  def initialize()
    @@pets = Hash.new
    @@mounts = Hash.new
  end
  def get_mount_list
    if @@mounts.length == 0
      map = search_list("1.15.-1")
      cleanup_list(map,@@mounts)
    end
    return @@mounts
  end
  def get_pet_list
    if @@pets.length == 0
      map = search_list("1&filters=146=Right%20Click%20to%20summon%20and%20dismiss")
      cleanup_list(map,@@pets)
    end
    return @@pets
  end
  def add_item_details(recipe_object)
    response = Net::HTTP.get(URI.parse("http://www.wowdb.com/item.aspx?id=#{recipe_object[:id]}"))      
    unless response
      raise "No recipe data found for #{recipe_object[:id]}"
    end
    #data_line = response.scan(/cg_items.addData\((.*)\);/).first
    tooltips = get_tooltips(response)
    if tooltips[recipe_object[:id]]
      tooltip = tooltips[recipe_object[:id]]
      spell_id = tooltip.match(/spell.aspx\?id=(\d+)/)
      if spell_id and spell_id.length > 0
        recipe_object[:spell_id] = spell_id[1].to_i
      end
    end
    # check for type
    recipe_object[:method] = ""
    json_data = Hash.new
    if response.include?("cg_json_1")
      json_data["cg_json_1"] = from_json(response.scan(/cg_json_1=(.*);/).first.first)
    end
    if response.include?("cg_json_2")
      json_data["cg_json_2"] = from_json(response.scan(/cg_json_2=(.*);/).first.first)
    end
    if response.include?("cg_json_3")
      json_data["cg_json_3"] = from_json(response.scan(/cg_json_3=(.*);/).first.first)
    end
    if response.include?("cg_screenshots")
      json_data["cg_screenshots"] = from_json(response.scan(/cg_screenshots=(.*);/).first.first)
    end
    response.gsub!(/;/,";\n")
    #puts "RESPONSE #{response}"
    tabs = response.scan(/DataGrid\((.*)\)/)
    unless tabs.nil?
      tabs.each do |tabd|
        tab = tabd.first
        tab.gsub!(/cg_primaryTabGroup/,"'cg_primaryTabGroup'")
        tab.gsub!(/Curse.DataGrid.Utility.processCounts/,"'preprocess'")
        tab.gsub!(/cg_json_(.)/,'\'cg_json_\1\'')
        tab.gsub!(/cg_comments(.)/,'\'cg_comments\'\1')
        tab.gsub!(/cg_screenshots(.)/,'\'cg_screenshots\'\1')
        tab = from_json(tab)
        tab[:id].downcase!
        tab[:template].downcase!
        # Trainers
        if tab[:id].eql?("taught-by") and tab[:template].eql?("npcs")
          recipe_object[:method] += "#{tab[:id]},"
          jd = json_data[tab[:data]]
          unless jd.nil?
            recipe_object[:method_trainers] = jd
          end
        end
        # Receipes
        if (tab[:id].eql?("sold-by") and tab[:template].eql?("npcs"))
          jd = json_data[tab[:data]]
          recipe_object[:method] += "#{tab[:id]},"
          recipe_object[:method_vendors] = jd
          # method source now has another array with the actual receipe id for later lookup
        end
        if (tab[:id].eql?("dropped-by") and tab[:template].eql?("npcs")) or (tab[:id].eql?("contained-in-object") and tab[:template].eql?("objects")) or (tab[:id].eql?("contained-in-item") and tab[:template].eql?("items"))
          jd = json_data[tab[:data]]
          recipe_object[:method] += "#{tab[:id]},"
          recipe_object[:method_drops] = jd
          # method source now has another array with the actual receipe id for later lookup
        end        
        # Quests
        if tab[:id].eql?("rewardfrom") and (tab[:template].eql?("quest") or tab[:template].eql?("quests"))
          jd = json_data[tab[:data]]
          recipe_object[:method] += "#{tab[:id]},"
          recipe_object[:method_quests] = jd
          # method source now has another array with the actual receipe id for later lookup
        end
        if tab[:id].eql?("createdby") and tab[:template].eql?("spells")
          jd = json_data[tab[:data]].first
          if not jd[:school].nil?
            recipe_object[:method] += "crafted,"
            recipe_object[:method_crafted] = jd[:id]
          else
            recipe_object[:method] = "redemption,"
            recipe_object[:method_redemption] = jd[:caption]
            if recipe_object[:method_redemption].nil?
              recipe_object[:method_redemption] = "Unknown"
            end
          end
        end        
      end
      unless recipe_object[:method].nil?
        recipe_object[:method].chop!
      end
    end
  end
  
  private
  def cleanup_list(srcMap,dstMap)
    srcMap.each do |src|
      unless dstMap.has_key?(src[:name])
        dstMap[src[:name]] = src
        dstMap[src[:name]].delete(:name)
      end
    end
  end
end

