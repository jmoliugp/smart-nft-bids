// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

contract AdvancedAuction {
    address private owner;
    address private nftAssetOwner;

    uint256 private startAt;
    uint256 private duration;

    uint256 private startingBid;
    address private highestBidder;

    bool private isAuctionActive;

    struct Bid {
        uint256 amount;
        bool secret;
        address bidder;
    }

    mapping(address => Bid) private bids;
    Bid[] private refunds;

    event NewBid(address indexed bidder, uint256 bid, bool secret);
    event AuctionEnded(address winner, uint256 bid);
    event RefundProcessed(address bidder, uint256 refundAmount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
        // Initially, the owner owns the virtual asset.
        nftAssetOwner = owner;
    }

    // Getters
    function getStartAt() public view returns (uint256) {
        return startAt;
    }

    function getDuration() public view returns (uint256) {
        return duration;
    }

    function getHighestBidder() public view returns (address) {
        require(highestBidder != address(0), "No bids registered yet");

        Bid memory highestBid = bids[highestBidder];
        if (highestBid.secret && msg.sender != owner) {
            revert("The bid is secret and you are not the owner");
        }

        return highestBidder;
    }

    function getHighestBid() public view returns (uint256) {
        return bids[highestBidder].amount;
    }

    function getIsAuctionActive() public view returns (bool) {
        return isAuctionActive;
    }

    function startAuction(
        uint256 _startingBid,
        uint256 _startAt,
        uint256 _duration
    ) public onlyOwner {
        require(!isAuctionActive, "Auction is already active");

        startingBid = _startingBid;
        startAt = _startAt;
        duration = _duration;
        isAuctionActive = true;
    }

    function bid(bool _secret) public payable {
        require(isAuctionActive, "Auction is not active");

        require(block.timestamp >= startAt, "Auction has not started yet");
        require(
            block.timestamp <= startAt + duration,
            "Auction has already ended"
        );

        uint256 highestBidAmount = bids[highestBidder].amount;
        require(
            msg.value > highestBidAmount && msg.value > startingBid,
            "There needs to be a higher bid"
        );

        Bid memory newBid = Bid(msg.value, _secret, msg.sender);
        bids[msg.sender] = newBid;
        refunds.push(newBid);
        highestBidder = msg.sender;

        emit NewBid(msg.sender, msg.value, _secret);
    }

    function finalizeAuction() public onlyOwner {
        require(isAuctionActive, "Auction is not active");
        require(
            block.timestamp > startAt + duration,
            "Auction has not ended yet"
        );

        // Processing refunds for all except the highest bidder.
        for (uint256 i = 0; i < refunds.length; i++) {
            if (refunds[i].bidder != highestBidder) {
                uint256 refundAmount = refunds[i].amount;
                // Calculating 2% commission.
                uint256 commission = (refundAmount * 2) / 100;
                uint256 refundNetCommission = refundAmount - commission;

                // Ensure safe transfer of funds.
                (bool success, ) = payable(refunds[i].bidder).call{
                    value: refundNetCommission
                }("");
                require(success, "Failed to send refund");

                emit RefundProcessed(refunds[i].bidder, refundNetCommission);
            }
        }

        // Mark the auction as not active and update the nftAssetOwner.
        isAuctionActive = false;
        nftAssetOwner = highestBidder;
        emit AuctionEnded(highestBidder, bids[highestBidder].amount);
    }

    function withdraw() public {
        // Prevent the highest bidder from withdrawing their bid during the auction.
        // This is crucial for maintaining the integrity of the auction, ensuring that the highest bid
        // remains valid and locked until the auction is finalized. It prevents the highest bidder from
        // retracting their winning bid, which could undermine the auction process.
        require(
            msg.sender != highestBidder,
            "Highest bidder cannot withdraw funds"
        );

        // Initialize a variable to track if a refund has been processed.
        bool refundProcessed = false;
        uint256 refundAmount = 0;

        for (uint256 i = 0; i < refunds.length; i++) {
            if (refunds[i].bidder == msg.sender) {
                refundAmount = refunds[i].amount;
                require(refundAmount > 0, "No funds to withdraw");

                // Calculate the amount to refund after deducting a 2% commission
                uint256 refundNetCommission = (refundAmount * 98) / 100;
                refunds[i].amount = 0;

                // Send the refund, ensuring to handle failure as per EIP-1884 / EIP-2929
                (bool success, ) = payable(msg.sender).call{
                    value: refundNetCommission
                }("");
                require(success, "Transfer failed");

                emit RefundProcessed(refunds[i].bidder, refundNetCommission);

                refundProcessed = true;
                break;
            }
        }

        // Ensure that a refund was indeed processed
        require(refundProcessed, "No eligible refund found for this address");
    }
}
