root = global ? window

class root.StartAnchor extends root.Token
    constructor: (debug) ->
        super

    reset: (state) ->
        super
        state.tokens[@debug.id].attempted = false

    setupStateObject: ->
        type: 'startAnchor'
        status: Inactive
        attempted: false

    nextMatch: (state) ->
        tokenState = state.tokens[@debug.id]
        if tokenState.attempted
            @reset(state)
            return new Result(Failure)

        if state.input[state.currentPosition - 1] == StartGuard
            tokenState.attempted = true
            return new Result(Success, state.currentPosition)
        return new Result(Failure)

class root.EndAnchor extends root.Token
    constructor: (debug) ->
        super

    reset: (state) ->
        super
        state.tokens[@debug.id].attempted = false

    setupStateObject: ->
        type: 'endAnchor'
        status: Inactive
        attempted: false

    nextMatch: (state) ->
        tokenState = state.tokens[@debug.id]
        if tokenState.attempted
            @reset(state)
            return new Result(Failure)

        if state.input[state.currentPosition] == EndGuard
            tokenState.attempted = true
            return new Result(Success, state.currentPosition)
        return new Result(Failure)

class root.WordBoundary extends root.Token
    constructor: (debug, @negated = false) ->
        super(debug)
        @wordClass = new WordClass()

    reset: (state) ->
        super
        state.tokens[@debug.id].attempted = false

    setupStateObject: () ->
        type: 'wordBoundary'
        status: Inactive
        attempted: false

    nextMatch: (state) ->
        tokenState = state.tokens[@debug.id]
        if tokenState.attempted
            @reset(state)
            return new Result(Failure)
        leftChar = state.input[state.currentPosition-1]
        rightChar = state.input[state.currentPosition]
        if (@wordClass.isInClass(leftChar) isnt @wordClass.isInClass(rightChar)) isnt @negated
            tokenState.attempted = true
            return new Result(Success, state.currentPosition)
        return new Result(Failure)
