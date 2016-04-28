

module.exports =
  provider: null

  activate: ->

  deactivate: ->
    @provider = null

  provide: ->
    unless @provider?
      bash_var_provider = require './provider'
      bash_dir_provider = require './dirProvider'
      @provider = [new bash_var_provider(), new bash_dir_provider()]

    @provider
