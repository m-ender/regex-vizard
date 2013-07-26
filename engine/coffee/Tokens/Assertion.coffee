root = global ? window

class root.StartAnchor extends BasicToken
    constructor: (debug) ->
        super

    setupStateObject: ->
        obj = super
        obj.type = 'startAnchor'
        return obj

    matches: (state) ->
        if state.input[state.currentPosition - 1] == StartGuard
            return Result.Success(state.currentPosition)
        else
            return Result.Failure()

class root.EndAnchor extends BasicToken
    constructor: (debug) ->
        super

    setupStateObject: ->
        obj = super
        obj.type = 'endAnchor'
        return obj

    matches: (state) ->
        if state.input[state.currentPosition] == EndGuard
            return Result.Success(state.currentPosition)
        else
            return Result.Failure()

class root.WordBoundary extends BasicToken
    constructor: (debug, @negated = false) ->
        super(debug)
        @wordClass = new WordClass()

    setupStateObject: () ->
        obj = super
        obj.type = 'wordBoundary'
        return obj

    matches: (state) ->
        leftChar = state.input[state.currentPosition - 1]
        rightChar = state.input[state.currentPosition]
        # "isnt" is basically XOR. The first one ensures that one character is a
        # word character while the other isn't. The final "isnt" inverts the result
        # if the @negated flag was set (XORing with true inverts a boolean, XORing
        # with false does not change it)
        if (@wordClass.isInClass(leftChar) isnt @wordClass.isInClass(rightChar)) isnt @negated
            return Result.Success(state.currentPosition)
        else
            return Result.Failure()
