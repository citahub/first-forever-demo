const cita = require("../cita-sdk");

const {
  abi,
  contractAddress
} = require("../build/contracts/UpgradableManager");

const UpdateManagerContract = new cita.base.Contract(abi, contractAddress);

UpdateManagerContract.methods
  .implementation()
  .call()
  .then(address =>
    UpdateManagerContract.methods.delegateNames(address)
      .call()
      .then(name => console.log('\x1b[33m%s\x1b[0m', `\ncurrent: ${name}: ${address}`))
  );
UpdateManagerContract.methods
  .getVersions()
  .call()
  .then(versions => console.log(`version:\n${versions.map(v => v).join(',\n')}`));
