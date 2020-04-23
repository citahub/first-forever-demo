const cita = require("../cita-sdk");
const transaction = {
  nonce: 999999,
  quota: 1000000,
  chainId: "0x1",
  version: 2,
  validUntilBlock: 999999,
  value: "0x0"
};
if (process.env.REACT_APP_RUNTIME === "web" || process.env.REACT_APP_RUNTIME === "webRandomPk") {
  transaction.from = cita.getFromAddress();
  transaction.privateKey = cita.base.accounts.wallet[0].privateKey;
}

module.exports = transaction;
