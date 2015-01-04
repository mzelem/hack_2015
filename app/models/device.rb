class Device < ActiveRecord::Base

  belongs_to :user

  ACTION_MAP = { "door-lock" => :lock, 'smart-plug' => :switch }

  def self.all_with_status

    devices = self.all
    devices.each do |d|
      d.status = device_connection.get_device_status(d)
    end
  end

  def perform_action(action)
    device_connection.perform_action(action, self)
  end

  def get_status
    self.status = device_connection.get_device_status(self)
  end

  def device_connection
    user.device_connection
  end
end
