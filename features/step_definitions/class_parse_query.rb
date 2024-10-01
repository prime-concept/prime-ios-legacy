# This class solves the validation problem of grouped data.
# The grouped data is given to object as an array
# Each array element is a hash with data property name and value
# For example, to validate Request with icon, title, details and "more info" button
# following array is given to object.set_array method
# [
#   {"class" => "UIImageView", "id" => "avia"},
#   {"class" => "UILabel", "label" => "NewYork - Paris"},
#   {"class" => "UILabel", "label" => "рейс BA 237, 27.06.2015 21:50, LHR терминал 5"},
#   {"class" => "UIButton", "label" => "More Info"}
# ]
require 'json'

class ParseQuery

  def initialize(q)
    @query = q
    @query_size = @query.size
    flush_class_variables
  end

  def flush_class_variables
    @is_debug=false
    @part_is_found = false
    @pattern_is_found = false
    @pattern_found_count = 0
    @j = 0
    @max_found = 0
    @msg = ''
    @ignored_classes = Array.new
    @wanted_object = Hash.new
    @found_indexes = Array.new
  end

  def set_array(a)
    @flush_class_variables
    @array = a
    @array_size = @array.size
  end

  def set_ignore_classes(a)
    @ignored_classes = a
  end

  def array_line_match
    @array[@j].each do |key, value|
      return false unless @query[@i].key?(key)
      return false if @query[@i][key].to_s != @array[@j][key].to_s
    end
    @found_indexes.push(@i)
    true
  end

  def array_next_element
    @j = @j + 1
    @max_found = @j if @j > @max_found
  end

  def reset_array_index
    @j = 0
  end

  def reset_found_index
    @found_indexes = Array.new
  end

  def full_array_is_found
    @pattern_is_found = true
    @pattern_found_count += 1
    reset_array_index
  end

  def parse_data
    @query_size.times do |index|
      @i = index

      next if @ignored_classes.include?(@query[@i]['class'])

      unless array_line_match then
        reset_array_index
        reset_found_index
        next
      end

      array_next_element

      if @j == @array_size then
        full_array_is_found
      end

      return true if is_pattern_found
    end
    return false
  end

  def find_object
    if is_pattern_found then
      @found_indexes.each do |fi|
        @wanted_object.each_with_index do |hash_as_array, idx|
          key = hash_as_array[0]
          value = hash_as_array[1]
          break unless @query[fi].key?(key)
          break if @query[fi][key].to_s != value.to_s
          return @query[fi] if idx == @wanted_object.size - 1
        end
      end
    end
  end

  def is_pattern_found
    @pattern_is_found
  end

  def how_many_patterns_found
    @pattern_found_count
  end

  def parse(a)
    set_array(a)
    parse_data
    is_pattern_found
  end

  def get_object(w)
    @wanted_object = w
    parse_data
    find_object
  end

  def get_query
    @query
  end

  def parse_and_verify(a)
    set_array(a)
    parse_data
    raise("Following object didn't found on the screen: #{a}") unless @pattern_is_found
    is_pattern_found
  end

  def print_full_status
    unless is_pattern_found then
      @msg += "\nMISMATCH: Unable to find block ["+@max_found.to_s+'] from this group:'
      (0..@array_size-1).each do |id|
        @msg += "\n["+id.to_s+"] "+@array[id].to_s
      end
      @msg += "\n"
      return @msg
    end
  end

  def print_query_to_file(filePath)
    outDir = "output"
    create_directory_if_missing(outDir)
    outFilePath = File.join(outDir, filePath)
    f = File.new(outFilePath, 'w')
    f.write(JSON.pretty_generate(@query))
    f.close
    @msg = 'Export file: ' + outFilePath
  end
end
