require 'bundler/setup'
require 'faye'

Faye::WebSocket.load_adapter('thin')
bayeux = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)

Thread.new {
  highest_bid = 0
  client = bayeux.get_client

  client.subscribe('/private/*') do |bid|
    if !bid["error"] && bid["amount"] > highest_bid
      highest_bid = bid["amount"]
      client.publish('/bids', bid)
    else
      client.publish("/private/#{bid['user']}", { "error" => "Bid is too low." })
    end
  end
}

run bayeux
