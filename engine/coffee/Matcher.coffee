root = global ? window

class root.Matcher
    constructor: (@regex, nGroups, subject) ->
        @startingPosition = 1
        @success = false
        @state = @setupInitialState(subject, nGroups)
        
    setupInitialState: (str, nGroups = 0) ->
        state =
            inputString: str
            input: @parseInput(str)
            currentPosition: 1
            captures: []
        
        for i in [0..nGroups]
            state.captures[i] = undefined
        
        return state
        
    # Build character array and surround it with special objects as guards for the
    # start and end of the input string
    parseInput: (inputString) ->
        input = [StartGuard].concat(inputString.split(""))
        input.push(EndGuard)
        return input
    
    # Returns true if there is more to do
    # Returns false if a match has been found or can ultimately not be found
    stepForward: () ->        
        switch @regex.nextMatch(@state, false)
            when false
                @state.currentPosition = ++@startingPosition
                return @startingPosition < @state.input.length
            when 0, -1
                return true
            else
                @success = true
                return false
                
    group: (n = 0) ->
        @state.captures[n]
        
    groups: () ->
        @state.captures