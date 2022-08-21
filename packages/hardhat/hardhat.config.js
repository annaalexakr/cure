require('@nomiclabs/hardhat-waffle')
require('hardhat-deploy')
require('@nomiclabs/hardhat-ethers')
require('@nomiclabs/hardhat-etherscan')
require('hardhat-gas-reporter')

if (process.env.PROD_ENV == null) {
  // only update env manually if not already updated (eg by netlify)
  require('dotenv').config({ path: '.env.local' })
}

const INFURA_API_KEY = process.env.INFURA_API_KEY || ''
const MAINNET_PRIVATE_KEY =
    process.env.MAINNET_PRIVATE_KEY ||
    ''
const GOERLI_PRIVATE_KEY =
    process.env.GOERLI_PRIVATE_KEY ||
    ''
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY

task('accounts', 'Prints the list of accounts', async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners()

  for (const account of accounts) {
    console.log(account.address)
  }
})

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  namedAccounts: {
    deployer: 0,
    creator: 1,
    voter: 2, // votes on NFTs, either up or down
    granter: 3 // either harvests or prunes NFTs
  },
  networks: {
    hardhat: {
      chainId: 1337,
      mining: {
        auto: true,
        interval: 10000
      },
      allowUnlimitedContractSize: true,
      initialBaseFeePerGas: 0 // https://github.com/sc-forks/solidity-coverage/issues/652
    },
    rinkeby: {
      url: `https://gerli.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [GOERLI_PRIVATE_KEY],
      gasPrice: 10000000000
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [MAINNET_PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY
  },
  gasReporter: {
    currency: 'USD',
    gasPrice: 21
  }
}
