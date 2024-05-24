/* global ethers task */
// require('./node_modules-tmp/@nomiclabs/hardhat-waffle/dist/src')
require("@nomiclabs/hardhat-waffle");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task('accounts', 'Prints the list of accounts', async () => {
  const accounts = await ethers.getSigners()

  for (const account of accounts) {
    console.log(account.address)
  }
})

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: '0.8.19',
  settings: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  },

  networks: {
    custom: {
      url: '',
      accounts: [],
    },
  },
  gasReporter: {
    enabled: true
  },
sourcify: {
  // Disabled by default
  // Doesn't need an API key
  enabled: true
}
}
