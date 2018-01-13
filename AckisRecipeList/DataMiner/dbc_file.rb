# Format values:
# 's' string offset pointer
# 'f' float
# 'F' signed float
# 'i' unsigned int
# 'I' signed int
# 'b' byte
# 'x' 4 byte value unkown format
class DBCFile
  def initialize(file,format)
    @records = Array.new
    io = File.open(file)
    io.binmode
    load(io,format)
  end
  def load(io,format)
    header = io.read(4)
    if not header.eql?("WDBC") 
      raise "Invalid file!"
    end
    @record_count = io.read(4).unpack("i")[0]
    field_count = io.read(4).unpack("i")[0]
    record_size = io.read(4).unpack("i")[0]
    string_size = io.read(4).unpack("i")[0] 
    strings = Hash.new
    field_types = Array.new
    format.scan(/./m) do |x| field_types << x end
    if field_types.length != field_count
      raise "Format mismatch! Found #{field_count} but only #{field_types.length} provided."
    end
    @records = Array.new()
    for i in 0..(@record_count-1)
      @records[i] = Array.new
      for y in 0..(field_count-1)
        if field_types[y].eql?("s")
          @records[i][y] = io.read(4)
          if not @records[i][y].nil?
            @records[i][y] = @records[i][y].unpack("i")[0]
          end
        end
        if field_types[y].eql?("x")
           @records[i][y] = io.read(4)
        end
        if field_types[y].eql?("i") or field_types[y].eql?("n")
          @records[i][y] = io.read(4)
          if not @records[i][y].nil?
            @records[i][y] = @records[i][y].unpack("I")[0]
          end
        end
        if field_types[y].eql?("I")
          @records[i][y] = io.read(4)
          if not @records[i][y].nil?
            @records[i][y] = @records[i][y].unpack("i")[0]
          end
        end
        if field_types[y].eql?("f")
          @records[i][y] = io.read(4)
          if not @records[i][y].nil?
            @records[i][y] = @records[i][y].unpack("F")[0]
          end
        end
        if field_types[y].eql?("F")
          @records[i][y] = io.read(4)
          if not @records[i][y].nil?
            @records[i][y] = @records[i][y].unpack("f")[0]
          end
        end
        if field_types[y].eql?("b")
          @records[i][y] = io.read(1)
        end
      end
    end
    # read the string table out
    # trim the leading \0 out io.read(1)
    offset = 0
    while not io.eof?
      m = read_string(io)
      strings[offset] = m 
      offset += m.length + 1
    end
    # consolidate the data via format info
    @records.each do |r|
      for y in 0..(field_count-1)
        if field_types[y].eql?("s")
          r[y]=strings[r[y]]
        end
      end
    end
  end
  def length()
    return @record_count
  end
  def each
    @records.each do |r|
      yield r
    end
  end
  def get_record(id)
    return @records[id]
  end
  private
  def read_string(io)
    c = ""
    string = ""
    begin 
      c = io.read(1)
      if c != "\0"
        string = string + "#{c}"
      end
    end while c != "\0"    
    return string
  end
end
