require 'twilio-ruby'

class ReportVoiceController < ApplicationController
  def create
    account_sid = 'ACfd44ee9e742f315e06c70c41b17b9179'
    auth_token = '880f2a102a6c979c3cd5c594a31be526'

    response = Twilio::TwiML::Response.new do |r|
      # r.Say 'Yo what up Dogie Doglock?', :voice => 'alice'
      r.Gather :action => '/gather_report', :timeout => '5', :finishOnKey => ' ' do |g|
      end
    end

    render :xml => response.text
  end
end
