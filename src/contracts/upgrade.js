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
      .upgradeTo("0x948f636f28509b26374a5AaBa8fa315C162Fc082")
      .call({
        from
      });
  })
  .then(() => {
    console.log(transaction);
    cita.base.storeAbi(contractAddress, v1abi, transaction);
  })
  .catch(console.error);
