root = global ? window

# This encapsulates concatenation.
# Empty (sub)patterns are also represented by (empty) sequences
class root.Sequence extends Token
    constructor: (debug) ->
        super(debug)

    reset: (state) ->
        super
        state.tokens[@debug.id].i = 0 # the first subtoken to try upon calling nextMatch
        state.tokens[@debug.id].subtokenFailed = false
        state.tokens[@debug.id].pos = [] # "current" positions that were used by successful subtokens

    setupStateObject: ->
        status: Inactive
        i: 0
        pos: []
        subtokenFailed: false

    nextMatch: (state) ->
        tokenState = state.tokens[@debug.id]

        if tokenState.subtokenFailed
            @subtokens[tokenState.i].reset(state)
            --tokenState.i
            if tokenState.pos.length > 0
                state.currentPosition = tokenState.pos.pop()
            tokenState.subtokenFailed = false
            return Result.Indeterminate()

        # Once the first token (index 0) fails, i will be set to -1 and
        # there will be nothing else to backtrack.
        if tokenState.i == -1
            return Result.Failure()

        # If the sequence is empty, it cannot fail. But at the same time
        # there is nothing to backtrack, so we make sure the above condition
        # catches the next call of this function.
        if @subtokens.length == 0
            tokenState.i = -1
            return Result.Success(state.currentPosition)

        currentToken = @subtokens[tokenState.i]
        result = currentToken.nextMatch(state)
        switch result.type
            when Failure
                tokenState.subtokenFailed = true
                return Result.Indeterminate()
            when Indeterminate
                return result
            when Success
                if tokenState.i == @subtokens.length - 1
                    tokenState.wasFinal = true
                    return result
                else
                    tokenState.pos.push(state.currentPosition)
                    state.currentPosition = result.nextPosition
                    ++tokenState.i
                    return Result.Indeterminate()
