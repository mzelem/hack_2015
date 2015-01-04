require 'att/codekit'

class DevicesController < ApplicationController
  include Att::Codekit
  before_action :set_device, only: [:show, :edit, :action, :update, :destroy]

  # GET /devices
  # GET /devices.json
  def index
    @devices = current_user.devices.all

    # init device status
    if @devices.first.present? && @devices.first.status.blank?
      @devices.each do |d|
        d.get_status
        d.save
      end
    end
  end

  # GET /devices/1
  # GET /devices/1.json
  def show
    img = @device.get_snapshot

    File.open('/tmp/image.jpg', 'wb') do|f|
      f.write(Base64.decode64(img))
    end

    fqdn = 'https://api.att.com'

    clientcred = Auth::ClientCred.new(fqdn,
                                      'hw3jjqqx24o16vkwi3ljza6hpuwykgyj',
                                      'vycosunsgooofdjy4d01cpynupvcitbo')

    token = clientcred.createToken('MMS')

    mms = Service::MMSService.new(fqdn, token)
    response = mms.sendMms('3035137428', "Your guest has arrived", '/tmp/image.jpg')

    send_data File.open('/tmp/image.jpg', 'r').read, type: 'image/jpg', disposition: 'inline'
  end

  # GET /devices/1
  # GET /devices/1.json
  def action
    content = '-1'
    c = 0

    device_action = params[:device_action]
    while content.to_s == '-1' do
      resp = @device.perform_action(device_action)
      content = JSON.parse(resp.body)["content"]
      c += 1
      content = '1' if c == 2
    end

    if content.to_s != '-1'
      
      @device.status = device_action
      @device.save

      if device_action == 'unlock'
        @camera_device = @device.user.devices.where(device_type: 'camera').first

        img = @camera_device.get_snapshot

        pic = @camera_device.pics.create(base_64: @camera_device)

        #fqdn = 'https://api.att.com'

        token = Att::Codekit::Auth::OAuthToken.new(session["credentials"]["token"], session["credentials"]["expires_at"], session["credentials"]["refresh_token"])

        message = Message.new(to: '3035137428', body: "Your guest has checked in: http://#{request.host_with_port}/pics/#{pic.id}")

        message.send_message(token)
      end

      render action: :show
    else
      render status: 422, json: {}
    end
  end

  # GET /devices/new
  def new
    @device = Device.new
  end

  # GET /devices/1/edit
  def edit
  end

  # POST /devices
  # POST /devices.json
  def create
    @device = Device.new(device_params)

    respond_to do |format|
      if @device.save
        format.html { redirect_to devices_path, notice: 'Device was successfully created.' }
        format.json { render :show, status: :created, location: @device }
      else
        format.html { render :new }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /devices/1
  # PATCH/PUT /devices/1.json
  def update
    respond_to do |format|
      if @device.update(device_params)
        format.html { redirect_to devices_path, notice: 'Device was successfully updated.' }
        format.json { render :show, status: :ok, location: @device }
      else
        format.html { render :edit }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /devices/1
  # DELETE /devices/1.json
  def destroy
    @device.destroy
    respond_to do |format|
      format.html { redirect_to devices_url, notice: 'Device was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device
      @device = Device.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def device_params
      params.require(:device).permit(:name, :beacon_id, :device_type)
    end
end
