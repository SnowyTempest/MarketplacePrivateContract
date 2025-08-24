# Data Marketplace MVP

A decentralized data marketplace built on the Stacks blockchain that enables secure buying and selling of private datasets with built-in privacy guarantees and reputation management.

## 🎯 Overview

This MVP demonstrates core blockchain concepts for data monetization:
- **Secure Data Trading**: Buy and sell datasets with automated payments
- **Privacy Certification**: Built-in privacy level verification
- **Reputation System**: Trust scores for data providers
- **Access Control**: Granular permissions for purchased data

## 🚀 Features

### Core Marketplace
- ✅ Create data listings with metadata
- ✅ Purchase data with automatic payment splitting
- ✅ Privacy level certification (Basic, Enhanced, Maximum)
- ✅ User reputation tracking
- ✅ Access control for purchased data

### Smart Contract Features
- 🔐 **Secure Payments**: Automatic fee distribution to sellers and platform
- 🏆 **Reputation System**: 5-star rating system with score averaging
- 🛡️ **Privacy Compliance**: Privacy method tracking and certification
- ⚡ **Gas Optimized**: Single contract deployment for cost efficiency

## 📋 Contract Functions

### Public Functions

#### For Data Sellers
```clarity
;; Create a new data listing
(create-listing title description price privacy-level privacy-method)

;; Toggle listing active/inactive
(toggle-listing listing-id)
```

#### For Data Buyers
```clarity
;; Purchase access to a dataset
(purchase-data listing-id)

;; Rate a data seller (1-5 stars)
(rate-seller seller-principal rating)
```

#### For Contract Owner
```clarity
;; Update marketplace fee (max 5%)
(set-fee new-fee-basis-points)
```

### Read-Only Functions
```clarity
;; Get listing details
(get-listing listing-id)

;; Get user profile and reputation
(get-profile user-principal)

;; Check if user has access to data
(has-access listing-id buyer-principal)

;; Get privacy certification
(get-privacy-cert listing-id)

;; Get marketplace statistics
(get-marketplace-stats)
```

## 🛠️ Technical Details

### Privacy Levels
- **Level 1 (Basic)**: K-anonymity, basic data masking
- **Level 2 (Enhanced)**: Differential privacy techniques
- **Level 3 (Maximum)**: Homomorphic encryption, zero-knowledge proofs

### Fee Structure
- Default marketplace fee: **2.5%**
- Maximum allowed fee: **5%**
- Fees automatically distributed on each purchase

### Reputation System
- Initial reputation: **100 points**
- Rating scale: **1-5 stars** (converted to 20-100 point scale)
- Reputation increases with successful sales (+5 points per sale)
- Ratings are averaged with current reputation score

## 🚀 Getting Started

### Prerequisites
- [Clarinet](https://docs.hiro.so/clarinet) for local development
- [Stacks Wallet](https://wallet.hiro.so/) for testnet deployment
- Basic understanding of Clarity smart contracts

### Local Development

1. **Clone and Setup**
   ```bash
   git clone <your-repo>
   cd data-marketplace-mvp
   clarinet new marketplace
   ```

2. **Add Contract**
   ```bash
   # Copy the contract code to contracts/marketplace.clar
   clarinet check
   ```

3. **Run Tests**
   ```bash
   clarinet console
   ```

4. **Deploy to Testnet**
   ```bash
   clarinet integrate
   ```

### Example Usage

```clarity
;; Create a listing
(contract-call? .marketplace create-listing 
  "Customer Demographics" 
  "Anonymized customer data with geographic distribution" 
  u1000000  ;; 1 STX
  u2        ;; Enhanced privacy
  "differential-privacy")

;; Purchase data
(contract-call? .marketplace purchase-data u1)

;; Rate the seller
(contract-call? .marketplace rate-seller 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u5)
```

## 📊 Use Cases

### For Data Providers
- **Healthcare**: Anonymized patient data for research
- **Finance**: Market sentiment and trading patterns
- **IoT**: Sensor data from smart devices
- **Social Media**: Engagement metrics and user behavior

### For Data Buyers
- **Researchers**: Academic studies requiring large datasets
- **ML Engineers**: Training data for machine learning models
- **Analysts**: Market research and competitive intelligence
- **Developers**: Real-world data for application testing

## 🔐 Security Considerations

- **Privacy First**: All data must include privacy certification
- **Access Control**: Buyers only get access after payment
- **Immutable Records**: All transactions recorded on blockchain
- **Reputation Incentives**: Quality encouraged through rating system

## 🛣️ Roadmap

### Phase 2 - Enhanced Features
- [ ] Data samples and previews
- [ ] Advanced search and filtering
- [ ] Dispute resolution system
- [ ] Data quality verification

### Phase 3 - Business Logic
- [ ] Dynamic pricing mechanisms
- [ ] Subscription-based access
- [ ] Bulk purchase discounts
- [ ] API integration for data delivery

### Phase 4 - Ecosystem
- [ ] Multi-chain deployment
- [ ] Oracle integration
- [ ] Governance token
- [ ] Advanced analytics dashboard

## 💡 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Development Guidelines
- Follow Clarity best practices
- Add comprehensive tests for new features
- Update documentation for public functions
- Ensure gas optimization for all operations

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Support

- **Documentation**: [Stacks Docs](https://docs.stacks.co/)
- **Community**: [Discord](https://discord.gg/stacks)
- **Issues**: GitHub Issues for bug reports
- **Discussions**: GitHub Discussions for questions

## 🏆 Acknowledgments

- Built for educational purposes and blockchain bootcamp
- Inspired by decentralized data economy principles
- Powered by Stacks blockchain and Clarity smart contracts

---

**⚠️ Disclaimer**: This is an MVP for educational purposes. Not audited for production use. Always conduct thorough security reviews before deploying to mainnet.