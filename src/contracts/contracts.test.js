const cita = require('../cita')
const {
  abi
} = require('./compiled')
const {
  contractAddress
} = require('../config')
const transaction = require('./transaction')

const simpleStoreContract = new cita.base.Contract(abi, contractAddress) // instantiate contract

cita.base.getBalance(cita.base.accounts.wallet[0].address).then(console.log) // check balance of account
console.log(`Interact with contract at ${contractAddress}`)
const time = new Date().getTime()
const text = 'hello world at ' + time

test(`Add record of (${text}, ${time})`, async () => {
  const current = await cita.base.getBlockNumber()
  transaction.validUntilBlock = +current + 88 // update transaction.validUntilBlock
  const txResult = await simpleStoreContract.methods.add(text, time).send(transaction) // sendTransaction to the contract
  const receipt = await cita.listeners.listenToTransactionReceipt(txResult.hash) // listen to the receipt
  expect(receipt.errorMessage).toBeNull()
}, 10000)

test(`Get record of (${text}, ${time})`, (done) => {
  setTimeout(async () => {
    const list = await simpleStoreContract.methods.getList().call({
      from: transaction.from,
    }) // check list
    const msg = await simpleStoreContract.methods.get(time).call({
      from: transaction.from,
    }) // check message
    expect(+list[list.length - 1]).toBe(time)
    expect(msg).toBe(text)
    done()
  }, 8000)
}, 10000)
