json.array!(@devices) do |device|
  json.extract! device, :id, :name, :beacon_id, :device_type, :status
  json.url device_url(device, format: :json)
end
