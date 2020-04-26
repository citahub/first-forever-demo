const { default: CITASDK } = require("@cryptape/cita-sdk");
const web3 = require("web3");
const config = require("./config");
require("dotenv").config();

var cita; // config.chain indicates that the address of CITA to interact

const REACT_APP_RUNTIME = process.env.REACT_APP_RUNTIME;
console.log("It working in " + REACT_APP_RUNTIME);
if (process.env.REACT_APP_RUNTIME === "cyton") {
  cita = CITASDK(window.cita.currentProvider);
  cita.currentProvider.setHost(config.chain);
} else if (process.env.REACT_APP_RUNTIME === "webRandomPk") {
  cita = CITASDK(config.chain);
  const pk = initRandomPK();
  const account = cita.base.accounts.privateKeyToAccount(pk); // create account by private key from random

  cita.base.accounts.wallet.add(account); // add account to cita
} else {
  cita = CITASDK(config.chain);
  const account = cita.base.accounts.privateKeyToAccount(config.privateKey); // create account by private key from config
  cita.base.accounts.wallet.add(account); // add account to cita
}

function initRandomPK() {
  if (!window.localStorage.getItem("webRandomPk")) {
    const pk = new web3().eth.accounts.create(web3.utils.randomHex(32))
      .privateKey;
    window.localStorage.setItem("webRandomPk", pk);
  }
  return window.localStorage.getItem("webRandomPk");
}

// get account's address
cita.getFromAddress = function() {
  return REACT_APP_RUNTIME === "web" || REACT_APP_RUNTIME === "webRandomPk"
    ? cita.base.accounts.wallet[0].address
    : REACT_APP_RUNTIME === "cita-web-debugger"
    ? cita.base.defaultAccount
    : REACT_APP_RUNTIME === "cyton"
    ? window.cyton.getAccount()
    : "";
};
module.exports = cita;
