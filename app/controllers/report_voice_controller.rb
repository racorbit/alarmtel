require 'twilio-ruby'

class ReportVoiceController < ApplicationController
  def create
    account_sid = 'ACfd44ee9e742f315e06c70c41b17b9179'
    auth_token = '880f2a102a6c979c3cd5c594a31be526'

    response = Twilio::TwiML::Response.new do |r|
      # r.Say 'Yo Snow, whadda ya now?', :voice => 'alice'
      r.Gather :action => '/gather_report', :finish_on_key => '' do |g|
      end
    end

    # puts response.text
    # puts 'about to respond'

    render :xml => response.text
  end
end
