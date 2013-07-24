root = global ? window

class root.Group extends root.Token
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
            switch result.type
                when Failure
                    @reset(state)
                when Success
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
                return new Result(Indeterminate)
            when Success
                tokenState.status = Matched
                state.captures[@index] = state.input[tokenState.firstPosition...result.nextPosition].join("")
                tokenState.result = result
                return new Result(Indeterminate)
