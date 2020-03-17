const cita = require("../cita-sdk");
const { simpleStoreContract } = require("../simpleStore");
const { contractAddress } = require("../config");
let transaction = require("./transaction");
// const {contractAddress: upgradeAddress, abi: upgradeAbi} = require("../build/contracts/SimpleStoreV2");
const {contractAddress: upgradeAddress, abi: upgradeAbi} = require("../build/contracts/SimpleStoreV2");
const from = cita.base.accounts.wallet[0].address;

cita.base
  .getBlockNumber()
  .then(height => {
    transaction.validUntilBlock = height + 80;
  })
  .then(() => {
    simpleStoreContract.methods
      .upgradeTo(upgradeAddress)
      .call({
        from
      });
  })
  .then(() => {
    console.log(transaction);
    cita.base.storeAbi(contractAddress, upgradeAbi, transaction);
  })
  .catch(console.error);
