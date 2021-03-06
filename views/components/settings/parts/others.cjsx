{$, $$, _, React, ReactBootstrap, FontAwesome, ROOT, POI_VERSION, CONST} = window
{Grid, Col, Button, ButtonGroup, Input} = ReactBootstrap
Divider = require './divider'
path = require 'path-extra'
{openExternal} = require 'shell'

Others = React.createClass
  openLink: (lnk, e) ->
    openExternal lnk
    e.preventDefault()
  render: ->
    <div id='poi-others'>
      <Grid>
        <Col xs={12}>
          <img src="file://#{ROOT}/assets/img/logo.png" style={width: '100%'} />
          <p>poi v{POI_VERSION} 基于 Electron v{process.versions.electron} 和 React.js 开发，是一个开源的跨平台舰队 Collection 浏览器。poi 的游戏行为与 Chrome 一致，原则上不提供任何影响收发包的功能。poi 仅提供基本浏览器功能，扩展功能请等待插件开发。</p>
          <p>微博: <a onClick={@openLink.bind(@, 'http://weibo.com/letspoi')}> @ 今天 poi 出新版本了吗 </a></p>
          <p>开发讨论与意见交流群: 378320628 </p>
          <p>poi 掉落数据统计:<a onClick={@openLink.bind(@, 'http://db.kcwiki.moe')}> http://db.kcwiki.moe </a></p>
          <p>更多帮助与指南查看 poi wiki: <a onClick={@openLink.bind(@, 'https://github.com/poooi/poi/wiki')}> https://github.com/poooi/poi/wiki </a></p>
          <p>GitHub：<a onClick={@openLink.bind(@, 'https://github.com/poooi/poi')}> https://github.com/poooi/poi </a></p>
        </Col>
      </Grid>
      <Divider text="Contributors" />
      <Grid>
      {
        for e, i in CONST.contributors
          <Col xs={2} key={i}>
            <img className="avatar-img" src={e.avatar} onClick={@openLink.bind(@, e.link)} title={e.name} />
          </Col>
      }
      </Grid>
    </div>

module.exports = Others
