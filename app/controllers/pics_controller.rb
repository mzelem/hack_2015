class PicsController < ApplicationController
  before_action :set_pic, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @pics = Pic.all
    respond_with(@pics)
  end

  def show
    respond_with(@pic)


    send_data Base64.decode64(@pic.base_64), type: 'image/jpg', disposition: 'inline'
  end

  def new
    @pic = Pic.new
    respond_with(@pic)
  end

  def edit
  end

  def create
    @pic = Pic.new(pic_params)
    @pic.save
    respond_with(@pic)
  end

  def update
    @pic.update(pic_params)
    respond_with(@pic)
  end

  def destroy
    @pic.destroy
    respond_with(@pic)
  end

  private
    def set_pic
      @pic = Pic.find(params[:id])
    end

    def pic_params
      params.require(:pic).permit(:device_id, :base_64)
    end
end
