import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with account:", deployer.address);

  // 1. GovernanceToken (NO constructor args)
  const GovernanceToken = await ethers.getContractFactory("GovernanceToken");
  const token = await GovernanceToken.deploy();
  await token.waitForDeployment();
  console.log("GovernanceToken deployed to:", token.target);

  // 2. Roles (REQUIRES admin address)
  const Roles = await ethers.getContractFactory("Roles");
  const roles = await Roles.deploy(deployer.address);
  await roles.waitForDeployment();
  console.log("Roles deployed to:", roles.target);

  // 3. ProposalTypes (NO args)
  const ProposalTypes = await ethers.getContractFactory("ProposalTypes");
  const proposalTypes = await ProposalTypes.deploy();
  await proposalTypes.waitForDeployment();
  console.log("ProposalTypes deployed to:", proposalTypes.target);

  // 4. Delegation (NO args)
  const Delegation = await ethers.getContractFactory("Delegation");
  const delegation = await Delegation.deploy();
  await delegation.waitForDeployment();
  console.log("Delegation deployed to:", delegation.target);

  // 5. TimelockController (delay, guardian)
  const TimelockController = await ethers.getContractFactory("TimelockController");
  const timelock = await TimelockController.deploy(
    60,                 // delay (seconds)
    deployer.address    // guardian
  );
  await timelock.waitForDeployment();
  console.log("TimelockController deployed to:", timelock.target);

  // 6. GovernanceDAO (ONLY timelock address)
  const GovernanceDAO = await ethers.getContractFactory("GovernanceDAO");
  const dao = await GovernanceDAO.deploy(timelock.target);
  await dao.waitForDeployment();
  console.log("GovernanceDAO deployed to:", dao.target);

  // 7. Treasury (DAO address)
  const Treasury = await ethers.getContractFactory("Treasury");
  const treasury = await Treasury.deploy(dao.target);
  await treasury.waitForDeployment();
  console.log("Treasury deployed to:", treasury.target);

  console.log("✅ All contracts deployed successfully");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
