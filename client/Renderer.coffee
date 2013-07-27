root = global ? window

class root.Renderer
    constructor: (@regex, @input) ->
        @tokens = []
        collect = (token) =>
            id = token.debug.id
            @tokens[id] = token
            for subtoken in token.subtokens
                collect(subtoken)

        collect @regex.regex

    render: (state) ->
        console.log state
