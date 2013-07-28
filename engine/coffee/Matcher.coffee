root = global ? window

class root.Matcher
    constructor: (@regex, nGroups, @subject) ->
        @success = false
        @state = Matcher.setupInitialState(@subject)
        @regex.register(@state)

    @setupInitialState: (subject) ->
        state =
            input: @parseInput(subject)
            startingPosition: 1
            currentPosition: 1
            tokens: []
            captures: []

        return state

    # Build character array and surround it with special objects as guards for the
    # start and end of the input string
    @parseInput: (inputString) ->
        input = [StartGuard].concat(inputString.split(""))
        input.push(EndGuard)
        return input

    # Returns true if there is more to do
    # Returns false if a match has been found or can ultimately not be found
    stepForward: () ->
        result = @regex.nextMatch(@state)
        switch result.type
            when Failure
                @state.currentPosition = ++@state.startingPosition
                @regex.reset(@state)
                return @state.startingPosition < @state.input.length
            when Indeterminate
                return true
            when Success
                @success = true
                return false

    group: (n = 0) ->
        @state.captures[n]

    groups: () ->
        @state.captures
