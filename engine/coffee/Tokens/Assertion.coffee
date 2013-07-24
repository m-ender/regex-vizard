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

        # An anchor cannot backtrack. If this method is called
        # a second time it will invariably report failure.
        if tokenState.attempted
            return Result.Failure()

        tokenState.attempted = true
        if state.input[state.currentPosition - 1] == StartGuard
            return Result.Success(state.currentPosition)
        else
            return Result.Failure()

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

        # An anchor cannot backtrack. If this method is called
        # a second time it will invariably report failure.
        if tokenState.attempted
            return Result.Failure()

        tokenState.attempted = true
        if state.input[state.currentPosition] == EndGuard
            return Result.Success(state.currentPosition)
        else
            return Result.Failure()

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

        # A word boundary cannot backtrack. If this method is called
        # a second time it will invariably report failure.
        if tokenState.attempted
            return Result.Failure()

        tokenState.attempted = true
        leftChar = state.input[state.currentPosition-1]
        rightChar = state.input[state.currentPosition]
        if (@wordClass.isInClass(leftChar) isnt @wordClass.isInClass(rightChar)) isnt @negated
            return Result.Success(state.currentPosition)
        else
            return Result.Failure()
