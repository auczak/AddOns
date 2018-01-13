require "wowdb_helper"

class WoWDBFactions
  include JsonHelper
  include WoWDBHelper
  
  def initialize()
    @@factions = Hash.new
  end
  def get_faction_list
    if @@factions.length == 0
      map = search_list("8")
      cleanup_list(map,@@factions)
    end
    return @@factions
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