root = global ? window

class root.Token
    constructor: () ->
    
    # returns false if match unsuccessful
    # returns the position after the match if successful
    # report is a boolean flag
    matches: (state, report) ->
        false
        
    # remainder of the input not processed by this token
    remainder: ""

# This is the basic regex token
# It encapsulates concatenation, but it will also be used for generic single-token patterns
# Hence, the root of any pattern tree will be a Sequence
# For now, it also encapsulates alternation; to be specific an alternation is a linked list of Sequences
class root.Sequence extends root.Token
    constructor: (patternString) ->
        @pattern = new Array()
        @alternative = new Token() # can never match
        i = 0
        # Instead of iterating over character indices, we are slicing away processed bits from the front
        # of the string. This is probably horribly inefficient, but for now it's necessary for the
        # remainder concept to work.
        while patternString.length > 0
            char = patternString.charAt(0)
            switch char
                when "\\"
                    if patternString.length == 1
                        throw { # we need the curly brackets here, because CoffeeScript will cause problems, otherwise
                            name: "NothingToEscapeException"
                            message: "There is nothing to escape. Most likely, the pattern ends in a backslash \"\\\""
                        }
                    actualChar = patternString.charAt(1)
                    @pattern.push(new Character(actualChar))
                    patternString = patternString[2..]
                when "^"
                    @pattern.push(new StartAnchor())
                    patternString = patternString[1..]
                when "$"
                    @pattern.push(new EndAnchor())
                    patternString = patternString[1..]
                when "."
                    @pattern.push(new Wildcard())
                    patternString = patternString[1..]
                when "|"
                    @alternative = new Sequence(patternString[i+1..])
                    @remainder = @alternative.remainder
                    return # ugly hack because coffeescript doesn't support break labels or "break 2"
                when "("
                    group = new Group(patternString[i+1..])
                    patternString = group.remainder
                    @pattern.push(group)
                when ")"
                    @remainder = patternString[i..]
                    return
                else
                    @pattern.push(new Character(char))
                    patternString = patternString[1..]
            
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

class root.Group extends root.Token
    constructor: (patternString) ->
        @pattern = new Sequence(patternString)
        if @pattern.remainder.length > 0 and @pattern.remainder.charAt(0) == ")"
            @remainder = @pattern.remainder[1..]
            return
        else
            throw {
                name: "MissingClosingParenthesisException"
                message: "Missing closing parenthesis \")\""
            }
            
    matches: (state, report) ->
        return @pattern.matches(state, report)
        
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