const cita = require("../cita-sdk");
let transaction = require("./transaction");
const path = require("path");
const location = process.argv.slice(2)[0];
const {
  contractAddress: upgradeAddress,
  abi: upgradeAbi
} = require(path.resolve(location));
// const from = cita.base.accounts.wallet[0].address;
const {
  abi,
  contractAddress
} = require("../build/contracts/UpgradableManager");

const UpdateManagerContract = new cita.base.Contract(abi, contractAddress);

cita.base
  .getBlockNumber()
  .then(height => {
    transaction.validUntilBlock = height + 80;
  })
  .then(() => {
    UpdateManagerContract.methods.upgradeTo(upgradeAddress).send(transaction).then(hash => console.log(hash))
  })
  .then(() => {
    cita.base.storeAbi(contractAddress, upgradeAbi, transaction).then(console.log);
  })
  .catch(console.error);
