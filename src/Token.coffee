root = global ? window

class root.Token
    constructor: () ->
    
    # returns false if match unsuccessful
    # returns the position after the match if successful
    # report is a boolean flag
    matches: (state, report) ->
        false

# This is the basic regex token
# It encapsulates concatenation, but it will also be used for generic single-token patterns
# Hence, the root of any pattern tree will be a Sequence
# For now, it also encapsulates alternation; to be specific an alternation is a linked list of Sequences
class root.Sequence extends root.Token
    constructor: (patternString) ->
        @pattern = new Array()
        @alternative = new Token() # can never match
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
                when "|"
                    @alternative = new Sequence(patternString[i+1..])
                    return # ugly hack because coffeescript doesn't support break labels or break 2
                else @pattern.push(new Character(char))
            i++
            
    matches: (state, report) ->
        i = 0
        result = startOfSequence = state.currentPosition
        console.log(this) if report
        console.log(state) if report
        for subpattern in @pattern
            if not result = subpattern.matches(state, report)
                state.currentPosition = startOfSequence
                return @alternative.matches(state, report)
            state.report() if report
        return result
        
# This represents a single literal character
class root.Character extends root.Token
    constructor: (@character) ->
    
    matches: (state, report) ->
        if state.input[state.currentPosition] == @character
            return ++state.currentPosition
        return false
        
        
class root.Wildcard extends root.Token
    constructor: () ->
    
    matches: (state, report) ->
        unless state.input[state.currentPosition] in ["\n", "\r", 1]
            return ++state.currentPosition
        return false
        
        
class root.StartAnchor extends root.Token
    constructor: () ->
    
    matches: (state, report) ->
        if state.input[state.currentPosition - 1] == -1
            return state.currentPosition
        return false

        
class root.EndAnchor extends root.Token
    constructor: () ->
    
    matches: (state, report) ->
        if state.input[state.currentPosition] == 1
            return state.currentPosition
        return false