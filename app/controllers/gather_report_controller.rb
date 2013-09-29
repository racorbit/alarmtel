require 'twilio-ruby'

class GatherReportController < ApplicationController

  def gather
    account_sid = 'ACfd44ee9e742f315e06c70c41b17b9179'
    auth_token = '880f2a102a6c979c3cd5c594a31be526'
    
    digits = params[:Digits]

    # puts digits
    # puts "about to send text"

    @client = Twilio::REST::Client.new account_sid, auth_token
    
    params = {
      :from => '+16474960429',
      :to => '+14168438393',
      :body => digits
    }
    
    @client.account.messages.create(params)
    render :nothing => true
  end

end
