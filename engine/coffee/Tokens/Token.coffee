root = global ? window

class root.Token
    constructor: (@debug, token) ->
        # list of sub-tokens
        # Sequences and Disjunctions will use a list of arbitrary length
        # Quantifiers and Groups will use a single token in the list
        # Atomic tokens like characters and anchors will have this list empty
        @subtokens = []
        if token and token instanceof Token
            @subtokens.push(token)

    reset: (state) ->
        # Resets all subtokens recursively
        for subtoken in @subtokens
            subtoken.reset(state)

    register: (state) ->
        for subtoken in @subtokens
            subtoken.register(state)
        state.tokens[@debug.id] = @setupStateObject(state)

    setupStateObject: ->
        {}

    # this function will attempt one match at a time - that is one alternative of a disjunction or a certain
    # number of repetitions
    nextMatch: (state) ->
        false
