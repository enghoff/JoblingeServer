User.destroy_all

Fabricate(:user_with_game_data, nickname: "admin",   role:"admin").register!
Fabricate(:user_with_game_data, nickname: "manager", role:"manager").register!

50.times { Fabricate(:group) }
50.times { Fabricate(:location) }
