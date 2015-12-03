{_, $, $$, React, ReactBootstrap, FontAwesome} = window
{OverlayTrigger, Tooltip, Label} = ReactBootstrap
{__, __n} = require 'i18n'

StatusLabel = React.createClass
  shouldComponentUpdate: (nextProps, nextState) ->
    not _.isEqual(nextProps.label, @props.label)
  render: ->
    if @props.label? and @props.label == 0
      <OverlayTrigger placement="top" overlay={<Tooltip id="statuslabel-status-0">{__ 'Retreated'}</Tooltip>}>
        <Label bsStyle="danger"><FontAwesome key={0} name='exclamation-circle' /></Label>
      </OverlayTrigger>
    else if @props.label? and @props.label == 1
      <OverlayTrigger placement="top" overlay={<Tooltip id="statuslabel-status-1">{__ 'Repairing'}</Tooltip>}>
        <Label bsStyle="info"><FontAwesome key={0} name='wrench' /></Label>
      </OverlayTrigger>
    else if @props.label? and @props.label == 2
      <OverlayTrigger placement="top" overlay={<Tooltip id="statuslabel-status-2">{__ 'Ship tag: %s', 'E1, E2, E3'}</Tooltip>}>
        <Label bsStyle="info"><FontAwesome key={0} name='tag' /></Label>
      </OverlayTrigger>
    else if @props.label? and @props.label == 3
      <OverlayTrigger placement="top" overlay={<Tooltip id="statuslabel-status-3">{__ 'Ship tag: %s', 'E4'}</Tooltip>}>
        <Label bsStyle="primary"><FontAwesome key={0} name='tag' /></Label>
      </OverlayTrigger>
    else if @props.label? and @props.label == 4
      <OverlayTrigger placement="top" overlay={<Tooltip id="statuslabel-status-4">{__ 'Ship tag: %s', '?'}</Tooltip>}>
        <Label bsStyle="success"><FontAwesome key={0} name='tag' /></Label>
      </OverlayTrigger>
    else if @props.label? and @props.label == 5
      <OverlayTrigger placement="top" overlay={<Tooltip id="statuslabel-status-5">{__ 'Ship tag: %s', '?'}</Tooltip>}>
        <Label bsStyle="warning"><FontAwesome key={0} name='tag' /></Label>
      </OverlayTrigger>
    else if @props.label? and @props.label == 6
      <OverlayTrigger placement="top" overlay={<Tooltip id="statuslabel-status-6">{__ 'Resupply needed'}</Tooltip>}>
        <Label bsStyle="warning"><FontAwesome key={0} name='database' /></Label>
      </OverlayTrigger>
    else
      <Label bsStyle="default" style={opacity: 0}></Label>

module.exports = StatusLabel
