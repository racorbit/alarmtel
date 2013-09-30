require 'twilio-ruby'

class GatherReportController < ApplicationController

  def gather    
    digits = params[:Digits]

    # SSSS 18 Q XYZ GG CCC N
    # 1234 18 1 131 01 015 8

    digit_hash = Hash[
      "account_code", digits[0..3],
      "msg_type", digits[4..5],
      "event_qualifier", digits[6],
      "event_code", digits[7..9],
      "partition", digits[10..11],
      "zone", digits[12..14],
      "checksum", digits[15],
    ]

    if _is_a_number?(digits) and _ready_to_send(digit_hash["msg_type"], digit_hash["account_code"])
      _send_sms(digit_hash)
    else
      render :nothing => true
    end
  end

  def _send_sms(digit_hash)
    account_sid = 'ACfd44ee9e742f315e06c70c41b17b9179'
    auth_token = '880f2a102a6c979c3cd5c594a31be526'

    @client = Twilio::REST::Client.new account_sid, auth_token
    
    params = {
      :from => '+16474960429',
      :to => '+' + _to_number(digit_hash["account_code"]),
      :body => _msg_content(digit_hash)
    }

    @client.account.messages.create(params)

    response = Twilio::TwiML::Response.new do |r|
      # r.Say 'Thank you sir mix a lot?', :voice => 'alice'
      r.Hangup
    end

    render :xml => response.text
  end

  def _is_a_number?(my_str)
    true if Float(my_str) rescue false
  end

  def _to_number(account_code)
    case account_code
    when "0001"
      "14168438393"
    when "0002"
      "14165651817"
    else
      "acount_not_found"
    end
  end

  def _ready_to_send(msg_type, account_code)
    _to_number(account_code) != "acount_not_found"
  end

  def _msg_content(digit_hash)
    if digit_hash["msg_type"] == "18"
      msg_content = _alarm_type(digit_hash["event_code"]) + ": " + _event_def(digit_hash["event_code"])
      if _is_a_user(digit_hash["event_code"])
        msg_content = msg_content + " by User: " + digit_hash["zone"] + " on Partition " + digit_hash["partition"]
      else
        msg_content = msg_content + " on Zone " + digit_hash["zone"] + " / Partition " + digit_hash["partition"]
      end
      msg_content = msg_content + _event_type(digit_hash["event_qualifier"]) + " --- via AlarmTell.com"
    else
      msg_content = "Invalid message format - message type is " + digit_hash["msg_type"] + ", expecting 18 (Contact ID) - via AlarmTell.com"
    end
    msg_content
  end

