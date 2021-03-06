
esprima = require 'esprima'
_ = require 'lodash'

typeIsArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'

parse = (code) ->
  try
    syntax = esprima.parse code, {tolerant: true, loc: true}
    return _.map syntax.errors, (e) -> _.extend({}, e, {type: 'warning'})
  catch e
    e.type = 'error'
    return [e]

module.exports = (langs, markdown_processor) ->
  if !typeIsArray langs
    langs = [langs]
  (editor, delta) ->
    tokens = markdown_processor.parse editor.getValue()

    # only get toplevel code environments
    code_tokens = _.filter tokens, (t) -> (langs.indexOf t.info) > -1

    results = _.map code_tokens, (code_token) ->
      res = parse code_token.content
      resCorrLine = _.map res, (r) ->
        r.lineNumber += code_token.map[0]
        return r
      return resCorrLine

    editor.addResult editor, _.flatten results
