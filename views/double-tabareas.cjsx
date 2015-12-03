path = require 'path-extra'
glob = require 'glob'
{__} = require 'i18n'
semver = require 'semver'
fs = require 'fs-extra'
{_, $, React, ReactBootstrap, FontAwesome} = window
{Nav, NavItem, NavDropdown, MenuItem} = ReactBootstrap

# Plugin version
packages = fs.readJsonSync path.join ROOT, 'plugin.json'

$('poi-main').className += 'double-tabbed'
window.doubleTabbed = true

PluginWrap = React.createClass
  shouldComponentUpdate: (nextProps, nextState)->
    false
  render: ->
    React.createElement @props.plugin.reactClass

# Discover plugins and remove unused plugins
plugins = glob.sync(path.join(PLUGIN_PATH, 'node_modules', 'poi-plugin-*'))
plugins = plugins.filter (filePath) ->
  # Every plugin will be required
  try
    plugin = require filePath
    packageData = {}
    try
      packageData = fs.readJsonSync path.join filePath, 'package.json'
    catch error
      if env.process.DEBUG? then console.log error
    if packageData?.name?
      plugin.packageName =  packageData.name
    else
      plugin.packageName = plugin.name
    if packages[plugin.packageName]?.version?
      lowest = packages[plugin.packageName].version
    else
      lowest = "v0.0.0"
    return config.get("plugin.#{plugin.name}.enable", true) && semver.gte(plugin.version, lowest)
  catch e
    return false

plugins = plugins.map (filePath) ->
  plugin = require filePath
  plugin.priority = 10000 unless plugin.priority?
  plugin
plugins = plugins.filter (plugin) ->
  plugin.show isnt false
plugins = _.sortBy(plugins, 'priority')
tabbedPlugins = plugins.filter (plugin) ->
  !plugin.handleClick?

settings = require path.join(ROOT, 'views', 'components', 'settings')
mainview = require path.join(ROOT, 'views', 'components', 'main')

lockedTab = false
ControlledTabArea = React.createClass
  getInitialState: ->
    key: [0, 0]
  handleSelect: (key) ->
    @setState {key} if key[0] isnt @state.key[0] or key[1] isnt @state.key[1]
  handleSelectLeft: (key) ->
    @handleSelect [key, @state.key[1]]
  handleSelectRight: (e, key) ->
    e.preventDefault()
    @handleSelect [@state.key[0], key]
  handleSelectMainView: ->
    event = new CustomEvent 'view.main.visible',
      bubbles: true
      cancelable: false
      detail:
        visible: true
    window.dispatchEvent event
    @handleSelectLeft 0
  handleSelectShipView: ->
    event = new CustomEvent 'view.main.visible',
      bubbles: true
      cancelable: false
      detail:
        visible: false
    window.dispatchEvent event
    @handleSelectLeft 1
  handleCtrlOrCmdTabKeyDown: ->
    @handleSelect [(@state.key[0] + 1) % 1, @state.key[1]]
  handleCtrlOrCmdNumberKeyDown: (num) ->
    if num == 1
      @handleSelectMainView()
    else
      if num == 2
        @handleSelectShipView()
      else
        if num <= 2 + tabbedPlugins.length && num > 2
          @handleSelect [@state.key[0], num - 3]
  handleShiftTabKeyDown: ->
    @handleSelect [@state.key[0], if @state.key[1]? then (@state.key[1] - 1 + tabbedPlugins.length) % tabbedPlugins.length else tabbedPlugins.length - 1]
  handleTabKeyDown: ->
    @handleSelect [@state.key[0], if @state.key[1]? then (@state.key[1] + 1) % tabbedPlugins.length else 1]
  handleKeyDown: ->
    return if @listener?
    @listener = true
    window.addEventListener 'keydown', (e) =>
      if e.keyCode is 9
        e.preventDefault()
        return if lockedTab and e.repeat
        lockedTab = true
        setTimeout ->
          lockedTab = false
        , 200
        if e.ctrlKey or e.metaKey
          @handleCtrlOrCmdTabKeyDown()
        else if e.shiftKey
          @handleShiftTabKeyDown()
        else
          @handleTabKeyDown()
      else if e.ctrlKey or e.metaKey
        if e.keyCode >= 49 and e.keyCode <= 57
          @handleCtrlOrCmdNumberKeyDown(e.keyCode - 48)
        else if e.keyCode is 48
          @handleCtrlOrCmdNumberKeyDown 10
  componentDidMount: ->
    window.addEventListener 'game.start', @handleKeyDown
    window.addEventListener 'tabarea.reload', @forceUpdate
  render: ->
    <div className='poi-tabs-container'>
      <div>
        <Nav bsStyle="tabs" activeKey={@state.key[0]}>
          <NavItem key={0} eventKey={0} onSelect={@handleSelectMainView}>
            {mainview.displayName}
          </NavItem>
          <NavItem key={1} eventKey={1} onSelect={@handleSelectShipView}>
            <span><FontAwesome key={0} name='server' />{__ ' Fleet'}</span>
          </NavItem>
          <NavItem key={1000} eventKey={1000} className='poi-app-tabpane' onSelect={@handleSelectLeft}>
            {settings.displayName}
          </NavItem>
        </Nav>
        <div id={mainview.name} className="poi-app-tabpane #{if @state.key[0] in [0, 1] then 'show' else 'hidden'}">
          {
            React.createElement mainview.reactClass,
              selectedKey: @state.key[0]
              index: 0
          }
        </div>
        <div id={settings.name} className="poi-app-tabpane #{if @state.key[0] == 1000 then 'show' else 'hidden'}">
          {
            React.createElement settings.reactClass,
              selectedKey: @state.key[0]
              index: 1000
          }
        </div>
      </div>
      <div>
        <Nav bsStyle="tabs" activeKey={@state.key[1]} onSelect={@handleSelectRight}>
          <NavDropdown id='plugin-dropdown' key={-1} eventKey={-1} pullRight
                       title={plugins[@state.key[1]]?.displayName || <span><FontAwesome name='sitemap' />{__ ' Plugins'}</span>}>
          {
            counter = -1
            plugins.map (plugin, index) =>
              if plugin.handleClick?
                <MenuItem key={index} eventKey={@state.key[1]} onSelect={plugin.handleClick}>
                  {plugin.displayName}
                </MenuItem>
              else
                key = (counter += 1)
                <MenuItem key={index} eventKey={key}>
                  {plugin.displayName}
                </MenuItem>
          }
          {
            if plugins.length == 0
              <MenuItem key={1001} disabled>{__ "Install plugins in settings"}</MenuItem>
          }
          </NavDropdown>
        </Nav>
        {
          counter = -1
          plugins.map (plugin, index) =>
            if !plugin.handleClick?
              key = (counter += 1)
              <div id={plugin.name} key={key} className="poi-app-tabpane #{if @state.key[1] == key then 'show' else 'hidden'}">
                <PluginWrap plugin={plugin} selectedKey={@state.key[1]} index={key} />
              </div>
        }
      </div>
    </div>

module.exports = ControlledTabArea
