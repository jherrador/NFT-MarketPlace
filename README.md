# 🛒 NFT-MarketPlace

![Ethereum](https://img.shields.io/badge/Ethereum-Blockchain-3C3C3D?logo=ethereum&logoColor=white)
![Solidity](https://img.shields.io/badge/Solidity-%5E0.8.x-363636?logo=solidity)
![ERC721](https://img.shields.io/badge/Standard-ERC721-blue)
![Marketplace](https://img.shields.io/badge/Type-NFT%20Marketplace-purple)
![License](https://img.shields.io/badge/License-Unlicensed-lightgrey)

NFT-MarketPlace is a decentralized marketplace built in Solidity that allows users to trade **ERC721 NFTs** securely on Ethereum.

Users can:

- List NFTs for sale
- Cancel active listings
- Purchase listed NFTs
- Pay marketplace fees (fixed listing fee + percentage-based sales fee)

The platform collects:
- A fixed fee per listing
- A percentage fee on each completed sale

This project demonstrates core marketplace mechanics such as listing management, secure NFT transfers, and automated fee distribution.

---

## 🧠 Project Overview

NFT-MarketPlace enables peer-to-peer NFT trading while enforcing marketplace rules via smart contracts.

### Core Marketplace Flow:

1. User lists an ERC721 NFT for sale.
2. A listing fee is paid to the marketplace.
3. NFT is approved for marketplace transfer.
4. Another user purchases the NFT.
5. Marketplace deducts a percentage fee.
6. Seller receives payment minus the marketplace fee.
7. NFT is transferred to the buyer.

The contract ensures secure transfers and proper fee accounting.

---

## 🏗️ Core Features

### 🖼️ NFT Listing
- Supports ERC721 tokens
- Seller defines sale price
- Listing fee required to create listing

### ❌ Cancel Listing
- Seller can cancel an active listing before sale

### 💰 NFT Purchase
- Buyers can purchase listed NFTs
- Smart contract verifies correct payment
- Ownership transferred automatically

### 🏦 Marketplace Fee System
- Fixed listing fee
- Percentage-based fee on completed sales
- Revenue collected by the platform

---

## 📦 Project Structure

```text
.
├── .github/
├── lib/
├── script/
├── src/
└── test/
```

- `src/` — Marketplace smart contracts
- `test/` — Unit tests
- `script/` — Deployment scripts
- `lib/` — Dependencies

---

## 🛠 Tech Stack

- **Solidity**
- **ERC721**
- **Foundry**
- **Forge**
- **Ethereum**

---

## 🚀 Getting Started

### Prerequisites

- Foundry installed

---

## 🧪 Build & Test

### Compile contracts

```bash
forge build
```

### Run tests

```bash
forge test
```

---

## 🧪 Example Marketplace Flow

1. Seller approves the marketplace contract to transfer their NFT.
2. Seller calls the listing function and pays the listing fee.
3. NFT becomes available for purchase.
4. Buyer calls the buy function and sends the required ETH.
5. Marketplace deducts percentage fee.
6. Seller receives payment.
7. NFT is transferred to buyer.
8. Seller may cancel listing before sale.

---

## ⚠️ Important Notes

- Only ERC721 tokens are supported.
- Correct payment is required to complete purchase.
- Listings can be canceled before sale.
- Marketplace fees are automatically enforced by the contract.

---

## 🔮 Future Integrations & Enhancements

The marketplace can evolve with additional features such as:

### 💳 Multi-Crypto Payments
- Accept payments in ERC20 tokens (USDC, DAI, WETH)
- Allow sellers to choose preferred payment token

### 📈 Royalty Support (ERC2981)
- Automatic royalty payments to NFT creators

### 🔁 Auctions & Bidding
- Timed auctions
- Highest bid mechanism
- Reserve price support

### 🧾 Escrow & Secure Settlement
- Time-locked settlement options
- Dispute resolution mechanisms

---

## 👤 Author

Developed by **Javier Herrador** as part of his Solidity and Web3 development journey.