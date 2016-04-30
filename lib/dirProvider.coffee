
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

  regex_fn: /((?:(?:\.\.\/)|(?:\.\/)|\/|(?:\~\/))(?:(?:(?:\\\ )|\w|-|\.)+\/)*)((?:[\w\.](?:[\w\.-]|(?:\\\ ))*)*)$/
  regex_fn_quoted: /((?:(?:\.\.\/)|(?:\.\/)|\/|(?:\~\/))(?:(?:\w|-|\.)(?:\ |\w|-|\.)*\/)*)((?:[\w\.](?:[\w-\.\ ])*)*)$/

  getSuggestions: ({editor, bufferPosition, scopeDescriptor}) ->
    [quoted, parent, child] = @getPrefix(editor, bufferPosition, scopeDescriptor)
    rl = null
    if parent
      try
        parent = parent.replace(/\\ /g," ")
        if parent.startsWith("~")
          parent = path.resolve(os.homedir() + parent[1..-1])
        else if parent.startsWith(".")
          parent = path.resolve(editor.getPath(), "../#{parent}/")
        unless fs.accessSync(path.resolve(parent), fs.F_OK | fs.R_OK)
          files = fs.readdirSync(path.resolve(parent))
          rl = for file in files
            try
              @buildDirValue(file, child, parent, quoted, fs.statSync(path.resolve("#{parent}/#{file}")).isDirectory()) unless fs.accessSync(path.resolve("#{parent}/#{file}"), fs.F_OK | fs.R_OK)
            catch err
              # console.log err
              continue
      catch err
        # console.log err

    return rl

  getPrefix: (editor, bufferPosition, scopeDescriptor) ->

    # Get the text for the line up to the triggered buffer position
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    # Match the regex to the line, and return the match
    if "string.quoted.double.shell" in scopeDescriptor.scopes
      [true].concat(line.match(@regex_fn_quoted)?[1..2]) or [true, null, null]
    else
      [false].concat(line.match(@regex_fn)?[1..2]) or [false, null, null]


  buildDirValue: (file, child, parent, quoted, isDir) ->
    text: if not quoted then file.replace(/\ /g, "\\ ") else file
    type: "constant"
    replacementPrefix: child
    rightLabel: if isDir then "Directory" else "File"
    description: parent+file
