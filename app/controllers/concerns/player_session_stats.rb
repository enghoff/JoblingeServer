class PlayerSessionStats
  include DateFormats
  include Virtus.model
  attribute :user, User
  attribute :grouped_by

  GROUPED_BY_OPTIONS = {
    days:   "group_by_day",
    weeks:  "group_by_week",
    months: "group_by_month",
    years:  "group_by_year",
  }.with_indifferent_access

  def grouped_by=(grouped_by)
    @grouped_by = GROUPED_BY_OPTIONS.has_key?(grouped_by) ? grouped_by.to_sym : :weeks
  end

  def total_times
    @total_times ||= user.player_sessions.count
  end

  def total_time_played
    seconds_to_hours_and_minutes(total_time_played_in_seconds)
  end

  def average_time_per_session
    timespan = total_times > 0 ? total_time_played_in_seconds/total_times.to_f : 0
    seconds_to_hours_and_minutes(timespan)
  end

  def last_session_time_played
    if last_session
      seconds_to_hours_and_minutes(last_session.duration_in_seconds)
    else
      "-"
    end
  end

  def first_time_played_at
    if first_session
      date_format(first_session.started_at)
    else
      "-"
    end
  end

  def last_time_played_at
    if last_session
      date_format(last_session.finished_at)
    else
      "-"
    end
  end

  def last_session
    @last_session ||= user.player_sessions.order(finished_at: :desc).first
  end

  def first_session
    @first_session ||= user.player_sessions.order(started_at: :asc).first
  end

  def total_time_played_in_seconds
    @total_time_played_in_seconds ||= user.player_sessions.sum(:duration_in_seconds)
  end

  def session_groups
    # binding.pry
    @session_groups ||= PlayerSessionGroups.new(user:user, grouped_by:grouped_by)
  end

  class PlayerSessionGroups
    include DateFormats
    include Virtus.model
    attribute :user, User
    attribute :grouped_by

    def each # |date, number_of_times, timespan|
      return enum_for(:each) unless block_given?
      session_groups.each do |date, data|
        yield formated_date(date), data.first, data.second
      end
    end

    private

    def formated_date(date)
      case grouped_by
      when :days
        date_day_format(date)
      when :weeks
        date_week_format(date)
      when :months
        date_month_format(date)
      when :years
        date.year
      end
    end

    def session_groups
      @session_groups ||= begin
        session_times_groups.inject({}) do |h, (date, times)|
          if times > 0
            h[date] = []
            h[date].push times
            h[date].push seconds_to_hours_and_minutes( session_minutes_groups[date] )
          end
          h
        end
      end
    end

    def session_times_groups
      @session_times_groups ||= user
        .player_sessions
        .send(GROUPED_BY_OPTIONS[grouped_by], :started_at)
        .reverse_order
        .count
    end

    def session_minutes_groups
      @session_minutes_groups ||= user
        .player_sessions
        .send(GROUPED_BY_OPTIONS[grouped_by], :started_at)
        .reverse_order
        .sum(:duration_in_seconds)
    end
  end

end
