require 'twilio-ruby'

class ReportVoiceController < ApplicationController
  def create
    account_sid = 'ACfd44ee9e742f315e06c70c41b17b9179'
    auth_token = '880f2a102a6c979c3cd5c594a31be526'

    response = Twilio::TwiML::Response.new do |r|
      # r.Say 'Yo what up Doggie Doglock?', :voice => 'alice'
      url_root = url_for :only_path => false
      r.Play "#{url_root.gsub! "report_voice", ""}assets/handshake.aif"
      r.Gather :action => '/gather_report', :numDigits => '16', :timeout => '5', :finishOnKey => ' ' do |g|
      # r.Play "#{url_root.gsub! "report_voice", ""}assets/kiss_off.aif"
      # r.Hangup
      # r.Play "#{url_root.gsub! "report_voice", ""}assets/kiss_off.aif"
      end
    end

    puts "-----------------------"
    puts response.text
    render :xml => response.text
  end
end
