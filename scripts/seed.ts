import dotenv from "dotenv";
dotenv.config();

import { ethers } from "hardhat";

async function main() {
  /*//////////////////////////////////////////////////////////////
                        ENV VALIDATION
  //////////////////////////////////////////////////////////////*/

  console.log("Loaded addresses:");
  console.log("GovernanceToken:", process.env.GOVERNANCE_TOKEN_ADDRESS);
  console.log("GovernanceDAO:", process.env.GOVERNANCE_DAO_ADDRESS);

  if (
    !process.env.GOVERNANCE_TOKEN_ADDRESS ||
    !process.env.GOVERNANCE_DAO_ADDRESS
  ) {
    throw new Error("❌ Missing contract addresses in .env file");
  }

  /*//////////////////////////////////////////////////////////////
                          SIGNERS
  //////////////////////////////////////////////////////////////*/

  const [deployer, member1, member2, member3] =
    await ethers.getSigners();

  console.log("Seeding DAO state...");
  console.log("Member1:", member1.address);
  console.log("Member2:", member2.address);
  console.log("Member3:", member3.address);

  /*//////////////////////////////////////////////////////////////
                    LOAD DEPLOYED CONTRACTS
  //////////////////////////////////////////////////////////////*/

  const governanceToken = await ethers.getContractAt(
    "GovernanceToken",
    process.env.GOVERNANCE_TOKEN_ADDRESS
  );

  const governanceDAO = await ethers.getContractAt(
    "GovernanceDAO",
    process.env.GOVERNANCE_DAO_ADDRESS
  );

  /*//////////////////////////////////////////////////////////////
                          STAKE ETH
  //////////////////////////////////////////////////////////////*/

  await (await governanceToken.connect(member1).stake({
    value: ethers.parseEther("5"),
  })).wait();

  await (await governanceToken.connect(member2).stake({
    value: ethers.parseEther("3"),
  })).wait();

  await (await governanceToken.connect(member3).stake({
    value: ethers.parseEther("1"),
  })).wait();

  console.log("✅ Members staked ETH");

  /*//////////////////////////////////////////////////////////////
                        CREATE PROPOSAL
        ⚠️ createProposal() TAKES NO ARGUMENTS
  //////////////////////////////////////////////////////////////*/

  await (await governanceDAO.connect(member1).createProposal()).wait();

  const proposalId = await governanceDAO.proposalCount();

  console.log("✅ Proposal created with ID:", proposalId.toString());

  /*//////////////////////////////////////////////////////////////
                            CAST VOTES
  //////////////////////////////////////////////////////////////*/

  await (await governanceDAO.connect(member1).vote(proposalId, 1)).wait(); // FOR
  await (await governanceDAO.connect(member2).vote(proposalId, 1)).wait(); // FOR
  await (await governanceDAO.connect(member3).vote(proposalId, 0)).wait(); // AGAINST

  console.log("✅ Votes cast");

  console.log("🎉 DAO state seeded successfully");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
