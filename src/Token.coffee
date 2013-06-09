root = global ? window

class root.Token
    constructor: (token) ->    
        # list of sub-tokens
        # Sequences and Disjunctions will use a list of arbitrary length
        # Quantifiers and Groups will use a single token in the list
        # Atomic tokens like characters and anchors will have this list empty
        @subtokens = []
        if token and token instanceof Token
            @subtokens.push(token)
        @reset()
    
    # this function will attempt one match at a time - that is one alternative of an disjunction or a certain
    # number of repetitions
    # returns 0 if match unsuccessful but there might be matches on further attempts
    # returns the position after the match if successful
    # returns false if match ultimately unsuccessful (and internal state resets)
    # report is a boolean flag
    nextMatch: (state, report) ->
        false
        
    reset: () ->
        # Resets all subtokens recursively
        for subtoken in @subtokens
            subtoken.reset()
        
# This represents a single literal character
class root.Character extends root.Token
    constructor: (@character) ->
        super()
        
    reset: () ->
        super()
        @attempted = false
        
    nextMatch: (state, report) ->
        if @attempted
            @reset()
            return false
        
        if state.input[state.currentPosition] == @character
            @attempted = true
            return state.currentPosition + 1
        return false
        
class root.CharacterClass extends root.Token
    constructor: () ->
        super()
        @characters = []
        
    reset: () ->
        super()
        @attempted = false
        
    addCharacter: (character) ->
        @characters.push(character)
        
    nextMatch: (state, report) ->
        if @attempted
            @reset()
            return false
            
        if state.input[state.currentPosition] in @characters
            @attempted = true
            return state.currentPosition + 1
            
        return false
        
class root.Wildcard extends root.Token
    constructor: () ->
        super()
        
    reset: () ->
        super()
        @attempted = false
        
    nextMatch: (state, report) ->
        if @attempted
            @reset()
            return false
        
        unless state.input[state.currentPosition] in ["\n", "\r", 1]
            @attempted = true
            return state.currentPosition + 1
        return false
        
class root.StartAnchor extends root.Token    
    constructor: () ->
        super()
        
    reset: () ->
        super()
        @attempted = false
        
    nextMatch: (state, report) ->
        if @attempted
            @reset()
            return false
            
        if state.input[state.currentPosition - 1] == -1
            @attempted = true
            return state.currentPosition
        return false

        
class root.EndAnchor extends root.Token    
    constructor: () ->
        super()
        
    reset: () ->
        super()
        @attempted = false
        
    nextMatch: (state, report) ->
        if @attempted
            @reset()
            return false
            
        if state.input[state.currentPosition] == 1
            @attempted = true
            return state.currentPosition
        return false

class root.Disjunction extends root.Token
    constructor: (token) ->
        super(token)
        
    reset: () ->
        super()
        @i = 0 # the first subtoken to try upon calling nextMatch

    nextMatch: (state, report) ->
        if @i == @subtokens.length
            @reset()
            return false
            
        result = @subtokens[@i].nextMatch(state, report)
        
        if result != false
            return result
        else
            ++@i
            return 0

# This encapsulates concatenation.
# Empty (sub)patterns are also represented by (empty) sequences
class root.Sequence extends root.Token
    constructor: () ->
        super()
        
    reset: () ->
        super()
        @i = 0 # the first subtoken to try upon calling nextMatch
        @pos = [] # "current" positions that were used by successful subtokens
        
    nextMatch: (state, report) ->            
        if @i == -1
            @reset()
            return false
            
        if @subtokens.length == 0
            --@i
            return state.currentPosition

        result = @subtokens[@i].nextMatch(state, report)
        switch result
            when false
                --@i
                if @pos.length > 0
                    state.currentPosition = @pos.pop()
                return 0
            when -1, 0
                return result
            else
                if @i == @subtokens.length - 1
                    return result
                else
                    ++@i
                    @pos.push(state.currentPosition)
                    state.currentPosition = result                    
                    return -1

class root.Group extends root.Token
    constructor: (token) ->
        super(token)
        
    reset: () ->
        super()
        @result = 0
        
    nextMatch: (state, report) ->
        if @result isnt 0
            result = @result
            @result = 0
            return result
            
        result = @subtokens[0].nextMatch(state, report)
        switch result
            when 0, -1
                return result
            when false
                @result = false
                return 0
            else
                @result = result
                return -1
        
class root.Quantifier extends root.Token
    constructor: (token, @min, @max) ->
        super(token)
        
    reset: () ->
        super()
        @instances = [@clone(@subtokens[0])] # instances of the subtoken used for the individual repetitions
        @pos = []                            # "current" positions that were used for successful matches
        @result = false
        @emptyInstances = 0
        
    nextMatch: (state, report) ->
        if @result
            result = @result
            @result = false
            if @instances.length >= @min
                return result
            else
                return 0
            
        if @instances.length == 0
            @reset()
            return false
            
        if @instances.length > @max
            @instances.pop()
            result = state.currentPosition
            if @pos.length > 0
                state.currentPosition = @pos.pop()            
            if result == state.currentPosition
                --@emptyInstances
            return result
            
        instance = @instances.pop()
        
        result = instance.nextMatch(state, report)
        switch result
            when 0, -1
                @instances.push(instance)
                return result
            when false
                @result = state.currentPosition
                if @pos.length > 0
                    state.currentPosition = @pos.pop()
                    if @result == state.currentPosition
                        --@emptyInstances
                return 0
            else
                @instances.push(instance)
                if result == state.currentPosition and @emptyInstances >= @min
                    return @nextMatch(state, report)
                
                if result == state.currentPosition
                    ++@emptyInstances
                
                @instances.push(@clone(@subtokens[0]))
                @pos.push(state.currentPosition)
                state.currentPosition = result
                return -1

    # Taken from http://coffeescriptcookbook.com/chapters/classes_and_objects/cloning and slightly modified
    clone: (obj) ->
        if not obj? or typeof obj isnt 'object'
            return obj

        newInstance = new obj.constructor()

        for key of obj
            newInstance[key] = @clone(obj[key])

        return newInstance
        
class root.Option extends root.Quantifier
    constructor: (token) ->
        super(token, 0, 1)
        
    reset: () ->
        super()
        @result = false
        
    nextMatch: (state, report) ->
        if @result
            result = @result
            @result = false
            return result
        
        switch @repetitions
            when 1
                result = @subtokens[0].nextMatch(state, report)
                
                if result == false
                    --@repetitions
                    return 0
                else if result <= 0
                    return result
                else
                    @result = result
                    return -1
            when 0
                --@repetitions
                return state.currentPosition
            when -1
                @reset()
                return false
        
    reset: () ->
        @repetitions = 1
        
class root.RepeatZeroOrMore extends root.Quantifier
    constructor: (token) ->
        super(token, 0, Infinity)
        
class root.RepeatOneOrMore extends root.Quantifier
    constructor: (token) ->
        super(token, 1, Infinity)