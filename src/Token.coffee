root = global ? window

class root.Token
    constructor: (token) ->    
        # list of sub-tokens
        # Sequences and Alternations will use a list of arbitrary length
        # Quantifiers and Groups will use a single token in the list
        # Atomic tokens like characters and anchors will have this list empty
        @subtokens = []
        if token instanceof Token
            @subtokens.push(token)
    
    # returns false if match unsuccessful
    # returns the position after the match if successful
    # report is a boolean flag
    matches: (state, report) ->
        false
    
# The root of any pattern.
class root.RootToken extends root.Token
    matches: (state, report) ->
        return @subtokens[0].matches(state,report)

class root.Alternation extends root.Token
    
# This encapsulates concatenation.
# Empty (sub)patterns are also represented by (empty) sequences
class root.Sequence extends root.Token            
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
    matches: (state, report) ->
        return @pattern.matches(state, report)
        
# This represents a single literal character
class root.Character extends root.Token
    constructor: (@character) ->
        super()
        
    matches: (state, report) ->
        if state.input[state.currentPosition] == @character
            return ++state.currentPosition
        return false
        
        
class root.Wildcard extends root.Token    
    matches: (state, report) ->
        unless state.input[state.currentPosition] in ["\n", "\r", 1]
            return ++state.currentPosition
        return false
        
        
class root.StartAnchor extends root.Token    
    matches: (state, report) ->
        if state.input[state.currentPosition - 1] == -1
            return state.currentPosition
        return false

        
class root.EndAnchor extends root.Token    
    matches: (state, report) ->
        if state.input[state.currentPosition] == 1
            return state.currentPosition
        return false
        
class root.Option extends root.Token