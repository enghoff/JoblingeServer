Fabricator(:user) do
  nickname          { Faker::Internet.user_name }
  email             { Faker::Internet.email }
  location
  group
  gender            { %w(female male).sample }
  birth_date        { Faker::Date.between(10.years.ago, 18.years.ago) }
  password          { "qwerty" }
end

Fabricator(:user_with_game_data, from: :user) do
  after_create do |user|
    data = {
      "currentLocationId":"villa_01",
      "locations":[
        {
          "id":"villa_01",
          "currentPuzzle":"Villa_puzzle_01_Priorities",
          "currentRouteNodeId":"WayPoint_01",
          "puzzles":[
            {
              "id":"Villa_puzzle_01_Priorities",
              "puzzleLockId":"LockLocation01",
              "puzzleState":"UNLOCKED",
              "score":0,
              "completedAt":"2016-04-15T07:09:33.000Z"
            },
            {
              "id":"Villa_puzzle_03_Operator",
              "puzzleLockId":"LockLocation01",
              "puzzleState":"UNLOCKED",
              "score":0,
              "completedAt":"2016-04-15T07:09:33.000Z"
            }
          ]
        }
      ]
    }

    GameData.create!(user:user, data:data)
  end
end

Fabricator(:user_with_play_sessions, from: :user_with_game_data) do
  player_sessions(rand: 20){ Fabricate(:player_session) }
end
