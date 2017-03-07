class PlayerSessionSerializer < ActiveModel::Serializer

  attributes :id,
    :started_at,
    :finished_at,
    :duration_in_seconds

end
