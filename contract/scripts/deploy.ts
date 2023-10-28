import { ethers } from "hardhat";
import { writeFileSync } from "fs";
import { join } from "path";

async function main() {

  const marketplace = await ethers.deployContract("Marketplace");

  await marketplace.waitForDeployment();

  console.log('Contract deployed to: ', marketplace.target);

  const filepath = join(__dirname, "../../frontend/src/api/constants.ts");
    
    writeFileSync(filepath,
    `
    export const CONTRACT_ADDRESS = "${marketplace.target}";
    // export const NFT_ADDRESS = "${marketplace.target}";
    `);
  }

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

