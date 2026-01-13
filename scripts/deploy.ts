import { ethers } from "hardhat";

async function main() {
  const [deployer, proposer, executor, guardian] = await ethers.getSigners();

  console.log("Deploying contracts with account:", deployer.address);

  /*//////////////////////////////////////////////////////////////
                        DEPLOY GOVERNANCE TOKEN
  //////////////////////////////////////////////////////////////*/
  const GovernanceToken = await ethers.getContractFactory("GovernanceToken");
  const governanceToken = await GovernanceToken.deploy();
  await governanceToken.waitForDeployment();

  console.log("GovernanceToken deployed to:", await governanceToken.getAddress());

  /*//////////////////////////////////////////////////////////////
                          DEPLOY ROLES
  //////////////////////////////////////////////////////////////*/
  const Roles = await ethers.getContractFactory("Roles");
  const roles = await Roles.deploy(deployer.address);
  await roles.waitForDeployment();

  console.log("Roles deployed to:", await roles.getAddress());

  /*//////////////////////////////////////////////////////////////
                      DEPLOY PROPOSAL TYPES
  //////////////////////////////////////////////////////////////*/
  const ProposalTypes = await ethers.getContractFactory("ProposalTypes");
  const proposalTypes = await ProposalTypes.deploy();
  await proposalTypes.waitForDeployment();

  console.log("ProposalTypes deployed to:", await proposalTypes.getAddress());

  /*//////////////////////////////////////////////////////////////
                        DEPLOY DELEGATION
  //////////////////////////////////////////////////////////////*/
  const Delegation = await ethers.getContractFactory("Delegation");
  const delegation = await Delegation.deploy();
  await delegation.waitForDeployment();

  console.log("Delegation deployed to:", await delegation.getAddress());

  /*//////////////////////////////////////////////////////////////
                      DEPLOY GOVERNANCE DAO
  //////////////////////////////////////////////////////////////*/
  const GovernanceDAO = await ethers.getContractFactory("GovernanceDAO");
  const governanceDAO = await GovernanceDAO.deploy(
    await governanceToken.getAddress(),
    await proposalTypes.getAddress(),
    await delegation.getAddress(),
    await roles.getAddress()
  );
  await governanceDAO.waitForDeployment();

  console.log("GovernanceDAO deployed to:", await governanceDAO.getAddress());

  /*//////////////////////////////////////////////////////////////
                      DEPLOY TIMELOCK CONTROLLER
  //////////////////////////////////////////////////////////////*/
  const TimelockController = await ethers.getContractFactory(
    "TimelockController"
  );
  const timelock = await TimelockController.deploy(await roles.getAddress());
  await timelock.waitForDeployment();

  console.log("TimelockController deployed to:", await timelock.getAddress());

  /*//////////////////////////////////////////////////////////////
                          DEPLOY TREASURY
  //////////////////////////////////////////////////////////////*/
  const Treasury = await ethers.getContractFactory("Treasury");
  const treasury = await Treasury.deploy(await governanceDAO.getAddress());
  await treasury.waitForDeployment();

  console.log("Treasury deployed to:", await treasury.getAddress());

  /*//////////////////////////////////////////////////////////////
                        ASSIGN ROLES
  //////////////////////////////////////////////////////////////*/
  const PROPOSER_ROLE = await roles.PROPOSER_ROLE();
  const EXECUTOR_ROLE = await roles.EXECUTOR_ROLE();
  const GUARDIAN_ROLE = await roles.GUARDIAN_ROLE();

  await roles.grantRole(PROPOSER_ROLE, proposer.address);
  await roles.grantRole(EXECUTOR_ROLE, executor.address);
  await roles.grantRole(GUARDIAN_ROLE, guardian.address);

  console.log("Roles assigned");

  /*//////////////////////////////////////////////////////////////
                        FUND TREASURY BUCKETS
  //////////////////////////////////////////////////////////////*/
  const HIGH_CONVICTION = 0;
  const EXPERIMENTAL = 1;
  const OPERATIONAL = 2;

  await treasury.deposit(HIGH_CONVICTION, {
    value: ethers.parseEther("10"),
  });

  await treasury.deposit(EXPERIMENTAL, {
    value: ethers.parseEther("5"),
  });

  await treasury.deposit(OPERATIONAL, {
    value: ethers.parseEther("2"),
  });

  console.log("Treasury funded");

  console.log("✅ Deployment complete");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
