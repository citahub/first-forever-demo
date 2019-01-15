const cita = require('../cita')
const transaction = {
<<<<<<< HEAD
  from: cita.base.accounts.wallet[0].address,
  privateKey: cita.base.accounts.wallet[0].privateKey,
=======
  // from: appchain.base.accounts.wallet[0].address,
  // privateKey: appchain.base.accounts.wallet[0].privateKey,
>>>>>>> neuron-web
  nonce: 999999,
  quota: 1000000,
  chainId: 1,
  version: 1,
  validUntilBlock: 999999,
  value: '0x0',
}

module.exports = transaction
