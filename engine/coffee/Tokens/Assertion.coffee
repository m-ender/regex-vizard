root = global ? window

class root.StartAnchor extends root.Token
    constructor: (debug) ->
        super

    reset: (state) ->
        super
        state.tokens[@debug.id].attempted = false

    setupStateObject: ->
        type: 'startAnchor'
        attempted: false

    nextMatch: (state) ->
        tokenState = state.tokens[@debug.id]
        if tokenState.attempted
            @reset(state)
            return false

        if state.input[state.currentPosition - 1] == StartGuard
            tokenState.attempted = true
            return state.currentPosition
        return false

class root.EndAnchor extends root.Token
    constructor: (debug) ->
        super

    reset: (state) ->
        super
        state.tokens[@debug.id].attempted = false

    setupStateObject: ->
        type: 'endAnchor'
        attempted: false

    nextMatch: (state) ->
        tokenState = state.tokens[@debug.id]
        if tokenState.attempted
            @reset(state)
            return false

        if state.input[state.currentPosition] == EndGuard
            tokenState.attempted = true
            return state.currentPosition
        return false

class root.WordBoundary extends root.Token
    constructor: (debug, @negated = false) ->
        super(debug)
        @wordClass = new WordClass()

    reset: (state) ->
        super
        state.tokens[@debug.id].attempted = false

    setupStateObject: () ->
        type: 'wordBoundary'
        attempted: false

    nextMatch: (state) ->
        tokenState = state.tokens[@debug.id]
        if tokenState.attempted
            @reset(state)
            return false
        leftChar = state.input[state.currentPosition-1]
        rightChar = state.input[state.currentPosition]
        if (@wordClass.isInClass(leftChar) isnt @wordClass.isInClass(rightChar)) isnt @negated
            tokenState.attempted = true
            return state.currentPosition
        return false