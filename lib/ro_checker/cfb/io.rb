require 'stringio'

class Time
  def self.filetime_to_time(filetime)
    Time.at((filetime - 116444556000000000) / 10000000)
  end
end

module RoChecker
  class CFB
    class IO < StringIO
      attr_reader :endian, :sector_size

      def initialize(data, endian=:little)
        super(data)
        self.endian = endian
        self.sector_size = 0x200
      end

      def endian=(endian)
        @endian = endian == :big ? :big : :little
      end

      def sector_size=(size)
        @sector_size = (size == 0x1000 ? 0x1000 : 0x200)
      end

      def read_byte(times=1)
        raise ArgumentError, "invalid times: #{times}" if times < 1
        result = self.read(1*times).unpack('C'*times)
        return (times == 1 ? result.first : result)
      end

      def read_short(times=1)
        raise ArgumentError, "invalid times: #{times}" if times < 1
        f = @endian == :little ? 'v' : 'n'
        result = self.read(2*times).unpack(f*times)
        return (times == 1 ? result.first : result)
      end

      def read_int(times=1)
        raise ArgumentError, "invalid times: #{times}" if times < 1
        f = @endian == :little ? 'V' : 'N'
        result = self.read(4*times).unpack(f*times)
        return (times == 1 ? result.first : result)
      end

      def read_int64
        f = @endian == :little ? 'V' : 'N'
        result = self.read(8).unpack(f*2)
        if @endian == :little
          return result[0] + (result[1]<<32)
        else
          return result[1] + (result[0]<<32)
        end
      end

      def read_filetime
        Time.filetime_to_time(self.read_int64)
      end

      def read_sectors(index) # need consider sector chain
        index = [index] unless index.is_a?(Array)
        data = index.map do |sec|
          self.pos = (sec+1) * @sector_size
          self.read(@sector_size)
        end
        data.join('')
      end

      def read_sectors_as_io(index)
        CFB::IO.new(read_sectors(index), @endian)
      end
    end
  end
end
