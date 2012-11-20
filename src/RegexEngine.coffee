root = global ? window

class root.RegexEngine
    constructor: () ->      

    match: (regexString, inputString) ->
        console.log("Regex string:", regexString)
        console.log("Input string:", inputString)
        
        regex = new Sequence(regexString)
        
        console.log("Regex pattern:", regex)
        
        # Build character array and surround it with -1 and 1 as guards for the
        # start and end of the input string
        input = [-1].concat(inputString.split(""))
        input.push(1)
        console.log("Input:", input)
        
        startingPosition = 1
        
        while startingPosition < input.length and not regex.matches(input, startingPosition)
            startingPosition++
        
        return startingPosition < input.length
        