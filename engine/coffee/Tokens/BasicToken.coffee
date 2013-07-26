root = global ? window

# Represents all possible leaf tokens in the tree,
# i.e. those which do not contain any subtokens.
class root.BasicToken extends Token
    constructor: (debug) ->
        super

    reset: (state) ->
        super
        state.tokens[@debug.id].status = Inactive
        state.tokens[@debug.id].attempted = false

    setupStateObject: ->
        status: Inactive
        attempted: false

    nextMatch: (state) ->
        tokenState = state.tokens[@debug.id]

        # A basic token cannot backtrack. If this method is called
        # a second time it will invariably report failure.
        if tokenState.attempted
            return Result.Failure()

        tokenState.attempted = true
        result = @matches(state)
        switch result.type
            when Success
                tokenState.status = Matched
            when Failure
                tokenState.status = Failed
        return result

    # Subclasses implement
    # matches: (state) ->
    # which returns the appropriate Result object, which can only be one of
    # types Success and Failure
