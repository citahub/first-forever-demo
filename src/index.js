import React from 'react'
import ReactDOM from 'react-dom'
import './index.css'
import App from './App'
import * as cita from './cita-sdk'

const {
    REACT_APP_RUNTIME
} = process.env

if (REACT_APP_RUNTIME === 'web' || REACT_APP_RUNTIME === 'cyton') {
    ReactDOM.render(<App /> , document.getElementById('root'))
} else if (REACT_APP_RUNTIME === 'cita-web-debugger') {
  window.addEventListener('citaWebDebuggerReady', () => {
    window.addMessenger(cita)
    ReactDOM.render( <App /> , document.getElementById('root'))
  })
}
