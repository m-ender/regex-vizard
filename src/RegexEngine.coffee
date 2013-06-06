root = global ? window

class root.RegexEngine
    constructor: () ->      

    match: (regexString, inputString, report = false) ->
        console.log("Regex string:", regexString) if report
        regex = new Parser().parsePattern(regexString)
        console.log("Regex pattern:", regex) if report
        
        # Build character array and surround it with -1 and 1 as guards for the
        # start and end of the input string
        console.log("Input string:", inputString) if report
        state = @setupInitialState(inputString)        
        console.log("Input:", state.input) if report

        while state.startingPosition < state.input.length
            result = regex.nextMatch(state, report)
            while result == 0
                result = regex.nextMatch(state, report)
            if result == false
                state.currentPosition = ++state.startingPosition
            else
                break
        
        return state.startingPosition < state.input.length
        
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