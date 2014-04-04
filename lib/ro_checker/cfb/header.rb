require 'stringio'

module RoChecker
  class CFB
    class Header
      SIGNATURE = [0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1].pack("c*")

      attr_reader :minor_version, :major_version, :byte_order
      attr_reader :sector_shift, :mini_sector_shift, :num_dir_sec
      attr_reader :num_fat_sec, :transation_sig_num
      attr_reader :first_dir_sec_loc, :mini_stream_cutoff_size
      attr_reader :first_mini_fat_sec_loc

      def initialize(io)
        @int_keys = [
          :@num_dir_sec,
          :@num_fat_sec,
          :@first_dir_sec_loc,
          :@transation_sig_num,
          :@mini_stream_cutoff_size,
          :@first_mini_fat_sec_loc,
          :@num_mini_fat_sec,
          :@first_difat_sec,
          :@num_difat_sec
        ]
        parse(io)
      end

      # little endian is expected.
      def parse(io)
        sig = io.read(8)
        raise "not CFB header" unless sig == SIGNATURE
        cls_id = io.read(16) # not used

        @minor_version = io.read_short
        @major_version = io.read_short
        order = io.read(2).unpack('C*')
        @byte_order = [0xff, 0xfe] == order ? :big: :little
        io.endian = @byte_order

        @sector_shift = 2**io.read_short
        io.sector_size = sector_shift
        @mini_sector_shift = 2**io.read_short
        io.read(6) # reserved area
        @int_keys.each do |k|
          instance_variable_set(k, io.read_int)
        end
      end
      private :parse

      def inspect
        string = "#<#{self.class.name}:#{self.object_id}\n "
        fields =[]
        fields << "@minor_version=%2d(%#06x)" % [@minor_version, @minor_version]
        fields << "@major_version=%2d(%#06x)" % [@major_version, @major_version]
        fields << "@byte_order=:#{@byte_order}"
        fields << "@sector_shift=%d(%#06x)" % [@sector_shift, @sector_shift]
        fields << "@mini_sector_shift=%d(%#06x)" % [@mini_sector_shift, @sector_shift]
        fields += @int_keys.map{|k| v=instance_variable_get(k);"#{k}=%d(%#010x)" % [v,v] }
        string + fields.join(",\n ") + ">"
      end
    end
  end
end
