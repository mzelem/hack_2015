class User < ActiveRecord::Base

  has_many :devices

  #before_save :authorize
  after_save :load_devices

  validates_presence_of :password

  def authorize
    resp_json = device_connection.get_auth_token

    self.auth_token = resp_json['content']['authToken']
    self.gateway_id = resp_json['content']['gateways'][0]['id']
    self.request_token = resp_json['content']['requestToken']

  rescue
    false
  end

  def load_devices
    devices_json = device_connection.get_devices['content'].select{|h| !!(h['deviceType'] =~ /door-lock|smart-plug/) }

    devices_json.each do |d|
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

  def device_connection
    @device_conn ||= DeviceConnection.new(self)
  end
end