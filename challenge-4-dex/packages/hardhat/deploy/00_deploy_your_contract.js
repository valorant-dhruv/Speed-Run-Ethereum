// deploy/00_deploy_your_contract.js

const { ethers } = require("hardhat");

const localChainId = "31337";

// const sleep = (ms) =>
//   new Promise((r) =>
//     setTimeout(() => {
//       console.log(`waited for ${(ms / 1000).toFixed(3)} seconds`);
//       r();
//     }, ms)
//   );

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  //Now we deploy the Balloons smart contract with the help of the deployer
  //The deployer got 1000 balloon tokens
  await deploy("Balloons", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    // args: [ "Hello", ethers.utils.parseEther("1.5") ],
    log: true,
  });

  const balloons = await ethers.getContract("Balloons", deployer);

  await deploy("DEX", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    args: [balloons.address],
    log: true,
    waitConfirmations: 5,
  });

  const dex = await ethers.getContract("DEX", deployer);

  //This is the frontend address
  const frontend="0x10a2f2EfFFE8446933A7fA104b7B3ffD120e7dBc";

  // paste in your front-end address here to get 10 balloons on deploy:
  // Here all these functions are called by the deployer address only
  // That is why we are able to transfer 10 balloon from the deployer address as the msg.sender to the frontend address
  await balloons.transfer(
    frontend,
    "" + 10 * 10 ** 18
  );

  // // uncomment to init DEX on deploy:
  console.log(
    "Approving DEX (" + dex.address + ") to take Balloons from main account..."
  );
  // If you are going to the testnet make sure your deployer account has enough ETH
  // This basically transfer 5 balloon tokens and 5 ethers from the deployer address to the dex smart contract
  await balloons.approve(dex.address, ethers.utils.parseEther("100"));
  console.log("INIT exchange...");
  await dex.init(ethers.utils.parseEther("0.1"), {
    value: ethers.utils.parseEther("0.1"),
    gasLimit: 200000,
  });
};
module.exports.tags = ["Balloons", "DEX"];
