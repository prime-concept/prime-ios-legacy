# resolve screen size dependancy issue

def fit_to_screen(action)

  w = screen_dimensions[:width]
  case which_iPhone

  when 'iPhone6+'

    case action
    when 'startup_swipe'
      return {:x => 200, :dx => 400}
    when 'calendar_swipe'
      return {:x => 200, :dx => 400}
    end

  when 'iPhone6'

    case action
    when 'startup_swipe'
      return {:x => 150, :dx => 280}
    when 'calendar_swipe'
      return {:x => 150, :dx => 280}
    end

  when 'iPhone5'

    case action
    when 'startup_swipe'
      return {:x => 100, :dx => 180}
    when 'calendar_swipe'
      return {:x => 100, :dx => 250}
    end
  else
    raise "iPhone type '#{which_iPhone}' is not defined"
  end
end

# iPhone screen sizes
def supported_iPhones
  {
    '640x1136'=>'iPhone5',
    '750x1334'=>'iPhone6',
    '1242x2208'=>'iPhone6+'
  }
end

# get current iPhone type by screen sizes
def which_iPhone
  w = screen_dimensions[:width]
  h = screen_dimensions[:height]
  size = "#{w}x#{h}"
  raise "iPhone type is not defined" unless supported_iPhones.include?(size)
  supported_iPhones[size]
end
