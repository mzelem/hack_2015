class Guest < ActiveRecord::Base
  before_create :set_token

  private
  def set_token
    self.token = SecureRandom.urlsafe_base64(5)
  end
end
