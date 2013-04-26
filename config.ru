require 'bundler/setup'
require 'faye'
require 'thread'

$stdout.sync = true if ENV["RACK_ENV"] == 'development'

Faye::WebSocket.load_adapter('thin')
bayeux = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)

use Rack::Static, :urls => ["/js", "/css", "/img", "/index.html"], :root => "public", :index => "index.html"

mutex = Mutex.new

Thread.new {
  highest_bid = 0
  client = bayeux.get_client

  client.subscribe('/private/*') do |bid|
    mutex.synchronize do
      if bid["amount"] && !bid["error"] && bid["amount"] > highest_bid
        highest_bid = bid["amount"]
        client.publish('/bids', bid)
      else
        client.publish("/private/#{bid['user']}", { "error" => "Bid is too low." })
      end
    end
  end
}

run bayeux
