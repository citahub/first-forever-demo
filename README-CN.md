# First Forever

[English](./README.md) | 简体中文

本 demo 展示在 CITA 上开发一个 MVP DApp 的完整流程。

我们提供三种方式：

- [运行在 PC 和移动浏览器](#运行在PC和移动浏览器)：在 `.env` 设置 `REACT_APP_RUNTIME=web`
- [集成 cita-web-debugger 运行](#集成cita-web-debugger运行)： 在 `.env` 设置`REACT_APP_RUNTIME=cita-web-debugger`
- [集成 Cyton Wallet App 运行](#集成CytonWalletApp运行)：在 `.env` 设置 `REACT_APP_RUNTIME=cyton`

> 注意: 开发者应具备编译开发 webapp 的能力，并了解区块链和智能合约的基础知识。

操作步骤示意图：

![](https://raw.githubusercontent.com/cryptape/first-forever-demo/develop/doc/steps.png)

开始前需安装 [node.js](https://nodejs.org)。

# 运行在 PC 和移动浏览器

与智能合约的交互有：

- 在智能合约中存储 Text：`sendTransaction`；

- 从智能合约获取 TextList：`call`

- 从智能合约获取 Text：`call`

最终项目目录如下所示：

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

# 开始

## 1. 使用 Scaffold

本 Demo 需使用 `create-react-app` 构建，所以需安装 `create-react-app` scffold

> 注意: 本 demo 用 create-react-app 构建，并支持现有浏览器，如果需要 es5 版本，可弹出 scaffold，在 `.babelrc` 添加 `@babel/preset-es2015`

初始化项目

```shell
$ yarn create react-app first-forever && cd first-forever
```

项目结构为：

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

## 2. 添加 DApp 组件

此部分即 webapp 开发，开发完成后会添加 [Route](https://github.com/cryptape/first-forever-demo/blob/develop/src/Routes.jsx), [Containers](https://github.com/cryptape/first-forever-demo/tree/develop/src/containers) and [Components](https://github.com/cryptape/first-forever-demo/tree/develop/src/components)

```shell
└── src
    ├── Routes.jsx
    ├── components
    └── containers
```

本 demo 包括 4 个页面:

- [Homepage](https://github.com/cryptape/first-forever-demo/tree/develop/src/containers/Home/index.jsx)
- [AddMemo](https://github.com/cryptape/first-forever-demo/tree/develop/src/containers/Add/index.jsx)
- [MemoList](https://github.com/cryptape/first-forever-demo/tree/develop/src/containers/List/index.jsx)
- [Memo](https://github.com/cryptape/first-forever-demo/tree/develop/src/containers/Show/index.jsx)

以上即为普通 webapp 开发，接下里进入 DApp 开发。

## 3. 引入 cita-sdk-js

DApp 通过 cita-sdk-js 与 CITA 进行交互，部署 DApp，细节可访问 [@cryptape/cita-sdk](https://www.npmjs.com/package/@cryptape/cita-sdk)

 `yarn add @cryptape/cita-sdk` 之后初始化 `src/cita-sdk.js` 中的 `cita`

```javascript
const { default: CITASDK } = require('@cryptape/cita-sdk')

const config = require('./config')

const cita = CITASDK(config.chain) // config.chain indicates that the address of CITA to interact
const account = cita.base.accounts.privateKeyToAccount(config.privateKey) // create account by private key from config

cita.base.accounts.wallet.add(account) // add account to cita

module.exports = cita
```

## 4. 编写并调试智能合约

本 DApp 使用了非常简单的智能合约 -- [SimpleStore](https://github.com/cryptape/first-forever-demo/tree/master/src/contracts/SimpleStore.sol).

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

智能合约可通过 [CITA-IDE](https://appchain-ide.cryptape.com/)在线编译并调试

![remix](https://cdn.cryptape.com/docs/images/remix.png)

点击右侧面板 `Detail` ，展示编译详情

![remix](https://cdn.cryptape.com/docs/images/remix_detail.png)

编译生成的 **bytecode** 和 **abi** 会在 demo 中使用：

**bytecode** 用于部署 contract ，**abi** 用于初始化交互的合约实例。

### 部署和测试智能合约

在 `src` 下创建目录

```
├── contracts
│   ├── SimpleStore.sol
│   ├── compiled.js
│   ├── contracts.test.js
│   ├── deploy.js
│   └── transaction.js
```

- 保存 SimpleStore 代码 [SimpleStore.sol](https://github.com/cryptape/first-forever-demo/tree/master/src/contracts/SimpleStore.sol)

- 保存 **bytecode** 和 **abi** [compiled.js](https://github.com/cryptape/first-forever-demo/tree/master/src/contracts/compiled.js)

- 保存交易模板 [transaction.js](https://github.com/cryptape/first-forever-demo/tree/master/src/contracts/transaction.js)

  ```javascript
  const cita = require('../cita')
  const transaction = {
    from: cita.base.accounts.wallet[0].address,
    privateKey: cita.base.accounts.wallet[0].privateKey,
    nonce: '123abcXYZ',
    quota: 1000000,
    chainId: 1,
    version: 1,
    validUntilBlock: 999999,
    value: '0x0',
  }

  module.exports = transaction
  ```

- 保存部署脚本 [deploy.js](https://github.com/cryptape/first-forever-demo/tree/master/src/contracts/deploy.js)

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

- 保存测试脚本 [contracts.test.js](https://github.com/cryptape/first-forever-demo/tree/develop/src/contracts/contracts.test.js)

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

- 在 [package.json](https://github.com/cryptape/first-forever-demo/tree/develop/package.json) 中添加部署和测试脚本

  ```json
  "scripts": {
    "deploy": "node ./src/contracts/deploy.js",
    "test:contract": "jest ./src/contracts/contracts.test.js"
  }
  ```

- 创建 `src/config.js`, 添加私钥和 chain IP。

  ```shell
  $ cp src/config.js.example src/config.js
  ```

- 部署智能合约

  ```shell
  $ npm run deploy
  ```

- 在 config.js 中添加合约地址并测试，最终 config.js 如下所示：

  ```javascript
  const config = {
    chain: '{addr of net you are using}',
    privateKey: '{your private key}',
    contractAddress: '{deployed contract address}',
  }
  module.exports = config
  ```

## 将智能合约集成进 DApp

### 初始化智能合约

初始化智能合约 [simpleStore.js](https://github.com/cryptape/first-forever-demo/tree/develop/src/simpleStore.js)

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

### 在 AddMemo 页面，添加 `myContract.add`

在提交按钮上绑定如下方法 `src/containers/Add/index.jsx`
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

在 mount 加载 memos `src/containers/List/index.jsx`

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

在 mount 加载 memo `src/containers/Show/index.jsx`

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

开启本地服务器，启动 DApp `npm start` 。

![first forever](https://cdn.cryptape.com/docs/images/ff_1.png)
![first forever](https://cdn.cryptape.com/docs/images/ff_2.png)
![first forever](https://cdn.cryptape.com/docs/images/ff_3.png)
![first forever](https://cdn.cryptape.com/docs/images/ff_4.png)

# 集成 cita-web-debugger 运行

[cita-web-debugger](https://github.com/cryptape/cita.js/tree/develop/packages/cita-web-debugger) 是一个浏览器插件，用于在浏览器上做交易调试。

## 集成 cita-web-debugger ，从 CITA SDK 移除 Account

```javascript
// src/cita.js

const { default: CITASDK } = require('@cryptape/cita-sdk')

const config = require('./config')

const cita = CITASDK(config.chain) // config.chain indicates that the address of CITA to interact
const account = cita.base.accounts.privateKeyToAccount(config.privateKey) // create account by private key from config

// cita.base.accounts.wallet.add(account) // add account to cita
window.addEventListener('citaWebDebuggerReady', () => {
  if (window.addMessenger) {
    window.addMessenger(cita)
  }
})

module.exports = cita
```

## 集成 cita-web-debugger 之后，Render App

```javascript
// src/index.js

window.addEventListener('citaWebDebuggerReady', () => {
  setTimeout(() => {
    ReactDOM.render(<App />, document.getElementById('root'))
  }, 10)
})
```

## 从 Transaction Template 中删除与 Account 相关的字段

```javascript
// src/contracts/transaction.js

const cita = require('../cita')
const transaction = {
  // from: cita.base.accounts.wallet[0].address,
  // privateKey: cita.base.accounts.wallet[0].privateKey,
  nonce: '123abcXYZ',
  quota: 1000000,
  chainId: 1,
  version: 1,
  validUntilBlock: 999999,
  value: '0x0',
}

module.exports = transaction
```

## 从 cita-web-debugger 中获取默认 Account

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

之后 first-forever-demo 可与 cita-web-debugger 集成运行。

# 集成 Cyton Wallet App 运行

Cyton 是开源的区块链钱包，支持 CITA 和 Ethereum，包括 Android 版和 iOS 版: [Android](https://github.com/cryptape/cyton-android) and [iOS](https://github.com/cryptape/cyton-ios)。

只需更新少量代码即可适配 Cyton (Android & iOS)。

## 添加 manifest.json 并在 html link tag 中设置 manifest 路径

CITA DApp 需要通过 manifest.json 文件传给 Cyton Wallet 一些区块链信息，包括 chain name、chain id、node httpprovider 等。

我们提供了 manifest.json 的示例，建议放在项目根目录中。
如果有链，应在 chain set 中设置多对 chain id 和 node httpprovider。

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

在 html link tag 中设置 manifest.json 路径

```html
<link rel="manifest" href="%PUBLIC_URL%/manifest.json" />
```

## 集成 Cyton 后 从 CITA SDK 中移除 Account

更新 `cita-sdk.js`.

```javascript
const { default: CITASDK } = require('@cryptape/cita-sdk')

// Cyton will provider cita object to dapp browser and dapp just update currentProivder and host
if (typeof window.cita !== 'undefined') {
  window.cita = CITASDK(window.cita.currentProvider)
  window.cita.currentProvider.setHost(config.chain)
} else {
  console.log('No cita? You should consider trying Cyton!')
  window.cita = CITASDK(config.chain)
}
var cita = window.cita

module.exports = cita
```

## 从 Transaction Template 中移除 Account 相关的字段

```javascript
// src/contracts/transaction.js

const cita = require('../cita')
const transaction = {
  nonce: '123abcXYZ',
  quota: 1000000, // 10000 or 0xffff
  chainId: 1,
  version: 1,
  validUntilBlock: 999999,
  value: '0x0',
}

module.exports = transaction
```

## 从 Cyton App 中获取默认 Account

```javascript
// src/containers/add/index.jsx

const tx = {
  ...transaction,
  from: window.cyton.getAccout(),
  validUntilBlock: +current + 88,
}
```

```javascript
// src/containers/List/index.jsx

// const from = cita.base.accounts.wallet[0] ? cita.base.accounts.wallet[0].address : ''
const from = window.cyton.getAccout()
```

```javascript
// src/containers/Show/index.jsx

// from: cita.base.accounts.wallet[0].address,
from: window.cyton.getAccout(),
```

之后 first-forever-demo 可集成 Cyton Wallet App 运行。

若 Android 版有任何问题，可在 Chrome 浏览器调试，并输入 `chrome://inspect`。

若需调试 iOS 版本，可在 Safari 浏览器中调试。

> 注意: 调试时需下载 Cyton Wallet Android 或 iOS 的项目并安装，构建。
