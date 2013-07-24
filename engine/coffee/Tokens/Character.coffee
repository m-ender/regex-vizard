root = global ? window

# This represents a single literal character
class root.Character extends root.Token
    constructor: (debug, @character) ->
        super(debug)

    reset: (state) ->
        super
        state.tokens[@debug.id].status = Inactive
        state.tokens[@debug.id].attempted = false

    setupStateObject: ->
        type: 'character'
        status: Inactive
        attempted: false

    nextMatch: (state) ->
        tokenState = state.tokens[@debug.id]

        # A character cannot backtrack. If this method is called
        # a second time it will invariably report failure.
        if tokenState.attempted
            return Result.Failure()

        tokenState.attempted = true
        if state.input[state.currentPosition] == @character
            tokenState.status = Matched
            return Result.Success(state.currentPosition + 1)
        else
            tokenState.status = Failed
            return Result.Failure()
