root = global ? window

class root.Quantifier extends root.Token
    constructor: (debug, token, @min, @max) ->
        super(debug, token)
        @minGroup = -1
        @nGroups = 0
        @clearer = []

    reset: () ->
        super()
        @instances = [Helper.clone @subtokens[0]] # instances of the subtoken used for the individual repetitions
        @pos = []                                  # "current" positions that were used for successful matches
        @result = false
        @captureStack = []                         # remembers the captures of hidden instances on the above stack

    # [Number] minGroup is the smallest group number contained in the subtokens of this quantifier
    # [Number] nGroups is the number of groups contained in the subtokens of this quantifier
    setGroupRange: (@minGroup, @nGroups) ->
        for i in [0...@nGroups]
            @clearer[i] = undefined

    nextMatch: (state, report) ->
        if @result
            result = @result
            @result = false
            if @instances.length >= @min
                return result
            else
                return 0

        if @instances.length == 0
            @reset()
            return false

        if @instances.length > @max
            @instances.pop()
            result = state.currentPosition
            if @pos.length > 0
                state.currentPosition = @pos.pop()

            if @captureStack.length > 0
                state.captures[@minGroup...@minGroup+@nGroups] = @captureStack.pop()
            return result

        instance = @instances.pop()

        result = instance.nextMatch(state, report)
        switch result
            when 0, -1
                @instances.push(instance)
                return result
            when false
                @result = state.currentPosition
                if @pos.length > 0
                    state.currentPosition = @pos.pop()
                if @captureStack.length > 0
                    state.captures[@minGroup...@minGroup+@nGroups] = @captureStack.pop()

                return 0
            else
                @instances.push(instance)
                # only the first @min instances are allowed to match empty, to avoid infinite loops
                if result == state.currentPosition and @instances.length > @min
                    return @nextMatch(state, report)

                @captureStack.push(state.captures[@minGroup...@minGroup+@nGroups])
                state.captures[@minGroup...@minGroup+@nGroups] = @clearer

                @instances.push(Helper.clone @subtokens[0])
                @pos.push(state.currentPosition)
                state.currentPosition = result
                return -1

class root.Option extends root.Quantifier
    constructor: (debug, token) ->
        super(debug, token, 0, 1)

class root.RepeatZeroOrMore extends root.Quantifier
    constructor: (debug, token) ->
        super(debug, token, 0, Infinity)

class root.RepeatOneOrMore extends root.Quantifier
    constructor: (debug, token) ->
        super(debug, token, 1, Infinity)