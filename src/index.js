import React from 'react'
import ReactDOM from 'react-dom'
import './index.css'
import App from './App'
import registerServiceWorker from './registerServiceWorker'
import appchain from './appchain'

window.addEventListener('neuronWebReady', () => {
  window.addMessenger(appchain)
  ReactDOM.render(<App />, document.getElementById('root'))
})

setTimeout(() => {
  if (!window.addMessenger) {
    window.console.warn('Neuron Web Not Detected')
    ReactDOM.render(<App />, document.getElementById('root'))
  }
}, 3000)

registerServiceWorker()
