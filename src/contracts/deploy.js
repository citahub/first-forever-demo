const appchain = require('../appchain')
const {
  abi,
  bytecode
} = require('./compiled.js')

let transaction = require('./transaction')

// add transaction sender address
transaction = {
  ...transaction,
  from: window.neuron.getAccount(),
}

let _contractAddress = ''
// contract contract instance
const myContract = new appchain.base.Contract(abi)

appchain.base
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
      return appchain.listeners.listenToTransactionReceipt(txRes.hash)
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
    return appchain.base.storeAbi(contractAddress, abi, transaction) // store abi on the chain
  })
  .then(res => {
    if (res.errorMessage) throw new Error(res.errorMessage)
    return appchain.base.getAbi(_contractAddress, 'pending').then(console.log) // get abi from the chain
  })
  .catch(err => console.error(err))
