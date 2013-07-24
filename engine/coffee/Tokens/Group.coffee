root = global ? window

class root.Group extends root.Token
    constructor: (debug, token, @index) ->
        super(debug, token)

    reset: (state) ->
        super
        state.tokens[@debug.id].status = Inactive
        state.tokens[@debug.id].result = 0
        state.tokens[@debug.id].firstPosition = false

    setupStateObject: ->
        type: 'group'
        status: Inactive
        result: 0
        firstPosition: false

    register: (state) ->
        state.captures[@index] = undefined
        super

    nextMatch: (state) ->
        tokenState = state.tokens[@debug.id]
        if tokenState.result isnt 0
            result = tokenState.result
            if result is false
                @reset(state)
            else
                tokenState.result = 0
            return result

        if tokenState.firstPosition is false
            tokenState.firstPosition = state.currentPosition

        result = @subtokens[0].nextMatch(state)
        switch result
            when 0, -1
                tokenState.status = Active
                return result
            when false
                tokenState.status = Failed
                tokenState.result = false
                state.captures[@index] = undefined
                return 0
            else
                tokenState.status = Matched
                state.captures[@index] = state.input[tokenState.firstPosition...result].join("")
                tokenState.result = result
                return -1
