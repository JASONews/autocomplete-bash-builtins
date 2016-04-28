
fs = require 'fs'
path = require 'path'
os = require 'os'

module.exports =
class bashDirProvider
  selector: '.source.shell'
  disableForSelector: '.comment'

  inclusionPriority: 0
  suggestionPriority: 2
  filterSuggestions: true
  excludeLowerPriority: false

  regex_fn: /((?:(?:\.\.\/)|(?:\.\/)|\/|(?:\~\/))(?:(?:(?:\\\ )|\w|-|\.)+\/)*)([\w-]*)$/
  regex_fn_quoted: /((?:(?:\.\.\/)|(?:\.\/)|\/|(?:\~\/))(?:(?:\w|-|\.)(?:\ |\w|-|\.)*\/)*)([\w-\ ]*)$/

  getSuggestions: ({editor, bufferPosition, scopeDescriptor}) ->
    [quoted, parent, child] = @getPrefix(editor, bufferPosition, scopeDescriptor)
    rl = null
    if parent
      parent = parent.replace(/\\ /g," ")
      if parent.startsWith("~")
        parent = os.homedir() + parent[1..-1]
      if fs.existsSync(parent)
        files = fs.readdirSync(path.resolve(parent))
        rl = for file in files
          @buildDirValue(file, child, parent, quoted)
    return rl

  getPrefix: (editor, bufferPosition, scopeDescriptor) ->
    # Whatever your prefix regex might be

    # Get the text for the line up to the triggered buffer position
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    # Match the regex to the line, and return the match
    if "string.quoted.double.shell" in scopeDescriptor.scopes
      [true].concat(line.match(@regex_fn_quoted)?[1..2]) or [true, null, null]
    else
      [false].concat(line.match(@regex_fn)?[1..2]) or [false, null, null]


  buildDirValue: (file, child, parent, quoted) ->
    text: if not quoted then file.replace(/\ /g, "\\ ") else file
    type: "constant"
    replacementPrefix: child
    rightLabel: parent+file
    description: parent+file
