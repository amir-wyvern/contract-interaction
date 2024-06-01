/* global ethers */
/* eslint prefer-const: "off" */

async function deployDiamond () {
  const accounts = await ethers.getSigners()
  const contractOwner = accounts[0]
  
  const backContractOBJ = await ethers.getContractFactory("BackContract");
  const backContract = await backContractOBJ.deploy();
  await backContract.deployed();
  console.log("BackContract deployed to:", backContract.address);

  const proxyContractOBJ = await ethers.getContractFactory("ProxyContract");
  const proxyContract = await proxyContractOBJ.deploy(backContract.address);
  await proxyContract.deployed();
  console.log("proxyContract deployed to:", proxyContract.address);
 
}

if (require.main === module) {
  deployDiamond()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deployDiamond = deployDiamond