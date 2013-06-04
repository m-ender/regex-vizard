root = global ? window

class root.Token
    constructor: (token) ->    
        # list of sub-tokens
        # Sequences and Alternations will use a list of arbitrary length
        # Quantifiers and Groups will use a single token in the list
        # Atomic tokens like characters and anchors will have this list empty
        @subtokens = []
        if token and token instanceof Token
            @subtokens.push(token)
    
    # this function will attempt one match at a time - that is one alternative of an alternation or a certain
    # number of repetitions
    # returns 0 if match unsuccessful but there might be matches on further attempts
    # returns the position after the match if successful
    # returns false if match ultimately unsuccessful (and internal state resets)
    # report is a boolean flag
    nextMatch: (state, report) ->
        false
    
# The root of any pattern.
class root.RootToken extends root.Token
    nextMatch: (state, report) ->
        return @subtokens[0].nextMatch(state,report)

class root.Alternation extends root.Token
    constructor: (token) ->
        super(token)
        @i = 0 # the first subtoken to try upon calling nextMatch

    nextMatch: (state, report) ->
        result = subtokens[@i].nextMatch(state, report)
        while result == 0
            result = subtokens[@i].nextMatch(state, report)
        if result == false
            ++@i
    
# This encapsulates concatenation.
# Empty (sub)patterns are also represented by (empty) sequences
class root.Sequence extends root.Token
    constructor: () ->
        super()
        @i = 0 # the first subtoken to try upon calling nextMatch
        
    nextMatch: (state, report) ->
        result = state.currentPosition
        while @i >= 0 and @i < subtokens.length
            result = subtokens[@i].nextMatch(state, report)
            while result == 0
                result = subtokens[@i].nextMatch(state, report)
            if result == false
                --@i
            else
                ++@i
        if result == false            # if the sequence cannot match
            @i = 0                    # start over next time
        else                          # if the sequence found a match
            @i = subtokens.length - 1 # start by asking for another match from the last subtoken next time
        return result

class root.Group extends root.Token            
    matches: (state, report) ->
        return @pattern.matches(state, report)
        
# This represents a single literal character
class root.Character extends root.Token
    constructor: (@character) ->
        super()
        @reset()
        
    nextMatch: (state, report) ->
        if @attempted
            @reset()
            return false
        console.log(state)
        if state.input[state.currentPosition] == @character
            @attempted = true
            return state.currentPosition + 1
        return false
        
    reset: () ->
        @attempted = false
        
class root.Wildcard extends root.Token
    constructor: () ->
        super()
        @reset()
        
    nextMatch: (state, report) ->
        if @attempted
            @reset()
            return false
        
        unless state.input[state.currentPosition] in ["\n", "\r", 1]
            @attempted = true
            return state.currentPosition + 1
        return false
        
    reset: () ->
        @attempted = false
        
class root.StartAnchor extends root.Token    
    constructor: () ->
        super()
        @reset()
        
    nextMatch: (state, report) ->
        if @attempted
            @reset()
            return false
            
        if state.input[state.currentPosition - 1] == -1
            @attempted = true
            return state.currentPosition
        return false
        
    reset: () ->
        @attempted = false

        
class root.EndAnchor extends root.Token    
    constructor: () ->
        super()
        @reset()
        
    nextMatch: (state, report) ->
        if @attempted
            @reset()
            return false
            
        if state.input[state.currentPosition] == 1
            @attempted = true
            return state.currentPosition
        return false
        
    reset: () ->
        @attempted = false
        
class root.Quantifier extends root.Token
    constructor: (token, @min, @max) ->
        super(token)
        @reset()
                
    reset: () ->
        @repetitions = []
        
class root.Option extends root.Quantifier
    constructor: () ->
        super()
        @reset()
        
    nextMatch: () ->
        switch @repetitions
            when 1
                result = subtokens[0].nextMatch(state, report)
                while result == 0
                    result = subtokens[0].nextMatch(state, report)
                
                if result > 0
                    return result
                if result == false
                    --@repetitions
                    return 0
            when 0
                --@repetitions
                return state.currentPosition
            when -1
                @reset()
                return false
        
        
        
    reset: () ->
        @repetitions = 1