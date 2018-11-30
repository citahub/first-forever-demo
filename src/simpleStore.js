const appchain = require('./appchain')
const {
  abi
} = require('./contracts/compiled.js')
const {
  contractAddress
} = require('./config')

const transaction = require('./contracts/transaction')
const simpleStoreContract = new appchain.base.Contract(abi, contractAddress)
module.exports = {
  transaction,
  simpleStoreContract,
}
