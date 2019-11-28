const { default: CITASDK } = require("@cryptape/cita-sdk");

const config = require("./config");
require('dotenv').config();

var cita; // config.chain indicates that the address of CITA to interact

console.log("It working in " + process.env.REACT_APP_RUNTIME);
if (process.env.REACT_APP_RUNTIME === "cyton") {
  cita = CITASDK(window.cita.currentProvider);
  cita.currentProvider.setHost(config.chain);
} else {
  cita = CITASDK(config.chain);
  const account = cita.base.accounts.privateKeyToAccount(config.privateKey); // create account by private key from config
  cita.base.accounts.wallet.add(account); // add account to cita
}

module.exports = cita;
