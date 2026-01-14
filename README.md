# 🏛️ Crypto Ventures DAO

A fully on-chain **Decentralized Autonomous Organization (DAO)** built using **Solidity and Hardhat**, featuring token-based governance, delegation, quorum enforcement, timelock execution, and a treasury system.

This project demonstrates **production-grade DAO architecture**, strong testing practices, and real-world governance mechanics.

---

## 📌 Overview

**Crypto Ventures DAO** enables members to:

- Stake governance tokens to gain voting power  
- Create and vote on proposals  
- Delegate voting power securely  
- Enforce quorum and prevent double voting  
- Execute approved proposals via a timelock  
- Manage funds through a DAO-controlled treasury  

The system emphasizes **security, transparency, and modular design**.

---

## 🧱 Architecture

GovernanceToken
│ (staking → voting power)
▼
GovernanceDAO
│ (proposals, voting, quorum)
▼
TimelockController
│ (delay + guardian control)
▼
Treasury

yaml
Copy code

---

## 🗳️ Governance Model

- Voting power is based on **staked governance tokens**
- Only staked tokens are counted for voting
- Delegation is supported with **circular-delegation protection**
- One address can vote **only once per proposal**
- Treasury actions can only be executed through DAO-approved proposals

---

## 📐 Voting Formula

### Voting Power
votingPower = stakedTokens

shell
Copy code

### Quorum Rule
totalVotes ≥ quorumThreshold

yaml
Copy code

If quorum is not met, the proposal **fails gracefully**.

---

## 🔄 Proposal Lifecycle

1. Proposal is created by a staked member  
2. Members vote (YES / NO)  
3. Quorum is evaluated  
4. Proposal is queued in the Timelock  
5. Mandatory delay is enforced  
6. Proposal is executed (e.g., treasury transfer)  

---

## ⚙️ Setup Instructions

### 1️⃣ Install dependencies
```bash
npm install
2️⃣ Start local blockchain
bash
Copy code
npx hardhat node
3️⃣ Deploy contracts
bash
Copy code
npx hardhat run scripts/deploy.ts --network localhost
4️⃣ Seed demo state (optional)
bash
Copy code
npx hardhat run scripts/seed.ts --network localhost
▶️ Usage Examples
Stake tokens
ts
Copy code
await token.stake({ value: ethers.parseEther("1") });
Create a proposal
ts
Copy code
await dao.createProposal("Fund new Web3 startup");
Vote on a proposal
ts
Copy code
await dao.vote(1, true); // true = YES
Queue proposal
ts
Copy code
await dao.queue(1);
Execute after timelock
ts
Copy code
await timelock.execute(1);
🧪 Testing Instructions
Run the complete test suite:

bash
Copy code
npx hardhat test
Test Coverage Includes
Quorum failure

Tie votes

Zero votes

Double voting prevention

Delegation edge cases

Timelock enforcement

Role restrictions

Treasury underflow protection

✅ All tests are passing.

🔐 Security Considerations
Private keys are never committed

.env is excluded via .gitignore

Timelock prevents instant execution

Treasury access restricted to DAO only

Explicit revert reasons for clarity

Graceful failure handling

📁 Environment Template
Use .env.example:

env
Copy code
RPC_URL=http://127.0.0.1:8545
DEPLOYER_PRIVATE_KEY=private_key_here
⚠️ Never commit real private keys.

🚀 Project Highlights
Realistic DAO governance mechanics

Modular smart contract design

Extensive automated testing

Deployment and state seeding scripts

Portfolio-quality Web3 project

✅ Status
Fully implemented

Fully tested

Evaluation-ready

Portfolio-grade

👤 Author
Chopra Lakshmi Sathvika
