json.array!(@pics) do |pic|
  json.extract! pic, :id, :device_id, :base_64
  json.url pic_url(pic, format: :json)
end
