root = global ? window

class root.Quantifier extends root.Token
    constructor: (debug, token, @min, @max) ->
        super(debug, token)
        @minGroup = -1
        @nGroups = 0
        @clearer = []

    reset: (state) ->
        super
        state.tokens[@debug.id].freshSubStates = @collectSubStates(state, @subtokens[0])
        state.tokens[@debug.id].instances = [Helper.clone state.tokens[@debug.id].freshSubStates]
        state.tokens[@debug.id].pos = []
        state.tokens[@debug.id].result = false
        state.tokens[@debug.id].captureStack = []

    setupStateObject: (state) ->
        stateObject =
            type: 'quantifier'
            status: Inactive
            freshSubStates: @collectSubStates(state, @subtokens[0])
            instances: []                           # instances of the subtoken used for the individual repetitions
            pos: []                                 # "current" positions that were used for successful matches
            result: false
            captureStack: []                        # remembers the captures of hidden instances on the above stack
        stateObject.instances.push(Helper.clone stateObject.freshSubStates)
        return stateObject

    collectSubStates: (state, token) ->
        states = []
        key = token.debug.id
        states[key] = state.tokens[key]
        for subtoken in token.subtokens
            for key, val of @collectSubStates(state, subtoken)
                states[key] = val
        return states

    restoreSubStates: (state, subStates) ->
        for key, val of subStates
            state.tokens[key] = val


    # [Number] minGroup is the smallest group number contained in the subtokens of this quantifier
    # [Number] nGroups is the number of groups contained in the subtokens of this quantifier
    setGroupRange: (@minGroup, @nGroups) ->
        for i in [0...@nGroups]
            @clearer[i] = undefined

    nextMatch: (state) ->
        tokenState = state.tokens[@debug.id]
        if tokenState.result
            result = tokenState.result
            tokenState.result = false
            if tokenState.instances.length >= @min
                return result
            else
                return 0

        if tokenState.instances.length == 0
            @reset(state)
            return false

        if tokenState.instances.length > @max
            tokenState.instances.pop()
            result = state.currentPosition
            if tokenState.pos.length > 0
                state.currentPosition = tokenState.pos.pop()

            if tokenState.captureStack.length > 0
                state.captures[@minGroup...@minGroup+@nGroups] = tokenState.captureStack.pop()
            return result

        token = @subtokens[0]
        @restoreSubStates(state, tokenState.instances.pop())

        result = token.nextMatch(state)
        switch result
            when 0, -1
                tokenState.instances.push(@collectSubStates(state, token))
                return result
            when false
                tokenState.result = state.currentPosition
                if tokenState.pos.length > 0
                    state.currentPosition = tokenState.pos.pop()
                if tokenState.captureStack.length > 0
                    state.captures[@minGroup...@minGroup+@nGroups] = tokenState.captureStack.pop()

                return 0
            else
                tokenState.instances.push(@collectSubStates(state, token))
                # only the first @min instances are allowed to match empty, to avoid infinite loops
                if result == state.currentPosition and tokenState.instances.length > @min
                    return @nextMatch(state)

                tokenState.captureStack.push(state.captures[@minGroup...@minGroup+@nGroups])
                state.captures[@minGroup...@minGroup+@nGroups] = @clearer

                tokenState.instances.push(Helper.clone tokenState.freshSubStates)
                tokenState.pos.push(state.currentPosition)
                state.currentPosition = result
                return -1

class root.Option extends root.Quantifier
    constructor: (debug, token) ->
        super(debug, token, 0, 1)

    setupStateObject: ->
        obj = super
        obj.subtype = 'option'
        return obj

class root.RepeatZeroOrMore extends root.Quantifier
    constructor: (debug, token) ->
        super(debug, token, 0, Infinity)

    setupStateObject: ->
        obj = super
        obj.subtype = 'zeroOrMore'
        return obj

class root.RepeatOneOrMore extends root.Quantifier
    constructor: (debug, token) ->
        super(debug, token, 1, Infinity)

    setupStateObject: ->
        obj = super
        obj.subtype = 'oneOrMore'
        return obj