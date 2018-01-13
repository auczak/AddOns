require "core"
require "dbc_file"

# This class assumes WRATH data
# sample on extending dbcfile for re-manipulation of data
class WorldMapArea < DBCFile
  # Fied info
  # 0: ID
  # 1: map id
  # 2: area id
  # 3: Name
  # 4: y1
  # 5: y2
  # 6: x1
  # 7: x2
  # 8: virtualID
  def initialize(path)
      super("#{path}#{File::SEPARATOR}WorldMapArea.dbc","iiisffffII")
  end
  def get_zone_data()
    zone_info = Hash.new
    #Fields are 0 indexed
    @records.each do |record|
      zone_info[record[3]] = {:ulY => record[4], 
        :lrY => record[5], 
        :ulX => record[6], 
        :lrX => record[7], 
        :width => (record[5].to_f - record[4].to_f).abs,
        :height => (record[7].to_f-record[6].to_f).abs,
        :mapid => record[2]
        }
    end
    return zone_info
  end
end

# Cmdline Usage
if ARGV.nil? 
  puts "Usage: #{$0} <path to dbc files>"
  exit(0)
end
path = ARGV[0]
unless File.directory?(path)
  puts "Usage: #{$0} <path to dbc files>"
  exit(0)  
end

zoneData = WorldMapArea.new("#{path}") 
puts zoneData.get_zone_data.to_lua