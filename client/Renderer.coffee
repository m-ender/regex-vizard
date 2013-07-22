root = global ? window

class root.Renderer
    constructor: (@input, @regex) ->

    render: (state) ->
        console.log state