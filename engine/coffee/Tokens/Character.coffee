root = global ? window

# This represents a single literal character
class root.Character extends BasicToken
    constructor: (debug, @character) ->
        super(debug)

    reset: (state) ->
        super
        state.tokens[@debug.id].matchedPosition = null

    setupStateObject: ->
        obj = super
        obj.matchedPosition = null
        return obj

    matches: (state) ->
        if state.input[state.currentPosition] is @character
            state.tokens[@debug.id].matchedPosition = state.currentPosition
            return Result.Success(state.currentPosition + 1)
        else
            return Result.Failure()
