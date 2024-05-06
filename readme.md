# Advanced Auction Contract

The Advanced Auction Contract is a Solidity-based smart contract designed for conducting secure, transparent, and efficient online auctions of virtual assets, such as NFTs (Non-Fungible Tokens). It supports secret bids, automatic refunds, and commission deduction functionalities.

## Features

- **Start an Auction**: Initialize an auction with a starting bid, start time, and duration.
- **Bid**: Allows participants to place bids higher than the current highest bid and the starting bid. Bids can be marked as secret.
- **Finalize Auction**: Conclude the auction, process refunds with a 2% commission deduction, and transfer ownership of the asset to the highest bidder.
- **Withdraw**: Participants can withdraw their refunds, except for the highest bidder, to ensure the integrity of the auction.

## Contract Methods

- `startAuction(uint256 _startingBid, uint256 _startAt, uint256 _duration)`: Starts the auction with specified parameters.
- `bid(bool _secret)`: Place a bid on the auction. If `_secret` is true, the bid details are hidden until the auction ends.
- `finalizeAuction()`: Ends the auction, assigns the asset to the highest bidder, and processes all refunds.
- `withdraw()`: Allows bidders to withdraw their refunded bids minus a commission.

## Getting Started

### Using Remix IDE

Remix is a powerful in-browser IDE that allows you to write, compile, deploy, and test Solidity contracts without the need for local installations.

1. **Open Remix IDE**:

   - Go to [Remix IDE](https://remix.ethereum.org) in your web browser.

2. **Create a New File**:

   - In the `File Explorers` tab, create a new file named `AdvancedAuction.sol`.

3. **Copy and Paste**:

   - Copy the Solidity contract code provided above and paste it into the `AdvancedAuction.sol` file in Remix.

4. **Compile the Contract**:

   - Navigate to the `Solidity Compiler` tab and click on `Compile AdvancedAuction.sol`.

5. **Deploy the Contract**:

   - Switch to the `Deploy & Run Transactions` tab.
   - Make sure `Environment` is set to `JavaScript VM`.
   - Click on `Deploy` to deploy your contract to the simulated blockchain.

6. **Interact with the Contract**:

   - Once deployed, the contract will appear under `Deployed Contracts`.
   - Use the buttons provided to interact with the contract's functions like `startAuction`, `bid`, `finalizeAuction`, and `withdraw`.

7. **Testing**:
   - You can test various functionalities directly from the Remix interface by simulating transactions and observing the outputs and state changes.

## Contributing

Contributions are welcome! Please feel free to submit issues, suggestions, or improvements via GitHub. Your feedback and contributions are valued as we aim to improve the contract's functionality and security.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
