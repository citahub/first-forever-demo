const appchain = require('../appchain')
const transaction = {
  // from: appchain.base.accounts.wallet[0].address,
  // privateKey: appchain.base.accounts.wallet[0].privateKey,
  nonce: 999999,
  quota: 1000000,
  chainId: 1,
  version: 1,
  validUntilBlock: 999999,
  value: '0x0',
}

module.exports = transaction
