json.array!(@guests) do |guest|
  json.extract! guest, :id, :name, :phone, :token, :check_in, :checkout, :bluetooth_id, :preferred_language
  json.url guest_url(guest, format: :json)
end
