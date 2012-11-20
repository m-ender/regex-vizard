root = global ? window

class root.Regex
    constructor: (inputString) ->
        i = 0
        @pattern = new Array()
        while i < inputString.length
            @pattern.push(inputString.charAt(i))
            i++
     
    match: (input, startingPosition) ->
        input_i = startingPosition
        pattern_i = 0
        while input_i < input.length and pattern_i < @pattern.length and input[input_i] == @pattern[pattern_i]
            input_i++
            pattern_i++
        return pattern_i == @pattern.length
            
            