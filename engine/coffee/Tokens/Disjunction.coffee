root = global ? window

class root.Disjunction extends root.Token
    constructor: (debug, token) ->
        super

    reset: (state) ->
        super
        state.tokens[@debug.id].i = 0 # the first subtoken to try upon calling nextMatch

    setupStateObject: ->
        i: 0

    nextMatch: (state) ->
        tokenState = state.tokens[@debug.id]
        if tokenState.i == @subtokens.length
            @reset(state)
            return false

        result = @subtokens[tokenState.i].nextMatch(state)

        if result != false
            return result
        else
            ++tokenState.i
            return 0