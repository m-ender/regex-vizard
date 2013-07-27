root = global ? window

class root.Disjunction extends Token
    constructor: (debug, token) ->
        super

    reset: (state) ->
        super
        state.tokens[@debug.id].i = 0 # the first subtoken to try upon calling nextMatch

    setupStateObject: ->
        status: Inactive
        i: 0

    nextMatch: (state) ->
        tokenState = state.tokens[@debug.id]

        # When we've exhausted all subtokens, there is nothing more to backtrack.
        if tokenState.i == @subtokens.length
            return Result.Failure()

        result = @subtokens[tokenState.i].nextMatch(state)
        switch result.type
            when Success, Indeterminate
                return result
            when Failure
                ++tokenState.i
                return Result.Indeterminate()
