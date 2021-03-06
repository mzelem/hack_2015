class GuestsController < ApplicationController
  before_action :authorize_user
  before_action :set_guest, only: [:show, :edit, :update, :destroy]

  # GET /guests
  # GET /guests.json
  def index
    @guests = Guest.all
  end

  # GET /guests/1
  # GET /guests/1.json
  def show
  end

  # GET /guests/new
  def new
    @guest = Guest.new
  end

  # GET /guests/1/edit
  def edit
  end

  # POST /guests
  # POST /guests.json
  def create
    @guest = Guest.new(guest_params)

    respond_to do |format|
      if @guest.save

        message = Message.new(to: @guest.phone, body: "Thank you for registering to be our guest on #{@guest.check_in}. Your key is: #{@guest.token}")

        token = Att::Codekit::Auth::OAuthToken.new(session["credentials"]["token"], session["credentials"]["expires_at"], session["credentials"]["refresh_token"])
        message.send_message(token)

        format.html { redirect_to guests_path, notice: 'Guest was successfully created.' }
        format.json { render :show, status: :created, location: @guest }
      else
        format.html { render :new }
        format.json { render json: @guest.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /guests/1
  # PATCH/PUT /guests/1.json
  def update
    respond_to do |format|

      message = Message.new(to: @guest.phone, body: "Thank you for registering to be our guest on #{@guest.check_in}. Your key is: #{@guest.token}")

      if @guest.update(guest_params)
        token = Att::Codekit::Auth::OAuthToken.new(session["credentials"]["token"], session["credentials"]["expires_at"], session["credentials"]["refresh_token"])
        message.send_message(token)
        format.html { redirect_to guests_path, notice: 'Guest was successfully updated.' }
        format.json { render :show, status: :ok, location: @guest }
      else
        format.html { render :edit }
        format.json { render json: @guest.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /guests/1
  # DELETE /guests/1.json
  def destroy
    @guest.destroy
    respond_to do |format|
      format.html { redirect_to guests_url, notice: 'Guest was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_guest
      @guest = Guest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def guest_params
      params.require(:guest).permit(:name, :phone, :token, :check_in, :checkout, :bluetooth_id, :preferred_language)
    end
end
