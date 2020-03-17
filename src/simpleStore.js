const cita = require("./cita-sdk");
const { abi, contractAddress } = require("./build/contracts/UpgradableManager");

const transaction = require("./contracts/transaction");
const simpleStoreContract = new cita.base.Contract(abi, contractAddress);
module.exports = {
  transaction,
  simpleStoreContract
};
