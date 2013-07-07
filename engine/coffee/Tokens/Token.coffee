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
        @reset()

    # this function will attempt one match at a time - that is one alternative of an disjunction or a certain
    # number of repetitions
    # returns 0 if match unsuccessful but there might be matches on further attempts
    # returns the position after the match if successful
    # returns false if match ultimately unsuccessful (and internal state resets)
    # report is a boolean flag
    nextMatch: (state, report) ->
        false

    reset: () ->
        # Resets all subtokens recursively
        for subtoken in @subtokens
            subtoken.reset()