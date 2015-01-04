json.array!(@users) do |user|
  json.extract! user, :id, :login, :password, :gateway_id
  json.url user_url(user, format: :json)
end
