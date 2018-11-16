# frozen_string_literal: true

require 'cuba'
require 'twitter'
require 'newrelic_rpm'

CLIENT = Twitter::REST::Client.new do |c|
  c.consumer_key        = ENV['TWITTER_CONSUMER_API_KEY']
  c.consumer_secret     = ENV['TWITTER_CONSUMER_API_SECRET']
  c.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  c.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

CUSTOMER       = 'realDonaldTrump'
COMPANY        = 'SpongebobTo'
COMMENT_PREFIX = "@#{CUSTOMER} "

# I have no clue how to spell this...
# spongify I feel would be pronounced wrongly
def spongify(body)
  sponged_body = body.each_char
                     .with_object(String.new) do |char, new_body|
    new_body << char.public_send(rand(0..1).zero? ? :upcase : :downcase)
  end
  COMMENT_PREFIX + sponged_body
end

def sponge_it
  customer_latest_tweet = CLIENT.user_timeline(CUSTOMER).first
  our_latest_tweet      = CLIENT.user_timeline(COMPANY).first

  # This doesn't work if COMPANY has no tweets
  #
  # This also doesn't take into account if the CUSTOMER
  # tweets more than once between when this code is run
  if our_latest_tweet.in_reply_to_status_id != customer_latest_tweet.id
    CLIENT.update(spongify(customer_latest_tweet.text),
                  in_reply_to_status_id: customer_latest_tweet.id)
  end
end

Cuba.define do
  on get do
    on root do
      sponge_it
      res.write "Check me out at https://twitter.com/#{COMPANY}"
    end
  end
end
