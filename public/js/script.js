$(document).ready(function() {
    var user = prompt("Enter your name, please.");
    $("#username").text(user);
    var channel = "/private/" + user;

    var client = new Faye.Client('/faye');

    var lastBid = 0;
    var highestBid = 0;

    function log(message) {
        var now = new Date(),
            timestamp = now.getHours() + ":" + now.getMinutes() + ":" + now.getSeconds();
        var node = $("<p/>").text("[" + timestamp + "]: " + message);
        $("#log").append(node);
    }

    function updateHighestBid(bid) {
        var amount = bid.amount,
            user = bid.user == user ? "you" : bid.user;

        highestBid = amount;
        $("#highest-bid").html("<span>Highest bid: <strong>" + highestBid + " EUR</strong> by <strong>" + user + "</strong></span>");
    }

    client.subscribe('/bids', function(message) {
        updateHighestBid(message);
        var username = message.user == user ? "You" : message.user;
        log(username + " bid " + message.amount + " EUR ");
    });

    client.subscribe(channel, function(message) {
        if(message.error) log(message.error);
    });

    $("form#bidding input#bid").click(function() {
        var amount = parseInt($("form#bidding #amount").val());
        client.publish(channel, {
            user: user,
            amount: amount
        });
        return false;
    });
});
