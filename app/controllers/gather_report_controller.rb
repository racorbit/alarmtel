require 'twilio-ruby'

class GatherReportController < ApplicationController

  def gather    
    digits = params[:Digits]

    # SSSS 18 QXYZ GG CCC N
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

    puts "wat is hapening"
    if _is_a_number?(digits) and _ready_to_send(digit_hash["msg_type"], digit_hash["account_code"])
      puts 'about to call send_sms'
      _send_sms(digit_hash)
    else
      puts 'about to render nothing'
      render :nothing => true
    end
  end

  def _send_sms(digit_hash)
    puts '-------in send sms'
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
    puts _to_number(account_code) != "acount_not_found"
    msg_type == "18" and _to_number(account_code) != "acount_not_found"
  end

  def _msg_content(digit_hash)
    "AlarmTell.com " + _alarm_type(digit_hash["event_code"]) + " Report: " + digit_hash["event_code"] + " on zone: " + digit_hash["zone"]
    # _event_type(digit_hash["event_qualifier"]) + ": "
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
    when 400..499
      "Bypass"
    when 400..499
      "Test/Misc."
    end
  end

  def _is_a_number?(my_str)
    true if Float(my_str) rescue false
  end
end
