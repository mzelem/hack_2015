class DevicesController < ApplicationController
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
  end

  # GET /devices/1
  # GET /devices/1.json
  def action
    if @device.perform_action(params[:device_action])
      @device.get_status
      @device.save

      render action: :show
    else
      render status: 422
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
