module Fishbowl::Errors
  class ConnectionNotEstablished < RuntimeError; end;
  class ApprovalError < RuntimeError; end;
  class LoginError < RuntimeError; end;
  class MissingHost < ArgumentError; end;
  class MissingUsername < ArgumentError; end;
  class MissingPassword < ArgumentError; end;

  class StatusError < RuntimeError; end;

  def self.confirm_success_or_raise(code, status_message = nil)
    case code
      when 1000
        message = "Success!"
      when 1001
        message = "Unknown Message Received"
      when 1002
        message = "Connection to Fishbowl Server was lost"
      when 1003
        message = "Some Requests had errors -- now isn't that helpful..."
      when 1004
        message = "There was an error with the database."
      when 1009
        message = "Fishbowl Server has been shut down."
      when 1010
        message = "You have been logged off the server by an administrator."
      when 1012
        message = "Unknown request function."
      when 1100
        message = "Unknown login error occurred."
      when 1110
        message = "A new Integrated Application has been added to Fishbowl Inventory. Please contact your Fishbowl Inventory Administrator to approve this Integrated Application."
        raise(ApprovalError, message)
        return
      when 1111
        message = "This Integrated Application registration key does not match."
      when 1112
        message = "This Integrated Application has not been approved by the Fishbowl Inventory Administrator."
        raise(ApprovalError, message)
        return
      when 1120
        message = "Invalid Username or Password."
        raise(LoginError, message)
        return
      when 1130
        message = "Invalid Ticket passed to Fishbowl Inventory Server."
      when 1131
        message = "Invalid Key value."
      when 1140
        message = "Initialization token is not correct type."
      when 1150
        message = "Request was invalid"
      when 1160
        message = "Response was invalid."
      when 1162
        message = "The login limit has been reached for the server's key."
      when 1200
        message = "Custom Field is invalid."
      when 1500
        message = "The import was not properly formed."
      when 1501
        message = "That import type is not supported"
      when 1502
        message = "File not found."
      when 1503
        message = "That export type is not supported."
      when 1504
        message = "File could not be written to."
      when 1505
        message = "The import data was of the wrong type."
      when 2000
        message = "Was not able to find the Part {0}."
      when 2001
        message = "The part was invalid."
      when 2100
        message = "Was not able to find the Product {0}."
      when 2101
        message = "The product was invalid."
      when 2200
        message = "The yield failed."
      when 2201
        message = "Commit failed."
      when 2202
        message = "Add initial inventory failed."
      when 2203
        message = "Can not adjust committed inventory."
      when 2300
        message = "Was not able to find the Tag number {0}."
      when 2301
        message = "The tag is invalid."
      when 2302
        message = "The tag move failed."
      when 2303
        message = "Was not able to save Tag number {0}."
      when 2304
        message = "Not enough available inventory in Tagnumber {0}."
      when 2305
        message = "Tag number {0} is a location."
      when 2400
        message = "Invalid UOM."
      when 2401
        message = "UOM {0} not found."
      when 2402
        message = "Integer UOM {0} cannot have non-integer quantity."
      when 2500
        message = "The Tracking is not valid."
      when 2510
        message = "Serial number is missing."
      when 2511
        message = "Serial number is null."
      when 2512
        message = "Serial number is duplicate."
      when 2513
        message = "Serial number is not valid."
      when 2600
        message = "Location not found."
      when 2601
        message = "Invalid location."
      when 2602
        message = "Location Group {0} not found."
      when 3000
        message = "Customer {0} not found."
      when 3001
        message = "Customer is invalid."
      when 3100
        message = "Vendor {0} not found."
      when 3101
        message = "Vendor is invalid."
      when 4000
        message = "There was an error load PO {0}."
      when 4001
        message = "Unknow status {0}."
      when 4002
        message = "Unknown carrier {0}."
      when 4003
        message = "Unknown QuickBooks class {0}."
      when 4004
        message = "PO does not have a PO number. Please turn on the auto-assign PO number option in the purchase order module options."
      else
        message = "Unknown Error"
    end
    
    message = status_message if status_message
    
    code == 1000 ? true : raise(StatusError, message)
  end
end