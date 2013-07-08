root = global ? window

# This represents a single literal character
class root.Character extends root.Token
    constructor: (debug, @character) ->
        super(debug)

    reset: (state) ->
        super
        state.tokens[@debug.id].attempted = false

    setupStateObject: ->
        attempted: false

    nextMatch: (state) ->
        tokenState = state.tokens[@debug.id]
        if tokenState.attempted
            @reset(state)
            return false

        if state.input[state.currentPosition] == @character
            tokenState.attempted = true
            return state.currentPosition + 1
        return false