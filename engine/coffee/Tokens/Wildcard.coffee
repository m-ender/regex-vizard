root = global ? window

class root.Wildcard extends BasicToken
    constructor: (debug) ->
        super

    setupStateObject: ->
        obj = super
        obj.type = 'wildcard'
        return obj

    matches: (state) ->
        unless state.input[state.currentPosition] in ["\n", "\r", "\u2028", "\u2029", EndGuard]
            return Result.Success(state.currentPosition + 1)
        else
            return Result.Failure()
