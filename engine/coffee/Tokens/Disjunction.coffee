root = global ? window

class root.Disjunction extends root.Token
    constructor: (debug, token) ->
        super

    reset: (state) ->
        super
        state.tokens[@debug.id].i = 0 # the first subtoken to try upon calling nextMatch

    setupStateObject: ->
        type: 'disjunction'
        status: Inactive
        i: 0

    nextMatch: (state) ->
        tokenState = state.tokens[@debug.id]
        if tokenState.i == @subtokens.length
            @reset(state)
            return new Result(Failure)

        result = @subtokens[tokenState.i].nextMatch(state)

        switch result.type
            when Success, Indeterminate
                return result
            when Failure
                ++tokenState.i
                return new Result(Indeterminate)
