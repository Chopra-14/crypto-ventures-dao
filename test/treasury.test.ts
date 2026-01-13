import { expect } from "chai";
import { ethers } from "hardhat";

describe("Treasury", function () {
  it("prevents transfer if insufficient funds", async function () {
    const [owner, user] = await ethers.getSigners();

    const Treasury = await ethers.getContractFactory("Treasury");
    const treasury = await Treasury.deploy(owner.address);
    await treasury.waitForDeployment();

    await expect(
      treasury.transferFunds(user.address, ethers.parseEther("1"))
    ).to.be.revertedWith("Insufficient treasury balance"); // ✅ FIX
  });

  it("allows DAO to transfer funds", async function () {
    const [owner, user] = await ethers.getSigners();

    const Treasury = await ethers.getContractFactory("Treasury");
    const treasury = await Treasury.deploy(owner.address);
    await treasury.waitForDeployment();

    await owner.sendTransaction({
      to: treasury.target,
      value: ethers.parseEther("1"),
    });

    const before = await ethers.provider.getBalance(user.address);

    await treasury.transferFunds(user.address, ethers.parseEther("0.5"));

    const after = await ethers.provider.getBalance(user.address);

    expect(after).to.be.gt(before);
  });
});
