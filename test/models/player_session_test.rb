require "test_helper"

describe PlayerSession do

  describe "#duration_in_seconds" do
    it "sets the duration based on the datetimes" do
      started_at  = DateTime.new(2015,01,01)
      finished_at = started_at + 3.hours
      session = PlayerSession.new(started_at: started_at, finished_at: finished_at)
      session.save
      assert_equal session.duration_in_seconds, 3 * 60 * 60
    end
  end

  describe "#valid_time_range" do
    it "only allows time ranges of at least one second" do
      session = PlayerSession.new
      started_at = DateTime.new(2015,01,01)
      assert_error_on( PlayerSession.new, :base )
      assert_error_on( PlayerSession.new(started_at: started_at), :base )
      assert_error_on( PlayerSession.new(started_at: started_at, finished_at: started_at), :base )
      assert_error_on( PlayerSession.new(started_at: started_at, finished_at: started_at - 1.day), :base )
      refute_error_on( PlayerSession.new(started_at: started_at, finished_at: started_at + 1.second), :base )      
    end
  end

end
