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
        i: 0
        pos: []

    nextMatch: (state) ->
        tokenState = state.tokens[@debug.id]
        if tokenState.i == -1
            @reset(state)
            return false

        if @subtokens.length == 0
            --tokenState.i
            return state.currentPosition

        result = @subtokens[tokenState.i].nextMatch(state)
        switch result
            when false
                --tokenState.i
                if tokenState.pos.length > 0
                    state.currentPosition = tokenState.pos.pop()
                return 0
            when -1, 0
                return result
            else
                if tokenState.i == @subtokens.length - 1
                    return result
                else
                    ++tokenState.i
                    tokenState.pos.push(state.currentPosition)
                    state.currentPosition = result
                    return -1
