# Helper mixin to convert json to ruby objects
module JsonHelper
  def from_json(json)
      return eval(json.gsub(/(\w*)(\:)\s*([-_'a-z"0-9tfn\[{])/,'\2\1=>\3'))
  end
end
# Lua serializer helper
module LuaHelper
  def ruby_to_lua(v)
    if v=~ /\D+/
      return "\"#{v}\""
    else
      return v
    end
  end
end
# Mixings to Array and Hash to serialize to lua
class Array
  include LuaHelper
  include Enumerable
  def to_lua(depth=1)
    result = "{"
    each {|v|
        if v.instance_of? Array
          result << v.to_lua(depth+1)
        elsif v.instance_of? Hash
          result << v.to_lua(depth+1)
        else
          myval = ruby_to_lua(v)
          result << "\"#{myval}\","
        end
      }
    result << "}\n"
    return result
  end
end
class Hash
  include LuaHelper
  include Enumerable
  def to_lua(depth=1)
    # code here to generate lua out
    result = ("\t" * depth) +"{\n"
    keys.each {|k|
      mykey = ruby_to_lua(k)
      myval = fetch(k)
      if mykey.to_s.length <= 0
        next
      end
      if myval.instance_of? Hash
        result << ("\t" * depth) + "[#{mykey}] = \n" + myval.to_lua(depth+1)
      elsif myval.instance_of? Array
        result << ("\t" * depth) + "[#{mykey}] = \n" + myval.to_lua(depth+1)
      else
        myval = ruby_to_lua(myval)
        result << ("\t" * depth)+ "[#{mykey}] = #{myval},\n"
      end
      }
    comma = ""
    if depth > 1
      comma = ","
    end
    return result << ("\t" * depth) + "}#{comma}\n"
  end
end