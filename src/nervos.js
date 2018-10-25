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
// if (window) {
//   window.addEventListener("neuronWebReady", () => {
//     if (window.addMessenger) {
//       window.addMessenger(nervos)
//     }
//   })
// }

// add neruon provider
if (typeof window.nervos !== 'undefined') {
  window.nervos = Nervos(window.nervos.currentProvider)
  window.nervos.currentProvider.setHost('localhost:1337') // set CITA node IP address and port
} else {
  console.log('No nervos? You should consider trying Neuron!')
  window.nervos = Nervos(config.chain)
}
var nervos = window.nervos

module.exports = nervos
