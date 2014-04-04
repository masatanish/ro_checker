require 'ro_checker/cfb/header'
require 'ro_checker/cfb/sector'
require 'ro_checker/cfb/directory'
require 'ro_checker/cfb/io'

module RoChecker
  class CFB
    def self.read(data)
      CFB.new(data)
    end

    def self.read_from_path(path)
      raise IOError, "file is not found: #{path}" unless File.exist?(path)
      self.read(File.read(path))
    end

    attr_reader :header
    attr_reader :io
    attr_reader :directories

    def initialize(data)
      @io = CFB::IO.new(data)
      @header = Header.new(@io)
      @difats = []
      @io.pos=76
      # ugh! temporary, need consider difat array is larger than 109
      while (fat_location = @io.read_int) != Sector::FREESECT do
        @difats << fat_location
      end
      read_fats()
      read_directory_entries()
    end

    def sector_num
      return (@io.size / @io.sector_size) - 1
    end

    def read_fats
      @fats = []
      fatdata = @io.read_sectors(@difats)
      f = @io.endian == :little ? 'V*' : 'N*'
      @fats = fatdata.unpack(f)
      # delete not used data
      #@fats.pop while @fats.last == Sector::FREESECT 
      @fats = @fats[0...sector_num]
    end

    def read_directory_entries
      @directories = []

      dir_sectors = sectors(@header.first_dir_sec_loc)
      tmp_io = @io.read_sectors_as_io(dir_sectors)
      until tmp_io.eof? do
        @directories << CFB::Directory.new(tmp_io)
      end
      while (@directories.last.entry_name.nil? and @directories.last.obj_type == :unknown) do
        @directories.pop
      end
      tmp_io.close
    end

    def sectors(location)
      s = location
      sec_arr = []
      until s == Sector::ENDOFCHAIN or s == Sector::FREESECT do
        sec_arr << s
        s = @fats[s]
      end
      sec_arr
    end

    def sector_num
      return (@io.size / @io.sector_size) - 1
    end

    def num_fat_entry
      @fats.size
    end

    def file_size
      @io.size
    end
  end
end

