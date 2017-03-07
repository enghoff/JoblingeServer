Fabricator(:location) do
  name { Faker::Address.city }
end
