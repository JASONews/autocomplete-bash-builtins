ComplProvider = require '../lib/provider'
provider = new ComplProvider()

describe "when a prefix avaible", ->
  it "should return [] when prefix is not matched", ->
    ret = provider.getSuggestions(null, null, null, prefix="q")
    expect(ret).toBeInstanceOf Array
    expect(ret.length).toEqual 0

  it "should return a list of suggestion when prefix is matched", ->
    ret = provider.getSuggestions(null, null, null, prefix="q")
    expect(ret).toBeInstanceOf Array
    expect(ret.length).not.toEqual 0