# Contact ID Format Parsing Methods

 def _is_a_user(event_code)
   case Float(event_code)
   when 121, 313, 400..499, 574, 604, 607, 625, 642, 652, 653
     case Float(event_code)
     when 416, 423, 426..428, 432..434, 461, 465
       false
     else
       true
     end
   else
     false
   end
 end

  def _event_type(event_qualifier)
    if event_qualifier == "3"
      " (Restored Event)"
    else
      ""
    end
  end

  def _alarm_type(event_code)
    case Float(event_code)
    when 100..199
      "Alarm"
    when 200..299
      "Supervisory"
    when 300..399
      "Trouble"
    when 400..499
      "Open/Close"
    when 500..599
      "Bypass"
    when 600..699
      "Test/Misc"
    end
  end

  def _event_def(event_code)
    event_hash = Hash[
      "100", "Medical",
      "101", "Personal Emergency",
      "102", "Fail to report in",
      "110", "Fire",
      "111", "Smoke",
      "112", "Combustion",
      "113", "Water flow",
      "114", "Heat",
      "115", "Pull Station",
      "116", "Duct",
      "117", "Flame",
      "118", "Near Alarm",
      "120", "Panic",
      "121", "Duress",
      "122", "Silent",
      "123", "Audible",
      "124", "Duress – Access granted",
      "125", "Duress – Egress granted 123",
      "130", "Burglary",
      "131", "Perimeter",
      "132", "Interior",
      "133", "24 Hour (Safe)",
      "134", "Entry/Exit",
      "135", "Day/night",
      "136", "Outdoor",
      "137", "Tamper",
      "138", "Near alarm",
      "139", "Intrusion Verifier",
      "140", "General Alarm",
      "141", "Polling loop open",
      "142", "Polling loop short",
      "143", "Expansion module failure",
      "144", "Sensor tamper",
      "145", "Expansion module tamper",
      "146", "Silent Burglary",
      "147", "Sensor Supervision Failure",
      "150", "24 Hour Non-Burglary",
      "151", "Gas detected",
      "152", "Refrigeration",
      "153", "Loss of heat",
      "154", "Water Leakage",
      "155", "Foil Break",
      "156", "Day Trouble",
      "157", "Low bottled gas level",
      "158", "High temp",
      "159", "Low temp",
      "161", "Loss of air flow",
      "162", "Carbon Monoxide detected",
      "163", "Tank level",
      "200", "Fire Supervisory",
      "201", "Low water pressure",
      "202", "Low CO2",
      "203", "Gate valve sensor",
      "204", "Low water level ",
      "205", "Pump activated",
      "206", "Pump failure",
      "300", "System Trouble",
      "301", "AC Loss",
      "302", "Low system battery",
      "303", "RAM Checksum bad",
      "304", "ROM checksum bad",
      "305", "System reset",
      "306", "Panel programming changed",
      "307", "Self-test failure",
      "308", "System shutdown",
      "309", "Battery test failure",
      "310", "Ground fault",
      "311", "Battery Missing/Dead",
      "312", "Power Supply Overcurrent",
      "313", "Engineer Reset",
      "320", "Sounder/Relay",
      "321", "Bell 1",
      "322", "Bell 2",
      "323", "Alarm relay",
      "324", "Trouble relay",
      "325", "Reversing relay",
      "326", "Notification Appliance Ckt. # 3",
      "327", "Notification Appliance Ckt. #4",
      "330", "System Peripheral trouble",
      "331", "Polling loop open",
      "332", "Polling loop short",
      "333", "Expansion module failure",
      "334", "Repeater failure",
      "335", "Local printer out of paper",
      "336", "Local printer failure",
      "337", "Exp. Module DC Loss",
      "338", "Exp. Module Low Batt.",
      "339", "Exp. Module Reset",
      "341", "Exp. Module Tamper",
      "342", "Exp. Module AC Loss",
      "343", "Exp. Module self-test fail",
      "344", "RF Receiver Jam Detect",
      "350", "Communication trouble",
      "351", "Telco 1 fault",
      "352", "Telco 2 fault",
      "353", "Long Range Radio xmitter fault",
      "354", "Failure to communicate event",
      "355", "Loss of Radio supervision",
      "356", "Loss of central polling",
      "357", "Long Range Radio VSWR problem",
      "370", "Protection loop",
      "371", "Protection loop open",
      "372", "Protection loop short",
      "373", "Fire trouble",
      "374", "Exit error alarm (zone)",
      "375", "Panic zone trouble",
      "376", "Hold-up zone trouble",
      "377", "Swinger Trouble",
      "378", "Cross-zone Trouble",
      "380", "Sensor trouble",
      "381", "Loss of supervision - RF",
      "382", "Loss of supervision - RPM",
      "383", "Sensor tamper",
      "384", "RF low battery",
      "385", "Smoke detector Hi sensitivity",
      "386", "Smoke detector Low sensitivity",
      "387", "Intrusion detector Hi sensitivity",
      "388", "Intrusion detector Low sensitivity",
      "389", "Sensor self-test failure",
      "391", "Sensor Watch trouble",
      "392", "Drift Compensation Error",
      "393", "Maintenance Alert",
      "400", "Open/Close",
      "401", "O/C by user",
      "402", "Group O/C",
      "403", "Automatic O/C",
      "404", "Late to O/C",
      "405", "Deferred O/C",
      "406", "Cancel",
      "407", "Remote arm/disarm",
      "408", "Quick arm",
      "409", "Keyswitch O/C",
      "441", "Armed STAY",
      "442", "Keyswitch Armed STAY",
      "450", "Exception O/C",
      "451", "Early O/C",
      "452", "Late O/C",
      "453", "Failed to Open",
      "454", "Failed to Close",
      "455", "Auto-arm Failed",
      "456", "Partial Arm",
      "457", "Exit Error (user)",
      "458", "on Premises",
      "459", "Recent Close",
      "461", "Wrong Code Entry",
      "462", "Legal Code Entry",
      "463", "Re-arm after Alarm",
      "464", "Auto-arm Time Extended",
      "465", "Panic Alarm Reset",
      "466", "Service On/Off Premises",
      "411", "Callback request made",
      "412", "Successful download/access",
      "413", "Unsuccessful access",
      "414", "System shutdown command received",
      "415", "Dialer shutdown command received",
      "416", "Successful Upload",
      "421", "Access denied",
      "422", "Access report by user",
      "423", "Forced Access",
      "424", "Egress Denied",
      "425", "Egress Granted",
      "426", "Access Door propped open",
      "427", "Access point Door Status Monitor trouble",
      "428", "Access point Request To Exit trouble",
      "429", "Access program mode entry",
      "430", "Access program mode exit",
      "431", "Access threat level change",
      "432", "Access relay/trigger fail",
      "433", "Access RTE shunt",
      "434", "Access DSM shunt",
      "501", "Access reader disable",
      "520", "Sounder/Relay Disable",
      "521", "Bell 1 disable",
      "522", "Bell 2 disable",
      "523", "Alarm relay disable",
      "524", "Trouble relay disable",
      "525", "Reversing relay disable",
      "526", "Notification Appliance Ckt. # 3 disable",
      "527", "Notification Appliance Ckt. # 4 disable",
      "531", "Module Added",
      "532", "Module Removed",
      "551", "Dialer disabled",
      "552", "Radio transmitter disabled",
      "553", "Remote Upload/Download disabled",
      "570", "Zone/Sensor bypass",
      "571", "Fire bypass",
      "572", "24 Hour zone bypass",
      "573", "Burg. Bypass",
      "574", "Group bypass",
      "575", "Swinger bypass",
      "576", "Access zone shunt",
      "577", "Access point bypass",
      "601", "Manual trigger test report",
      "602", "Periodic test report",
      "603", "Periodic RF transmission",
      "604", "Fire test",
      "605", "Status report to follow",
      "606", "Listen-in to follow",
      "607", "Walk test mode",
      "608", "Periodic test - System Trouble Present",
      "609", "Video Xmitter active",
      "611", "Point tested OK",
      "612", "Point not tested",
      "613", "Intrusion Zone Walk Tested",
      "614", "Fire Zone Walk Tested",
      "615", "Panic Zone Walk Tested",
      "616", "Service Request",
      "621", "Event Log reset",
      "622", "Event Log 50% full",
      "623", "Event Log 90% full",
      "624", "Event Log overflow",
      "625", "Time/Date reset",
      "626", "Time/Date inaccurate",
      "627", "Program mode entry",
      "628", "Program mode exit",
      "629", "32 Hour Event log marker",
      "630", "Schedule change",
      "631", "Exception schedule change",
      "632", "Access schedule change",
      "641", "Senior Watch Trouble",
      "642", "Latch-key Supervision",
      "651", "Reserved for Ademco Use",
      "652", "Reserved for Ademco Use",
      "653", "Reserved for Ademco Use",
      "654", "System Inactivity"
    ]

    if event_hash[event_code] == nil
      event_code
    else
      event_hash[event_code]
    end
  end

end
