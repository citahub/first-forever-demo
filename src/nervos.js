const {
  default: Nervos
} = require('@nervos/chain')

const config = require('./config')

const nervos = Nervos(config.chain) // config.chain indicates that the address of Appchain to interact

// NOTICE:
// this account used to deploy contract, when build the front - end app it should be removed
//
// const account = nervos.appchain.accounts.privateKeyToAccount(config.privateKey) // create account by private key from config
// nervos.appchain.accounts.wallet.add(account) // add account to nervos

// add neuron web messenger from chrome
if (window) {
  window.addEventListener("neuronWebReady", () => {
    if (window.addMessenger) {
      window.addMessenger(nervos)
    }
  })
}

module.exports = nervos
