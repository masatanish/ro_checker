# coding: utf-8
require "ro_checker/version"
require 'ro_checker/cfb'

module RoChecker
  class CFB
    class << self
      def check_from_path(path)
        cfb = CFB.read_from_path(path)
        self.check(cfb)
      end

      def check_from_data(data)
        cfb = CFB.read(data)
        self.check(cfb)
      end

      def check(cfb)
        results = {}
        results[:valid_file_size] = cfb.valid_file_size?
        results[:valid_fat_size] = cfb.valid_fat_size?
        results[:no_freesects_at_tail] = cfb.no_tail_freesect?
        results[:no_unknown_sectors] = cfb.has_no_unknown_sectors?
        results
      end
    end

    # rule2. Invalid File Size
    def valid_file_size?
      return (@io.size % @io.sector_size == 0)
    end

    # rule.3 Invalid FAT References
    # out range of fat
    def valid_fat_size?
      max_sector = (@header.sector_shift / 4 * @header.num_fat_sec)
      return ((max_sector + 1) * @io.sector_size) >= @io.size
    end

    # rule.4 Invalid Free Sector Position
    def no_tail_freesect?
      !(@fats.last == Sector::FREESECT)
    end

    # rule.5 Unreferenced Sectors
    def has_no_unknown_sectors?
      !sector_role.include?(nil)
    end

    def sector_role
      role = []

      @fats.each_with_index do |f, idx|
        role[idx] = case f
                    when Sector::DIFSECT
                      :difat
                    when Sector::FATSECT
                      :fat
                    when Sector::FREESECT
                      :free
                    else
                      nil
                    end
      end

      # directory sections
      dirs = sectors(@header.first_dir_sec_loc)
      dirs.each{|d| role[d] = :directory }
      mini_fats = sectors(@header.first_mini_fat_sec_loc)
      mini_fats.each{|d| role[d] = :mini_fat }

      @directories.each do |dir|
        case dir.obj_type
        when :root
          sectors(dir.sector_location).each{|s| role[s] = :mini_stream }
        else 
          # if stream size is less than cutoff size, the objet is in mini stream.
          unless dir.stream_size < @header.mini_stream_cutoff_size
            sectors(dir.sector_location).each{|s| role[s] = dir.obj_type }
          end
        end
      end
      role
    end
  end
end
