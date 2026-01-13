import { expect } from "chai";
import { ethers } from "hardhat";

describe("Delegation", function () {
  it("allows delegation and revocation", async () => {
    const [user1, user2] = await ethers.getSigners();
    const Delegation = await ethers.getContractFactory("Delegation");
    const delegation = await Delegation.deploy();

    await delegation.connect(user1).delegate(user2.address);
    expect(await delegation.delegatedTo(user1.address)).to.equal(
      user2.address
    );

    await delegation.connect(user1).revokeDelegation();
    expect(await delegation.delegatedTo(user1.address)).to.equal(
      ethers.ZeroAddress
    );
  });

  it("prevents circular delegation", async () => {
    const [user1, user2] = await ethers.getSigners();
    const Delegation = await ethers.getContractFactory("Delegation");
    const delegation = await Delegation.deploy();

    await delegation.connect(user1).delegate(user2.address);
    await expect(
      delegation.connect(user2).delegate(user1.address)
    ).to.be.reverted;
  });
});
