root = global ? window

# This represents a single literal character
class root.Character extends root.Token
    constructor: (debug, @character) ->
        super(debug)

    reset: (state) ->
        super
        state.tokens[@debug.id].status = Inactive
        state.tokens[@debug.id].attempted = false

    setupStateObject: ->
        type: 'character'
        status: Inactive
        attempted: false

    nextMatch: (state) ->
        tokenState = state.tokens[@debug.id]
        if tokenState.status isnt Inactive
            @reset(state)
            return false

        if state.input[state.currentPosition] == @character
            tokenState.status = Matched
            tokenState.attempted = true
            return state.currentPosition + 1
        return false