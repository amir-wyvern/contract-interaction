/* global ethers */
/* eslint prefer-const: "off" */

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')

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

  // deploy facets
  console.log('')
  console.log('Deploying facets')
  const FacetNames = [
    'PermissionManagement',
    'DiamondCutFacet',
    'DiamondLoupeFacet',
    'OwnershipFacet'
  ]
  const cut = []
  for (const FacetName of FacetNames) {
    const Facet = await ethers.getContractFactory(FacetName)
    const facet = await Facet.deploy()
    await facet.deployed()
    console.log(`${FacetName} deployed: ${facet.address}`)
    cut.push({
      facetAddress: facet.address,
      action: FacetCutAction.Add,
      functionSelectors: getSelectors(facet)
    })
  }

  // upgrade diamond with facets
  console.log('')
  console.log('Diamond Cut:', cut)
  const infraFund = await ethers.getContractFactory("InfraFund");
  const infra_fund = await infraFund.deploy(cut, contractOwner.address);
  await infra_fund.deployed();
  console.log("InfraFund deployed to:", infra_fund.address);
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