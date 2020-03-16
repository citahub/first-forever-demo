import React from 'react'
import cita from '../../cita-sdk'
import BottomNav from '../../components/BottomNav'
import { simpleStoreContract } from '../../simpleStore'
require('./show.css')

const { REACT_APP_RUNTIME } = process.env
class Show extends React.Component {
  state = {
    time: 0,
    message: '',
    errorText: '',
  }

  componentDidMount() {
    const { time } = this.props.match.params
    const from =
      REACT_APP_RUNTIME === 'web'
        ? cita.base.accounts.wallet[0].address
        : REACT_APP_RUNTIME === 'cita-web-debugger'
          ? cita.base.defaultAccount
          : REACT_APP_RUNTIME === 'cyton'
            ? window.cyton.getAccount() : ''
    if (time) {
      simpleStoreContract.methods
        .get(time)
        .call({
          from,
        })
        .then(message => {
          this.setState({ time, message })
        })
        .catch(error => this.setState({ errorText: JSON.stringify(error) }))
    } else {
      this.setState({ errorText: 'No Time Specified' })
    }
  }
  render() {
    const { time, message } = this.state
    const _time = new Date(+time)
    if (!time) {
      return <div style={{ textAlign: 'center' }}>正在加载您的回忆</div>
    }
    return (
      <div className="show__container">
        <span className="show__time">{_time.toLocaleString()}</span>
        {/*<img src="https://picsum.photos/200/100?random" alt="rand_img" className="show__photo" />*/}
        {message.msgType === "image" ? (
            <div className="show__text"><img src={message.msgContent} style={{maxWidth: "100%", marginTop: 8}}/></div>
        ) : (
            <div className="show__text">{message.msgContent}</div>
        )}
        <BottomNav active={'list'} />
      </div>
    )
  }
}
export default Show
