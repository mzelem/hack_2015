class Device < ActiveRecord::Base

  belongs_to :user

  ACTION_MAP = { "door-lock" => :lock, 'smart-plug' => :switch }

  def self.all_with_status
    conn = DeviceConnection.new(self.user)

    devices = self.all
    devices.each do |d|
      d.status = conn.get_device_status(d)
    end
  end

  def perform_action(action)
    DeviceConnection.new(self.user).perform_action(action, self)
  end

  def get_status
    conn = DeviceConnection.new(self.user)
    self.status = conn.get_device_status(self)
  end
end
