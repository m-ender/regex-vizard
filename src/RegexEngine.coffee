root = global ? window

class root.RegexEngine
    constructor: () ->      

    match: (regexString, inputString, report = false) ->
        console.log("Regex string:", regexString) if report
        regex = (new Parser()).parse(regexString)
        console.log("Regex pattern:", regex) if report
        
        # Build character array and surround it with -1 and 1 as guards for the
        # start and end of the input string
        console.log("Input string:", inputString) if report
        input = [-1].concat(inputString.split(""))
        input.push(1)
        console.log("Input:", input) if report
        
        state =
            inputString: inputString
            input: input
            startPosition: 1
            currentPosition: 1
            report: () ->
                console.log("Current match: " + @inputString[@startPosition-1...@currentPosition-1])

        while state.startPosition < state.input.length and not regex.matches(state, report)
            state.currentPosition = ++state.startPosition
        
        return state.startPosition < state.input.length