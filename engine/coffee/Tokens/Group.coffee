root = global ? window

class root.Group extends Token
    constructor: (debug, token, @index) ->
        super(debug, token)

    reset: (state) ->
        super
        state.tokens[@debug.id].status = Inactive
        state.tokens[@debug.id].result = null
        state.tokens[@debug.id].firstPosition = false

    setupStateObject: ->
        type: 'group'
        status: Inactive
        result: null
        firstPosition: false

    register: (state) ->
        state.captures[@index] = undefined
        super

    nextMatch: (state) ->
        tokenState = state.tokens[@debug.id]
        if tokenState.result isnt null
            result = tokenState.result

            # If we got here from a previous subtoken Success, we reset the result
            # so that the next call can keep backtracking the subtoken.
            # If we got here from a Failure instead, we leave the result in place
            # so that subsequent calls will keep failing as there is nothing left
            # to backtrack in the subtoken.
            if result.type is Success
                tokenState.result = null
            return result

        if tokenState.firstPosition is false
            tokenState.firstPosition = state.currentPosition

        result = @subtokens[0].nextMatch(state)
        switch result.type
            when Indeterminate
                tokenState.status = Active
                return result
            when Failure
                tokenState.status = Failed
                tokenState.result = result
                state.captures[@index] = undefined
                return Result.Indeterminate()
            when Success
                tokenState.status = Matched
                state.captures[@index] = state.input[tokenState.firstPosition...result.nextPosition].join("")
                tokenState.result = result
                return Result.Indeterminate()
