module DateFormats
  def date_format(date)
    date ? date.strftime("%d/%b/%Y %R") : "---"
  end

  def date_week_format(date)
    return "---" unless date
    [ date_day_format(date.beginning_of_week), date_day_format(date.end_of_week) ].join(" - ")
  end

  def date_day_format(date)
    date ? date.strftime("%d/%b/%Y") : "---"
  end

  def date_month_format(date)
    date ? date.strftime("%Y %B") : "---"
  end

  def seconds_to_hours_and_minutes(seconds)
    seconds = seconds.to_i
    hours = seconds / (60 * 60)
    minutes = (seconds / 60) % 60
    "#{ hours }h #{ minutes }m"
  end
end
