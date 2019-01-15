const cita = require('../cita')
const {
  abi,
  bytecode
} = require('./compiled.js')

const transaction = require('./transaction')
let _contractAddress = ''
// contract contract instance
const myContract = new cita.base.Contract(abi)

cita.base
  .getBlockNumber()
  .then(current => {
    transaction.validUntilBlock = +current + 88 // update transaction.validUntilBlock
    // deploy contract
    return myContract
      .deploy({
        data: bytecode,
        arguments: [],
      })
      .send(transaction)
  })
  .then(txRes => {
    if (txRes.hash) {
      // get transaction receipt
      return cita.listeners.listenToTransactionReceipt(txRes.hash)
    } else {
      throw new Error('No Transaction Hash Received')
    }
  })
  .then(res => {
    const {
      contractAddress,
      errorMessage
    } = res
    if (errorMessage) throw new Error(errorMessage)
    console.log(`contractAddress is: ${contractAddress}`)
    _contractAddress = contractAddress
    return cita.base.storeAbi(contractAddress, abi, transaction) // store abi on the chain
  })
  .then(res => {
    if (res.errorMessage) throw new Error(res.errorMessage)
    return cita.base.getAbi(_contractAddress, 'pending').then(console.log) // get abi from the chain
  })
  .catch(err => console.error(err))
