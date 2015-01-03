require 'att/codekit'

class Message < ActiveRecord::Base
  include Att::Codekit

  def send_message(token)
    # Specify the addresses where the message is sent.
    addresses = self.to

    # Alternatively, the addresses can be specified using an array.
    # addresses = [5555555555,"444-555-5555"]

    # Create the service for making the method request.
    immn = Service::IMMNService.new('https://api.att.com', token)

    # Use exception handling to see if anything went wrong with the request.
    begin

      # Make method requests to send SMS and MMS messages.
      sms = immn.sendMessage(addresses, :message => self.body)
      #mms = immn.sendMessage(addresses, :subject => "This is a MMS message from the In-App Messaging example")

    rescue Service::ServiceException => e
      puts "There was an error, the API Gateway returned the following error code:"
      puts "#{e.message}"

    else

      # Display of results.
      puts "The response id of the sms message was: #{sms.id}"
    end

  end
end
