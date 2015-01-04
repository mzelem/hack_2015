class User < ActiveRecord::Base

  has_many :devices

  before_validation :authorize
  before_save :load_devices

  validates_presence_of :auth_token
  validates_presence_of :password

  def authorize
    conn = DeviceConnection.new(self)

    resp_json = conn.get_auth_token

    self.auth_token = resp_json['content']['authToken']
    self.gateway_id = resp_json['content']['gateways'][0]['id']
    self.request_token = resp_json['content']['requestToken']

  rescue
    false
  end

  def load_devices
    conn = DeviceConnection.new(self)

    conn.get_devices['content'].select{|h| !!(h['deviceType'] =~ /door-lock|smart-plug/) }.each do |d|
      name = if d['deviceType'] == 'door-lock'
        'Front Door'
      else
        'Switch'
      end
      device = self.devices.find_or_initialize_by(name: name)
      device.device_type = d['deviceType']
      device.status = d["attributes"].select{|h| !!(h['label'] =~ /#{Device::ACTION_MAP[device.device_type].to_s}/) }.first["value"]
      device.save
    end
  end
end
