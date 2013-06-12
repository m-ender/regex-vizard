root = global ? window

class root.Regex
    constructor: (regexString, report = false) ->      
        console.log("Regex string:", regexString) if report
        @regex = new Parser().parsePattern(regexString)
        console.log("Regex pattern:", @regex) if report

    test: (inputString, report = false) ->
        @regex.reset()
        
        console.log(@regex) if report
        
        # Build character array and surround it with -1 and 1 as guards for the
        # start and end of the input string
        console.log("Input string:", inputString) if report
        state = @setupInitialState(inputString, @regex.maxGroup)        
        console.log("Input:", state.input) if report

        while state.startingPosition < state.input.length
            result = @regex.nextMatch(state, report)
            while result == 0 or result == -1
                result = @regex.nextMatch(state, report)
            if result == false
                state.currentPosition = ++state.startingPosition
            else
                break
        
        i = 0
        console.log(state.captures) if report
        return state.startingPosition < state.input.length
        
    match: (inputString, report = false) ->
        @regex.reset()
    
        console.log(@regex) if report
        
        console.log("Input string:", inputString) if report
        state = @setupInitialState(inputString, @regex.maxGroup)        
        console.log("Input:", state.input) if report

        while state.startingPosition < state.input.length
            result = @regex.nextMatch(state, report)
            while result == 0 or result == -1
                result = @regex.nextMatch(state, report)
            if result == false
                state.currentPosition = ++state.startingPosition
            else
                break
        
        i = 0
        return state.captures
        
    # Build character array and surround it with special objects as guards for the
    # start and end of the input string
    parseInput: (inputString) ->
        input = [StartGuard].concat(inputString.split(""))
        input.push(EndGuard)
        return input
        
    setupInitialState: (str, maxGroup = 0) ->
        state =
            inputString: str
            input: @parseInput(str)
            startingPosition: 1
            currentPosition: 1
            captures: []
            report: () ->
                console.log("Current match: " + @inputString[@startingPosition-1...@currentPosition-1])
        
        for i in [0..maxGroup]
            state.captures[i] = undefined
        
        return state