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
    }

    mapping(address => Bid) private bids;
    mapping(address => uint256) private refunds;

    event NewBid(address indexed bidder, uint256 bid, bool secret);
    event AuctionEnded(address winner, uint256 bid);

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

    function getRefund(address bidder) public view returns (uint256) {
        return refunds[bidder];
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

        if (highestBidder != address(0)) {
            refunds[highestBidder] += highestBidAmount;
        }

        bids[msg.sender] = Bid(msg.value, _secret);
        highestBidder = msg.sender;

        emit NewBid(msg.sender, msg.value, _secret);
    }

    function finalizeAuction() public onlyOwner {
        require(isAuctionActive, "Auction is not active");
        require(
            block.timestamp > startAt + duration,
            "Auction has not ended yet"
        );

        isAuctionActive = false;
        nftAssetOwner = highestBidder;
        emit AuctionEnded(highestBidder, bids[highestBidder].amount);
    }

    function withdraw() public {
        uint256 amount = refunds[msg.sender];

        require(amount > 0, "No funds to withdraw");

        refunds[msg.sender] = 0;
        // Deducting 2% commission
        payable(msg.sender).transfer((amount * 98) / 100);
    }
}
