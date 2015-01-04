class Device < ActiveRecord::Base

  attr_accessor :auth_token, :gateway_id, :request_token, :status

  ACTION_MAP = { "door-lock" => :lock, 'smart-plug' => :switch }

  USER_ID = '553474442'
  PASSWORD = 'NO-PASSWD'
  APP_KEY = 'OE_43908046736E006C_1'
  BASE_URL = 'https://systest.digitallife.att.com:443'

  def get_auth_token
    conn = Faraday.new(:url => BASE_URL) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
    resp = conn.post '/penguin/api/authtokens', { userId: USER_ID, password: PASSWORD, domain: 'DL', appKey: APP_KEY }

    resp_json = JSON.parse(resp.body)

    self.auth_token = resp_json['content']['authToken']
    self.gateway_id = resp_json['content']['gateways'][0]['id']
    self.request_token = resp_json['content']['requestToken']
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

  def get_device_guid
    resp = att_connection.get("/penguin/api/#{self.gateway_id}/devices")
    resp_json = JSON.parse(resp.body)
    resp_json['content'].select{|h| !!(h['deviceType'] =~ /#{self.device_type}/) }.first["deviceGuid"]
  end

  def perform_action(action)
    att_connection.post do |req|
      req.url "/penguin/api/#{self.gateway_id}/devices/#{get_device_guid}/#{ACTION_MAP[self.device_type]}"
      req.headers['Content-Type'] = 'application/json'
      req.body = action
    end
  end
end
