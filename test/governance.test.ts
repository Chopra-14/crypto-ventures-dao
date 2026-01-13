import { expect } from "chai";
import { ethers } from "hardhat";

describe("GovernanceDAO", function () {
  it("does not queue proposal if quorum is not met", async function () {
    const [owner, user] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("GovernanceToken");
    const token = await Token.deploy();
    await token.waitForDeployment();

    const Timelock = await ethers.getContractFactory("TimelockController");
    const timelock = await Timelock.deploy(60, owner.address);
    await timelock.waitForDeployment();

    const DAO = await ethers.getContractFactory("GovernanceDAO");
    const dao = await DAO.deploy(timelock.target);
    await dao.waitForDeployment();

    await token.connect(user).stake({ value: ethers.parseEther("0.1") });

    await dao.connect(user).createProposal();
    await dao.connect(user).vote(1, 1); // ✅ FIX

    await expect(
      dao.queue(1)
    ).to.be.revertedWith("Quorum not met");
  });
});
