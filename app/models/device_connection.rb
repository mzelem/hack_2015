class DeviceConnection
  USER_ID = '553474442'
  PASSWORD = 'NO-PASSWD'
  APP_KEY = 'DE_154EB6D6BB79A8D8_1'
  BASE_URL = 'https://systest.digitallife.att.com:443'

  attr_accessor :user, :status

  def initialize(user)
    self.user = user
  end

  def auth_token
    user.auth_token
  end

  def request_token
    user.request_token
  end

  def gateway_id
    user.gateway_id
  end

  def get_auth_token
    conn = Faraday.new(:url => BASE_URL) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
    resp = conn.post '/penguin/api/authtokens', { userId: self.user.login, password: self.user.password, domain: 'DL', appKey: APP_KEY }

    JSON.parse(resp.body)
  end

  def att_connection
    get_auth_token

    @att_connection = if @att_connection.nil?
                        conn = Faraday.new(:url => BASE_URL) do |faraday|
                          faraday.request  :url_encoded             # form-encode POST params
                          faraday.response :logger                  # log requests to STDOUT
                          faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
                        end
                        conn.headers = {'AppKey' => APP_KEY, 'Authtoken' => self.auth_token, 'Requesttoken' => self.request_token }
                        conn
                      else
                        @att_connection
                      end
  end

  def get_device_guid(device)
    resp_json = get_devices
    resp_json['content'].select{|h| !!(h['deviceType'] =~ /#{device.device_type}/) }.first["deviceGuid"]
  end

  def get_device_status(device)
    resp_json = get_devices
    resp_json['content'].select{|h| !!(h['deviceType'] =~ /#{device.device_type}/) }.first["attributes"].select{|h| !!(h['label'] =~ /#{Device::ACTION_MAP[device.device_type].to_s}/) }.first["value"]
  end

  def get_devices
    resp_json ||= JSON.parse(att_connection.get("/penguin/api/#{self.gateway_id}/devices").body)
  end

  def perform_action(action,device)
    @resp_json = nil
    resp = att_connection.post do |req|
      req.url "/penguin/api/#{self.gateway_id}/devices/#{get_device_guid(device)}/#{Device::ACTION_MAP[device.device_type].to_s}"
      req.headers['Content-Type'] = 'application/json'
      req.body = action
    end
    resp
  end

  def get_snapshot(device)
    @resp_json = nil
    att_connection.get do |req|
      req.url "/penguin/api/#{self.gateway_id}/snapshot/#{get_device_guid(device)}"
      req.headers['Content-Type'] = 'application/json'
    end
  end
end