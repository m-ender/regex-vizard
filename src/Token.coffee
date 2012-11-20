root = global ? window

class root.Token
    constructor: () ->
    
    # returns false if match unsuccessful
    # returns the position after the match if successful
    matches: (input, currentPosition) ->
        no

# This is the basic regex token
# It encapsulates concatenation, but it will also be used for generic single-token patterns
# Hence, the root of any pattern tree will be a Sequence
class root.Sequence extends root.Token
    constructor: (patternString) ->
        @pattern = new Array()
        i = 0
        while i < patternString.length
            char = patternString.charAt(i)
            switch char
                when "\\"
                    actualChar = patternString.charAt(++i)
                    @pattern.push(new Character(actualChar))
                when "^" then @pattern.push(new StartAnchor())
                when "$" then @pattern.push(new EndAnchor())
                when "." then @pattern.push(new Wildcard())
                else @pattern.push(new Character(char))
            i++         
            
    matches: (input, currentPosition) ->
        i = 0
        for subpattern in @pattern
            unless currentPosition = subpattern.matches(input, currentPosition)
                break
        return currentPosition

# This represents a single literal character
class root.Character extends root.Token
    constructor: (@character) ->
    
    matches: (input, currentPosition) ->
        if input[currentPosition] == @character
            return currentPosition + 1
        return false
        
        
class root.Wildcard extends root.Token
    constructor: () ->
    matches: (input, currentPosition) ->
        unless input[currentPosition] in ["\n", "\r", 1]
            return currentPosition + 1
        return false
        
        
class root.StartAnchor extends root.Token
    constructor: () ->
    
    matches: (input, currentPosition) ->
        if input[currentPosition - 1] == -1
            return currentPosition
        return false

        
class root.EndAnchor extends root.Token
    constructor: () ->
    
    matches: (input, currentPosition) ->
        if input[currentPosition] == 1
            return currentPosition
        return false