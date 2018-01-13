require "core"
require "dbc_file"

# This class assumes WRATH data
# sample on exteiding dbcfile for re-manipulation of data
class Spells < DBCFile
  
  # fields we care about
  # 0: id
  # 124: Spell Name
  # 141: Rank
  def initialize(path)
      super("#{path}#{File::SEPARATOR}Spell.dbc","iiiiiiiiiixiiiiixiiiixxxxiiiiiiiiiiiiiiiiiiifxiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiffffffiiiiiiiiiiiiiiiiiiiiifffiiiiiiiiiiiiiiifffxxxxxxxxxixiixssssssssssssssssxssssssssssssssssxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxiiiiiiixiiixfffxxxiiiiix")
  end
  def print_spell_struct
    record = @records[12]
    i = 0
    record.each do |r|
      puts "#{i} = #{r}"
      i = i + 1
    end
  end
  def get_spell_data()
    spell_info = Hash.new
    #Fields are 0 indexed
    @records.each do |record|
      spell_info[record[0]] = {:name => record[139], :rank => record[156], :id => record[0]}
    end
    return spell_info
  end
end

# Cmdline Usage
if ARGV.length == 0 
  puts "Usage: #{$0} <path to dbc files>"
  exit(0)
end
path = ARGV[0]
unless File.directory?(path)
  puts "Usage: #{$0} <path to dbc files>"
  exit(0)  
end

spellData = Spells.new("#{path}") 
#spellData.print_spell_struct
spells = spellData.get_spell_data
puts "Records found: #{spellData.length}"
puts "Sorting output by spell name, rank"
ordered_keys = spells.keys.sort_by do |id|
  spells[id][:name] + spells[id][:rank]
end
ordered_keys.each do |key|
  puts "#{spells[key][:id]}\t#{spells[key][:name]} (#{spells[key][:rank]})"
end
