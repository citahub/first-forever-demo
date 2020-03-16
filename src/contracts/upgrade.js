const cita = require("../cita-sdk");
const { simpleStoreContract } = require("../simpleStore");
const { contractAddress } = require("../config");
let transaction = require("./transaction");
const { abi: v2abi } = require("../build/contracts/SimpleStoreV2");
const { abi: v1abi } = require("../build/contracts/SimpleStore");
const from = cita.base.accounts.wallet[0].address;

cita.base
  .getBlockNumber()
  .then(height => {
    transaction.validUntilBlock = height + 80;
  })
  .then(() => {
    simpleStoreContract.methods
      .upgradeTo("0xB9B42feBcB70BDd3b45E890fF4fa27B18F3C100A")
      .call({
        from
      });
  })
  .then(() => {
    console.log(transaction);
    cita.base.storeAbi(contractAddress, v1abi, transaction);
  })
  .catch(console.error);
