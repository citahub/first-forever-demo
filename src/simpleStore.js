const cita = require('./cita-sdk')
const {
  abi
} = require('./build/contracts/SimpleStoreV2');
const {
  contractAddress
} = require('./config')

const transaction = require('./contracts/transaction')
const simpleStoreContract = new cita.base.Contract(abi, contractAddress)
module.exports = {
  transaction,
  simpleStoreContract,
}
