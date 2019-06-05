# First Forever

This demo shows the entire process of building a MVP Dapp on cita.

We provider three situations：

- [run in PC and mobile browser directly](#run-in-pc-and-mobile-browser): set `REACT_APP_RUNTIME=web` in `.env`
- [run in neuronWeb](#run-in-neuronweb): set `REACT_APP_RUNTIME=cita-web-debugger` in `.env`
- [run in neuron wallet App](#run-in-neuron-wallet-app): set `REACT_APP_RUNTIME=cyton` in `env`

> Notice: This tutorial is for the developers who is able to build webapps and has basic knowledge of Blockchain and Smart Contract.

Before you start a tour, you may need to install [node.js](https://nodejs.org) firstly.

# Run in PC and mobile browser

All interactions with Smart Contract are:

- Store Text in Smart Contract: a `sendTransaction` action;

- Get TextList from Smart Contract: a `call` action;

- Get Text from Smart Contract: a `call` action;

The final project looks like

```shell
├── README.md
├── package.json
├── public
│   ├── favicon.ico
│   ├── index.html
│   └── manifest.json
├── src
│   ├── App.css
│   ├── App.js
│   ├── App.test.js
│   ├── Routes.jsx
│   ├── components
│   ├── config.js.example
│   ├── containers
│   ├── contracts
│   ├── index.css
│   ├── index.js
│   ├── logo.svg
│   ├── cita.js
│   ├── public
│   ├── registerServiceWorker.js
│   └── simpleStore.js
└── yarn.lock
```

# Getting Started

## 1. Use Scaffold for Project

This Demo use `create-react-app` to start the project, so you need the `create-react-app` scaffold firstly

> Notice: This demo is created by create-react-app and supported by modern browser. If es5 version needed, just eject the scaffold and add `@babel/preset-es2015` in `.babelrc`

```shell
$ yarn global add create-react-app
```

After that the project can be initiated by

```shell
$ create-react-app first-forever && cd first-forever
```

Now the project looks like

```shell
├── README.md
├── package.json
├── public
│   ├── favicon.ico
│   ├── index.html
│   └── manifest.json
└── src
    ├── App.css
    ├── App.js
    ├── App.test.js
    ├── index.css
    ├── index.js
    ├── logo.svg
    ├── public
    └── registerServiceWorker.js
```

## 2. Add Components of the Dapp

This step is very familiar to webapp developers, [Route](https://github.com/cryptape/first-forever-demo/blob/develop/src/Routes.jsx), [Containers](https://github.com/cryptape/first-forever-demo/tree/develop/src/containers) and [Components](https://github.com/cryptape/first-forever-demo/tree/develop/src/components) will be added to the Dapp

```shell
└── src
    ├── Routes.jsx
    ├── components
    └── containers
```

The Route indicates that the demo has 4 pages:

- [Homepage](https://github.com/cryptape/first-forever-demo/tree/develop/src/containers/Home/index.jsx)
- [AddMemo](https://github.com/cryptape/first-forever-demo/tree/develop/src/containers/Add/index.jsx)
- [MemoList](https://github.com/cryptape/first-forever-demo/tree/develop/src/containers/List/index.jsx)
- [Memo](https://github.com/cryptape/first-forever-demo/tree/develop/src/containers/Show/index.jsx)

All above are just traditional webapp development, and next we are going to dapp development.

## 3. cita.js

This step instructs how to have a Dapp running on Nervos cita.

The Dapp interacts with CITA by the `cita.js` and details of `cita` can be accessed at [@cryptape/cita-sdk](https://www.npmjs.com/package/@cryptape/cita-sdk)

In order to use cita.js, add cita-sdk as other packages by yarn `yarn add @cryptape/cita-sdk`, and then instantiate `cita` in `src/cita.js`.

```javascript
const { default: CITASDK } = require('@cryptape/cita-sdk')

const config = require('./config')

const cita = CITASDK(config.chain) // config.chain indicates that the address of CITA to interact
const account = cita.base.accounts.privateKeyToAccount(config.privateKey) // create account by private key from config

cita.base.accounts.wallet.add(account) // add account to cita

module.exports = cita
```

## 4. Smart Contract

This Dapp works with an extremely simple smart contract -- [SimpleStore](https://github.com/cryptape/first-forever-demo/tree/master/src/contracts/SimpleStore.sol).

```solidity
pragma solidity 0.4.24;

contract SimpleStore {
    mapping (address => mapping (uint256 => string)) private records;
    mapping (address => uint256[]) private categories;

    event Recorded(address _sender, string indexed _text, uint256 indexed _time);

    function _addToList(address from, uint256 time) private {
        categories[from].push(time);
    }

    function getList()
    public
    view
    returns (uint256[])
    {
        return categories[msg.sender];
    }

    function add(string text, uint256 time) public {
        records[msg.sender][time]=text;
        _addToList(msg.sender, time);
        emit Recorded(msg.sender, text, time);
    }
    function get(uint256 time) public view returns(string) {

        return records[msg.sender][time];
    }
}
```

Smart Contract can be debugged on [CITA-IDE](https://appchain-ide.cryptape.com/), an online solidity debugger

![remix](https://cdn.cryptape.com/docs/images/remix.png)

By clicking on `Detail` in the right-side panel, compiled details will show as follow

![remix](https://cdn.cryptape.com/docs/images/remix_detail.png)

In details, **bytecode** and **abi** will be used in this demo.

**bytecode** is used to deploy the contract, and **abi** is used to instantiate a contract instance for interacting.

### Deploy and Test the Contract

Create directory in `src`

```
├── contracts
│   ├── SimpleStore.sol
│   ├── compiled.js
│   ├── contracts.test.js
│   ├── deploy.js
│   └── transaction.js
```

- Store SimpleStore Source Code in [SimpleStore.sol](https://github.com/cryptape/first-forever-demo/tree/master/src/contracts/SimpleStore.sol)

- Store **bytecode** and **abi** in [compiled.js](https://github.com/cryptape/first-forever-demo/tree/master/src/contracts/compiled.js)

- Store transaction template in [transaction.js](https://github.com/cryptape/first-forever-demo/tree/master/src/contracts/transaction.js)

  ```javascript
  const cita = require('../cita')
  const transaction = {
    from: cita.base.accounts.wallet[0].address,
    privateKey: cita.base.accounts.wallet[0].privateKey,
    nonce: '123abcXYZ',
    quota: 1000000,
    chainId: 1,
    version: 2,
    validUntilBlock: 999999,
    value: '0x0',
  }

  module.exports = transaction
  ```

- Store deploy script in [deploy.js](https://github.com/cryptape/first-forever-demo/tree/master/src/contracts/deploy.js)

  ```javascript
  const cita = require('../cita')
  const { abi, bytecode } = require('./compiled.js')

  const transaction = require('./transaction')
  let _contractAddress = ''
  // contract contract instance
  const myContract = new cita.base.Contract(abi)

  cita.base
    .getBlockNumber()
    .then(current => {
      transaction.validUntilBlock = +current + 88 // update transaction.validUntilBlock
      // deploy contract
      return myContract
        .deploy({
          data: bytecode,
          arguments: [],
        })
        .send(transaction)
    })
    .then(txRes => {
      if (txRes.hash) {
        // get transaction receipt
        return cita.listeners.listenToTransactionReceipt(txRes.hash)
      } else {
        throw new Error('No Transaction Hash Received')
      }
    })
    .then(res => {
      const { contractAddress, errorMessage } = res
      if (errorMessage) throw new Error(errorMessage)
      console.log(`contractAddress is: ${contractAddress}`)
      _contractAddress = contractAddress
      return cita.base.storeAbi(contractAddress, abi, transaction) // store abi on the chain
    })
    .then(res => {
      if (res.errorMessage) throw new Error(res.errorMessage)
      return cita.base.getAbi(_contractAddress).then(console.log) // get abi from the chain
    })
    .catch(err => console.error(err))
  ```

- Store test script in [contracts.test.js](https://github.com/cryptape/first-forever-demo/tree/develop/src/contracts/contracts.test.js)

  ```javascript
  const cita = require('../cita')
  const { abi } = require('./compiled')
  const { contractAddress } = require('../config')
  const transaction = require('./transaction')

  const simpleStoreContract = new cita.base.Contract(abi, contractAddress) // instantiate contract

  cita.base.getBalance(cita.base.accounts.wallet[0].address).then(console.log) // check balance of account
  console.log(`Interact with contract at ${contractAddress}`)
  const time = new Date().getTime()
  const text = 'hello world at ' + time

  test(`Add record of (${text}, ${time})`, async () => {
    const current = await cita.base.getBlockNumber()
    transaction.validUntilBlock = +current + 88 // update transaction.validUntilBlock
    const txResult = await simpleStoreContract.methods.add(text, time).send(transaction) // sendTransaction to the contract
    const receipt = await cita.listeners.listenToTransactionReceipt(txResult.hash) // listen to the receipt
    expect(receipt.errorMessage).toBeNull()
  }, 10000)

  test(`Get record of (${text}, ${time})`, async () => {
    const list = await simpleStoreContract.methods.getList().call({
      from: transaction.from,
    }) // check list
    const msg = await simpleStoreContract.methods.get(time).call({
      from: transaction.from,
    }) // check message
    expect(+list[list.length - 1]).toBe(time)
    expect(msg).toBe(text)
  }, 3000)
  ```

- Add deploy and test script in [package.json](https://github.com/cryptape/first-forever-demo/tree/develop/package.json)

  ```json
  "scripts": {
    "deploy": "node ./src/contracts/deploy.js",
    "test:contract": "jest ./src/contracts/contracts.test.js"
  }
  ```

- Create `src/config.js`, set private key and chain ip in it.

  ```shell
  $ cp src/config.js.example src/config.js
  ```

- Deploy the contract

  ```shell
  $ npm run deploy
  ```

- Add contract address to config.js and test

  For now the `config.js` should be like:

  ```javascript
  const config = {
    chain: '{addr of net you are using}',
    privateKey: '{your private key}',
    contractAddress: '{deployed contract address}',
  }
  module.exports = config
  ```

## Integrate Contract into Dapp

### Instantiate Contract

Instantiate Contract in [simpleStore.js](https://github.com/cryptape/first-forever-demo/tree/develop/src/simpleStore.js) under `src`

```javascript
const cita = require('./cita')
const { abi } = require('./contracts/compiled.js')
const { contractAddress } = require('./config')

const transaction = require('./contracts/transaction')
const simpleStoreContract = new cita.base.Contract(abi, contractAddress)
module.exports = {
  transaction,
  simpleStoreContract,
}
```

### Add `myContract.add` in AddMemo Page

In `src/containers/Add/index.jsx`, bind the following method to submit button

```javascript
handleSubmit = e => {
  const { time, text } = this.state
  cita.base
    .getBlockNumber()
    .then(current => {
      const tx = {
        ...transaction,
        validUntilBlock: +current + 88,
      }
      this.setState({
        submitText: submitTexts.submitting,
      })
      return simpleStoreContract.methods.add(text, +time).send(tx) // execute add method to store memo in the contract
    })
    .then(res => {
      if (res.hash) {
        return cita.listeners.listenToTransactionReceipt(res.hash)
      } else {
        throw new Error('No Transaction Hash Received')
      }
    })
    .then(receipt => {
      if (!receipt.errorMessage) {
        this.setState({ submitText: submitTexts.submitted })
      } else {
        throw new Error(receipt.errorMessage)
      }
    })
    .catch(err => {
      this.setState({ errorText: JSON.stringify(err) })
    })
}
```

In `src/containers/List/index.jsx`, load memos on mount

```javascript
componentDidMount() {
  const from = cita.base.accounts.wallet[0] ? cita.base.accounts.wallet[0].address : ''
  simpleStoreContract.methods
    .getList()
    .call({
      from,
    })
    .then(times => {
      times.reverse()
      this.setState({ times })
      return Promise.all(times.map(time => simpleStoreContract.methods.get(time).call({ from })))
    })
    .then(texts => {
      this.setState({ texts })
    })
    .catch(console.error)
}
```

In `src/containers/Show/index.jsx`, load memo on mount

```javascript
componentDidMount() {
  const { time } = this.props.match.params
  if (time) {
    simpleStoreContract.methods
      .get(time)
      .call({
        from: cita.base.accounts.wallet[0].address,
      })
      .then(text => {
        this.setState({ time, text })
      })
      .catch(error => this.setState({ errorText: JSON.stringify(error) }))
  } else {
    this.setState({ errorText: 'No Time Specified' })
  }
}
```

As all of these done, start the local server by `npm start` to launch the dapp.

![first forever](https://cdn.cryptape.com/docs/images/ff_1.png)
![first forever](https://cdn.cryptape.com/docs/images/ff_2.png)
![first forever](https://cdn.cryptape.com/docs/images/ff_3.png)
![first forever](https://cdn.cryptape.com/docs/images/ff_4.png)

# Run in neuronWeb

[cita-web-debugger](https://github.com/cryptape/cita.js/tree/develop/packages/cita-web-debugger) is an CITA Web Debugger on Chrome, acts as an CITA Wallet to sign transactions from DApp.

## Integrate NeuronWeb and Remove Account From CITA SDK

```javascript
// src/cita.js

const { default: CITASDK } = require('@cryptape/cita-sdk')

const config = require('./config')

const cita = CITASDK(config.chain) // config.chain indicates that the address of CITA to interact
const account = cita.base.accounts.privateKeyToAccount(config.privateKey) // create account by private key from config

// cita.base.accounts.wallet.add(account) // add account to cita
window.addEventListener('citaWebDebuggerReader', () => {
  if (window.addMessenger) {
    window.addMessenger(cita)
  }
})

module.exports = cita
```

## Render App After NeuronWeb Integration

```javascript
// src/index.js

window.addEventListener('citaWebDebuggerReader', () => {
  setTimeout(() => {
    ReactDOM.render(<App />, document.getElementById('root'))
  }, 10)
})
```

## Remove Account-related Fields From Transaction Template

```javascript
// src/contracts/transaction.js

const cita = require('../cita')
const transaction = {
  // from: cita.base.accounts.wallet[0].address,
  // privateKey: cita.base.accounts.wallet[0].privateKey,
  nonce: '123abcXYZ',
  quota: 1000000,
  chainId: 1,
  version: 2,
  validUntilBlock: 999999,
  value: '0x0',
}

module.exports = transaction
```

## Get Default Account From NeuronWeb

```javascript
// src/containers/add/index.jsx

const tx = {
  ...transaction,
  from: cita.base.defaultAccount,
  validUntilBlock: +current + 88,
}
```

```javascript
// src/containers/List/index.jsx

// const from = cita.base.accounts.wallet[0] ? cita.base.accounts.wallet[0].address : ''
const from = cita.base.defaultAccount
```

```javascript
// src/containers/Show/index.jsx

// from: cita.base.accounts.wallet[0].address,
from: cita.base.defaultAccount,
```

After these modification, first-forever will work with neuronWeb perfectly.

# Run in neuron wallet App

Neuron is a blockchain wallet APP which supports CITA and Ethereum, it contains two platform versions: [Android](https://github.com/cryptape/neuron-android) and [iOS](https://github.com/cryptape/neuron-ios).

You just update little code to adapter Neuron (Android and iOS).

## Add manifest.json and set manifest path in html link tag

An CITA DApp needs to tell Neuron wallet some information of the blockchain through manifest.json file, which contains chain name, chain id, node httpprovider etc.

As follows, we provide an example of manifest.json. In general, we suggest to put manifest.json in root directory of the project.
If you have more than one chain, you should set more pairs of chain id and node httpprovider in chain set.

```javascript
// public/manifest.json

{
  "name": "CITA First Forever",                              // chain name
  "blockViewer": "https://microscope.cryptape.com/",             // blockchain browser
  "chainSet": {                                                 // a set of chainId and node httpprovider
    "1": "https://node.cryptape.com"                            // key is chainId, value is node httpprovider
  },
  "icon": "http://7xq40y.com1.z0.glb.clouddn.com/23.pic.jpg",   // chain icon
  "entry": "https://first-forever.dapp.cryptape.com/",          // DApp entry
  "provider": "https://cryptape.com/"                           // DApp provider
}
```

You should also set path of manifest.json in html file using link tag.

```html
<link rel="manifest" href="%PUBLIC_URL%/manifest.json" />
```

## Integrate Neuron and Remove Account From CITA SDK

Then you also should update `cita.js`.

```javascript
const { default: CITASDK } = require('@cryptape/cita-sdk')

// Neuron will provider cita object to dapp browser and dapp just update currentProivder and host
if (typeof window.cita !== 'undefined') {
  window.cita = CITASDK(window.cita.currentProvider)
  window.cita.currentProvider.setHost(config.chain)
} else {
  console.log('No cita? You should consider trying Neuron!')
  window.cita = CITASDK(config.chain)
}
var cita = window.cita

module.exports = cita
```

## Remove Account-related Fields From Transaction Template

```javascript
// src/contracts/transaction.js

const cita = require('../cita')
const transaction = {
  nonce: '123abcXYZ',
  quota: 1000000, // 10000 or 0xffff
  chainId: 1,
  version: 2,
  validUntilBlock: 999999,
  value: '0x0',
}

module.exports = transaction
```

## Get Default Account From Neuron App

```javascript
// src/containers/add/index.jsx

const tx = {
  ...transaction,
  from: window.neuron.getAccout(),
  validUntilBlock: +current + 88,
}
```

```javascript
// src/containers/List/index.jsx

// const from = cita.base.accounts.wallet[0] ? cita.base.accounts.wallet[0].address : ''
const from = window.neuron.getAccout()
```

```javascript
// src/containers/Show/index.jsx

// from: cita.base.accounts.wallet[0].address,
from: window.neuron.getAccout(),
```

After these modification, first-forever will work with neuron App perfectly.

If you have any mistakes in Android, you can debug in Chrome browser and input `chrome://inspect`.

If you want to debug in iOS , you can debug in Safari browser.

> Note: If you want to debug, you should download Android or iOS neuron project and build , install.
