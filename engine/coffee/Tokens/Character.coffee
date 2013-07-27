root = global ? window

# This represents a single literal character
class root.Character extends BasicToken
    constructor: (debug, @character) ->
        super(debug)

    matches: (state) ->
        if state.input[state.currentPosition] is @character
            return Result.Success(state.currentPosition + 1)
        else
            return Result.Failure()
