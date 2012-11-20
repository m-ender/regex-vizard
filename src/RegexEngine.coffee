root = global ? window

class root.RegexEngine
    constructor: () ->
        if typeof module != "undefined" && module.exports
            #On a server
            @Regex = require("Regex").Regex
        else
            #On a client
            @Regex = window.Regex        

    match: (regexString, inputString) ->
        console.log("Regex string:", regexString)
        console.log("Input string:", inputString)
        
        regex = new @Regex(regexString)
        console.log("Regex pattern:", regex.pattern)
        
        input = [-1].concat(inputString.split(""))
        input.push(1)
        console.log("Input:", input)
        
        startingPosition = 1
        
        while startingPosition < input.length and not regex.match(input, startingPosition)
            startingPosition++
        
        return startingPosition < input.length
        