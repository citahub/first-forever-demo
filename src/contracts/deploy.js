const cita = require("../cita-sdk");
const { abi, bytecode } = require(".compiled.js");
const config = require("../config");

const account = cita.base.accounts.privateKeyToAccount(config.privateKey); // create account by private key from config

cita.base.accounts.wallet.add(account); // add account to cita

let transaction = require("./transaction");

transaction = {
  ...transaction,
  from: cita.base.accounts.wallet[0].address
};

let _contractAddress = "";
// contract contract instance
const myContract = new cita.base.Contract(abi);

cita.base
  .getBlockNumber()
  .then(current => {
    transaction.validUntilBlock = +current + 88; // update transaction.validUntilBlock
    // deploy contract
    return myContract
      .deploy({
        data: bytecode,
        arguments: []
      })
      .send(transaction);
  })
  .then(txRes => {
    if (txRes.hash) {
      // get transaction receipt
      return cita.listeners.listenToTransactionReceipt(txRes.hash);
    } else {
      throw new Error("No Transaction Hash Received");
    }
  })
  .then(res => {
    const { contractAddress, errorMessage } = res;
    if (errorMessage) throw new Error(errorMessage);
    console.log(`contractAddress is: ${contractAddress}`);
    _contractAddress = contractAddress;
    return cita.base.storeAbi(contractAddress, abi, transaction); // store abi on the chain
  })
  .then(res => {
    if (res.errorMessage) throw new Error(res.errorMessage);
    return cita.base.getAbi(_contractAddress, "pending").then(console.log); // get abi from the chain
  })
  .catch(err => console.error(err));
