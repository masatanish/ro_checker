
module RoChecker
  class CFB
    class Directory
      OBJECT_TYPE = {
        0x00 => :unknown,
        0x01 => :storage,
        0x02 => :stream,
        0x05 => :root,
      }
      COLOR_FLAG = {
        0x00 => :red,
        0x01 => :black,
      }
      NO_STREAM = 0xffffffff

      attr_reader :entry_name
      attr_reader :obj_type
      attr_reader :sector_location
      attr_reader :stream_size

      def initialize(io)
        parse(io)
      end

      def parse(io)
        name_tmp = io.read(64).encode(Encoding::UTF_8, Encoding::UTF_16LE) # ugh!:endian
        @entry_name_length = io.read_short
        @entry_name = name_tmp[0, (@entry_name_length/2)-1]
        @obj_type = OBJECT_TYPE[io.read_byte]
        @color_flag = COLOR_FLAG[io.read_byte]
        @left = io.read_int
        @right = io.read_int
        @child = io.read_int
        @clsid = io.read(16)
        @state_bits = io.read_int
        @creation_time = io.read_filetime
        @modified_time = io.read_filetime
        @sector_location= io.read_int
        @stream_size = io.read_int64
      end
      private :parse

      def inspect
        string = "#<#{self.class.name}:#{self.object_id}\n "
        fields =[]
        fields << "@entry_name=#{@entry_name.inspect}"
        fields << "@obj_type=#{@obj_type.inspect}"
        keys = [:@child, :@left, :@right]
        fields << keys.map{|k| v=instance_variable_get(k);"#{k}=%#010x" % [v,v] }.join(", ")
        fields << "@sector_location=%d(%#010x)" % [@sector_location, @sector_location]
        fields << "@stream_size=%d(%#010x)" % [@stream_size, @stream_size]
        string + fields.join(",\n ") + ">"
      end
    end
  end
end
