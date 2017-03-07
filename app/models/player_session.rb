class PlayerSession < ActiveRecord::Base
  belongs_to :user

  before_save :set_duration

  validate :valid_time_range

  private

  def valid_time_range
    set_duration
    self.errors.add(:base, "invalid time range") unless self.duration_in_seconds > 0
  end

  def set_duration
    self.duration_in_seconds = self.finished_at.to_i - self.started_at.to_i rescue 0
  end

end
