import { expect } from "chai";
import { ethers } from "hardhat";

describe("Marketplace Tests", function () {
  // const [owner, otherAccount] = await ethers.getSigners();
  
  async function deployMarketplace() {

    const Marketplace = await ethers.getContractFactory("Marketplace");
    const marketplace = await Marketplace.deploy();

    return marketplace;
  }
});
