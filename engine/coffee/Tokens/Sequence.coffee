root = global ? window

# This encapsulates concatenation.
# Empty (sub)patterns are also represented by (empty) sequences
class root.Sequence extends root.Token
    constructor: (debug) ->
        super(debug)

    reset: (state) ->
        super
        state.tokens[@debug.id].i = 0 # the first subtoken to try upon calling nextMatch
        state.tokens[@debug.id].pos = [] # "current" positions that were used by successful subtokens

    setupStateObject: ->
        type: 'sequence'
        status: Inactive
        i: 0
        pos: []

    nextMatch: (state) ->
        tokenState = state.tokens[@debug.id]
        if tokenState.i == -1
            @reset(state)
            return new Result(Failure)

        if @subtokens.length == 0
            tokenState.i = -1
            return new Result(Success, state.currentPosition)

        result = @subtokens[tokenState.i].nextMatch(state)
        switch result.type
            when Failure
                --tokenState.i
                if tokenState.pos.length > 0
                    state.currentPosition = tokenState.pos.pop()
                return new Result(Indeterminate)
            when Indeterminate
                return result
            when Success
                if tokenState.i == @subtokens.length - 1
                    return result
                else
                    ++tokenState.i
                    tokenState.pos.push(state.currentPosition)
                    state.currentPosition = result.nextPosition
                    return new Result(Indeterminate)
