root = global ? window

class root.Regex
    constructor: (regexString, report = false) ->      
        console.log("Regex string:", regexString) if report
        @regex = new Parser().parsePattern(regexString)
        console.log("Regex pattern:", @regex) if report

    test: (inputString, report = false) ->
        @regex.reset()
        
        # Build character array and surround it with -1 and 1 as guards for the
        # start and end of the input string
        console.log("Input string:", inputString) if report
        state = @setupInitialState(inputString)        
        console.log("Input:", state.input) if report

        while state.startingPosition < state.input.length
            result = @regex.nextMatch(state, report)
            while result == 0 or result == -1
                result = @regex.nextMatch(state, report)
            if result == false
                state.currentPosition = ++state.startingPosition
            else
                break
        
        return state.startingPosition < state.input.length
        
    match: (inputString, report = false) ->
        @regex.reset()
    
        # Build character array and surround it with -1 and 1 as guards for the
        # start and end of the input string
        console.log("Input string:", inputString) if report
        state = @setupInitialState(inputString)        
        console.log("Input:", state.input) if report

        while state.startingPosition < state.input.length
            result = @regex.nextMatch(state, report)
            while result == 0 or result == -1
                result = @regex.nextMatch(state, report)
            if result == false
                state.currentPosition = ++state.startingPosition
            else
                break
        
        return inputString[state.startingPosition-1...result-1]
        
    parseInput: (inputString) ->
        input = [-1].concat(inputString.split(""))
        input.push(1)
        return input
        
    setupInitialState: (str) ->
        return {
            inputString: str
            input: @parseInput(str)
            startingPosition: 1
            currentPosition: 1
            report: () ->
                console.log("Current match: " + @inputString[@startingPosition-1...@currentPosition-1])
        }