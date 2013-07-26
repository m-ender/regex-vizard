root = global ? window

# This represents a single literal character
class root.Character extends BasicToken
    constructor: (debug, @character) ->
        super(debug)

    setupStateObject: ->
        obj = super
        obj.type = 'character'
        return obj

    matches: (state) ->
        if state.input[state.currentPosition] is @character
            return Result.Success(state.currentPosition + 1)
        else
            return Result.Failure()
