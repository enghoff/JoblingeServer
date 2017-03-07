class UserWithTokenSerializer < ActiveModel::Serializer

  attributes :id,
    :email,
    :nickname,
    :location,
    :group,
    :gender,
    :birth_date_year,
    :birth_date_month,
    :birth_date_day,
    :auth_token,
    :created_at

  has_one :game_data
  belongs_to :group
  belongs_to :location
  
end
