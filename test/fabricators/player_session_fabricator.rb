Fabricator(:player_session) do
  started_at  { rand(90).days.ago }
  finished_at {|attrs| attrs[:started_at] + rand(120).minutes + 1.second}
end
