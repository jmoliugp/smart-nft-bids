// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract AdvancedAuction {
    address private owner;
    uint256 public startingBid;
    uint256 public startAt;
    uint256 public duration;
    address public highestBidder;
    uint256 public highestBid;
    bool public isAuctionActive;
    IERC721 public nft;
    uint256 public tokenId;

    struct Bid {
        uint256 amount;
        bool secret;
    }

    mapping(address => Bid) public bids;
    mapping(address => uint256) public refunds;

    event NewBid(address indexed bidder, uint256 bid, bool secret);
    event AuctionEnded(address winner, uint256 bid);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(address _nftAddress, uint256 _tokenId) {
        owner = msg.sender;
        nft = IERC721(_nftAddress);
        tokenId = _tokenId;
    }

    function startAuction(uint256 _startingBid, uint256 _startAt, uint256 _duration) public onlyOwner {
        require(!isAuctionActive, "Auction is already active");

        startingBid = _startingBid;
        startAt = _startAt;
        duration = _duration;
        isAuctionActive = true;
    }

    function bid(bool _secret) public payable {
        require(isAuctionActive, "Auction is not active");

        require(block.timestamp >= startAt, "Auction has not started yet");
        require(block.timestamp <= startAt + duration, "Auction has already ended");

        require(msg.value > highestBid, "There needs to be a higher bid");

        if (highestBidder != address(0)) {
            refunds[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        bids[msg.sender] = Bid(msg.value, _secret);
        emit NewBid(msg.sender, msg.value, _secret);
    }

    function finalizeAuction() public onlyOwner {
        require(isAuctionActive, "Auction is not active");
        require(block.timestamp > startAt + duration, "Auction has not ended yet");

        isAuctionActive = false;
        nft.transferFrom(owner, highestBidder, tokenId);
        emit AuctionEnded(highestBidder, highestBid);
    }

    function withdraw() public {
        uint256 amount = refunds[msg.sender];

        require(amount > 0, "No funds to withdraw");

        refunds[msg.sender] = 0;
        // Deducting 2% commission
        payable(msg.sender).transfer(amount * 98 / 100);
    }

    function showWinner() public view returns (address, uint256) {
        require(!isAuctionActive, "Auction has not ended");

        return (highestBidder, highestBid);
    }
}
