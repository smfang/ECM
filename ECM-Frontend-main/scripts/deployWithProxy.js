const { ethers, upgrades } = require("hardhat");

// string calldata name, 
// string calldata symbol, 
// string calldata _projectName, 
// address _projectAddress, 
// address _controllerAddress, 
// uint256 _availableCreditsToSell, 
// uint256 _tokenMintPriceInETH

async function main() {
  const CarbonCreditTokenUpgradeable = await ethers.getContractFactory(
    "CarbonCreditTokenUpgradeable"
  );
  console.log("Deploying CarbonCreditToken...");
  const contract = await upgrades.deployProxy(CarbonCreditTokenUpgradeable, ['CarbonCredit', 'CCT', 'TEST', ethers.ZeroAddress, 1000, ethers.parseEther('1')], {
    initializer: "initialize",
    kind: "transparent",
  });
  await contract.deployed();
  console.log("CarbonCreditToken deployed to:", contract.address);
}

main();