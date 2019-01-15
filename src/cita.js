const {
  default: CITASDK
} = require('@cryptape/cita-sdk')

const config = require('./config')

const cita = CITASDK(config.chain) // config.chain indicates that the address of CITA to interact

console.log('It working in ' + process.env.REACT_APP_RUNTIME)
if (process.env.REACT_APP_RUNTIME === 'web') {
  const account = cita.base.accounts.privateKeyToAccount(config.privateKey) // create account by private key from config
  cita.base.accounts.wallet.add(account) // add account to cita
}

module.exports = cita
