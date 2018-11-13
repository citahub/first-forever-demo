const {
  default: AppChain
} = require('@appchain/base')

const config = require('./config')

const appchain = AppChain(config.chain) // config.chain indicates that the address of Appchain to interact
const account = appchain.base.accounts.privateKeyToAccount(config.privateKey) // create account by private key from config

appchain.base.accounts.wallet.add(account) // add account to appchain

module.exports = appchain
