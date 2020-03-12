import React from 'react'
import Submit from '../../components/Submit'
import BottomNav from '../../components/BottomNav'
import './add.css'
import {
  transaction,
  simpleStoreContract
} from '../../simpleStore'
import cita from '../../cita-sdk'

const timeFormatter = time => ('' + time).padStart(2, '0')
const {
  REACT_APP_RUNTIME
} = process.env

const submitTexts = {
  normal: '愿此刻永恒',
  submitting: '保存中',
  submitted: '保存成功',
}

class Add extends React.Component {
  state = {
    text: '',
    time: new Date(),
    submitText: submitTexts.normal,
    errorText: '',
  }
  handleInput = e => {
    this.setState({
      text: e.target.value,
    })
  }
  handleSubmit = e => {
    const {
      time,
      text
    } = this.state
    cita.base
      .getBlockNumber()
      .then(current => {
        const tx = {
          ...transaction,
          validUntilBlock: +current + 88,
        }
        tx.from =
          REACT_APP_RUNTIME === 'web' ?
            cita.base.accounts.wallet[0].address :
            REACT_APP_RUNTIME === 'cita-web-debugger' ?
              cita.base.defaultAccount :
              REACT_APP_RUNTIME === 'cyton' ?
                window.cyton.getAccount() : ''
        this.setState({
          submitText: submitTexts.submitting,
        })
        return simpleStoreContract.methods.add(text, +time, 'text').send(tx)
      })
      .then(res => {
        if (res.hash) {
          return cita.listeners.listenToTransactionReceipt(res.hash).then(receipt => {
            if (!receipt.errorMessage) {
              this.setState({
                submitText: submitTexts.submitted
              })
            } else {
                alert(receipt.errorMessage)
                this.props.history.push('/');
            }
          })
        } else {
            alert("Transaction send failed")
            this.props.history.push('/');
        }
      })
  }
  render() {
    const { time, text, submitText, errorText } = this.state
    return (
      <div className="add__content--container">
        <div className="add__time--container">
          <span className="add__time--year"> {time.getFullYear()} </span>:{' '}
          <span className="add__time--month"> {timeFormatter((time.getMonth() + 1) % 12)} </span>:{' '}
          <span className="add__time--day"> {timeFormatter(time.getDate())} </span>:{' '}
          <span className="add__time--hour"> {timeFormatter(time.getHours())} </span>:{' '}
          <span className="add__time--min"> {timeFormatter(time.getMinutes())} </span>{' '}
        </div>
        <div className="add__content--prompt">
          <svg className="icon" aria-hidden="true">
            <use xlinkHref="#icon-icon-time" />
          </svg>{' '}
          <span> 把你觉得重要的一刻， 存放在链上， 永远保存， 随时查看 </span>{' '}
        </div>{' '}
        <textarea
          cols="32"
          rows="10"
          className="add__content--textarea"
          placeholder="留下你的时光吧..."
          onChange={this.handleInput}
          value={text}
        />{' '}
        <Submit text={submitText} onClick={this.handleSubmit} disabled={submitText !== submitTexts.normal} />{' '}
        {errorText && <span className="warning"> {errorText} </span>} <BottomNav showAdd={false} />{' '}
      </div>
    )
  }
}
export default Add
