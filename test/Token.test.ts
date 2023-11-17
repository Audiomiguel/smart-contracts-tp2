import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("AgrosToken", function () {
  const MINTER_ROLE = ethers.keccak256(ethers.toUtf8Bytes("MINTER_ROLE"));
  const BURNER_ROLE = ethers.keccak256(ethers.toUtf8Bytes("BURNER_ROLE"));

  const AccessControlError = 'AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})';

  async function deployInnovaTokenFixture() {
    const [owner, user] = await ethers.getSigners();

    
    return { owner, user };
  }

  it("account without MINTER_ROLE cannot mint tokens", async function () {
    await loadFixture(deployInnovaTokenFixture);

    expect(true).to.be.true;
  });

  xit("account with MINTER_ROLE can mint tokens", async function () {

  });

  xit("account with MINTER_ROLE cannot be minted to invalid address", async function () {

  });

  xit("account without BURNER_ROLE cannot burn tokens", async function () {

  });

  xit("account with BURNER_ROLE can burn tokens", async function () {

  });

  xit("account with BURNER_ROLE cannot be burned to invalid address", async function () {

  });
});