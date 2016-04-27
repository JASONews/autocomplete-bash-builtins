

module.exports =
  provider: null

  activate: ->

  deactivate: ->
    @provider = null

  provide: ->
    unless @provider?
      bash_var_provider = require './provider'
      @provider = new bash_var_provider()

    @provider
