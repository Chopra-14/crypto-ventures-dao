import { ethers } from "hardhat";

async function main() {
  const [deployer, member1, member2, member3] =
    await ethers.getSigners();

  console.log("Seeding DAO state...");
  console.log("Members:");
  console.log("Member1:", member1.address);
  console.log("Member2:", member2.address);
  console.log("Member3:", member3.address);

  /*//////////////////////////////////////////////////////////////
                        LOAD DEPLOYED CONTRACTS
  //////////////////////////////////////////////////////////////*/

  const governanceToken = await ethers.getContractAt(
    "GovernanceToken",
    process.env.GOVERNANCE_TOKEN_ADDRESS!
  );

  const governanceDAO = await ethers.getContractAt(
    "GovernanceDAO",
    process.env.GOVERNANCE_DAO_ADDRESS!
  );

  /*//////////////////////////////////////////////////////////////
                        STAKE ETH
  //////////////////////////////////////////////////////////////*/

  await governanceToken.connect(member1).stake({
    value: ethers.parseEther("5"),
  });

  await governanceToken.connect(member2).stake({
    value: ethers.parseEther("3"),
  });

  await governanceToken.connect(member3).stake({
    value: ethers.parseEther("1"),
  });

  console.log("Members staked ETH");

  /*//////////////////////////////////////////////////////////////
                      CREATE PROPOSAL
  //////////////////////////////////////////////////////////////*/

  const tx = await governanceDAO
    .connect(member1)
    .createProposal(
      0, // HIGH_CONVICTION
      "Invest in Layer-2 scaling project"
    );

  const receipt = await tx.wait();
  const proposalId = receipt!.logs[0].args[0];

  console.log("Proposal created with ID:", proposalId.toString());

  /*//////////////////////////////////////////////////////////////
                          CAST VOTES
  //////////////////////////////////////////////////////////////*/

  await governanceDAO.connect(member1).vote(proposalId, 1); // FOR
  await governanceDAO.connect(member2).vote(proposalId, 1); // FOR
  await governanceDAO.connect(member3).vote(proposalId, 0); // AGAINST

  console.log("Votes cast");

  console.log("✅ DAO state seeded successfully");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
