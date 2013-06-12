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
    # negated is a boolean
    constructor: (@negated = false, character, ranges, subclasses) ->
        super()
        @characters = character or []
        @ranges = ranges or []
        @subclasses = subclasses or []
        
    reset: () ->
        super()
        @attempted = false
        
    addCharacter: (character) ->
        @characters.push(character)
        
    addRange: (startCharacter, endCharacter) ->
        @ranges.push(
            start: startCharacter.charCodeAt(0)
            end: endCharacter.charCodeAt(0)
        )
        
    nextMatch: (state, report) ->
        if @attempted
            @reset()
            return false
            
        char = state.input[state.currentPosition]
                
        if @isInClass(char)
            @attempted = true
            return state.currentPosition + 1
            
        return false
        
    # This can be used to query whether a character is inside the class without changing the token's
    # internal state. This is useful for nested character classes and word boundaries.
    isInClass: (char) ->
        if char in [StartGuard, EndGuard] # the StartGuard is only included for use in word boundaries
            return false
            
        inSet = false
        if char in @characters
            inSet = true
        else
            for range in @ranges
                if range.start <= char.charCodeAt(0) <= range.end
                    inSet = true
                    break
                    
        unless inSet
            for subclass in @subclasses
                if subclass.isInClass(char)
                    inSet = true
                    break
                    
        return inSet isnt @negated

# For built-in \d and \D        
class root.DigitClass extends root.CharacterClass
    constructor: (negated = false) ->
        super(negated, [], [
            start: "0".charCodeAt(0)
            end:   "9".charCodeAt(0)
        ])

# For built-in \w and \W        
class root.WordClass extends root.CharacterClass
    constructor: (negated = false) ->
        super(negated, ["_"], [
            start: "A".charCodeAt(0)
            end:   "Z".charCodeAt(0)
           ,
            start: "a".charCodeAt(0)
            end:   "z".charCodeAt(0)
           ,
            start: "0".charCodeAt(0)
            end:   "9".charCodeAt(0)
        ])

# For built-in \s and \S        
class root.WhitespaceClass extends root.CharacterClass
    constructor: (negated = false) ->
        super(negated, [
            "\u0020" # space
            "\u00a0" # no-break space
            "\u1680" # ogham space mark
            "\u180e" # mongolian vowel separator
            "\u2028" # Unicode line separator
            "\u2029" # Unicode paragraph separator
            "\u202f" # narrow no-break space
            "\u205f" # medium mathematical space
            "\u3000" # ideographic space
            "\ufeff" # zero-width no-break space
        ], [
            start: 0x9    # horizontal tab, line feed, vertical tab, form feed, carriage return
            end:   0xd
           ,
            start: 0x2000 # various punctuation and typesetting related characters 
            end:   0x200a
        ])
    
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
        
        unless state.input[state.currentPosition] in ["\n", "\r", "\u2028", "\u2029", EndGuard]
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
            
        if state.input[state.currentPosition - 1] == StartGuard
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
            
        if state.input[state.currentPosition] == EndGuard
            @attempted = true
            return state.currentPosition
        return false
        
class root.WordBoundary extends root.Token
    constructor: (@negated = false) ->
        super()
        @wordClass = new WordClass()
        
    reset: () ->
        super()
        @attempted = false
        
    nextMatch: (state, report) ->
        if @attempted
            @reset()
            return false
        leftChar = state.input[state.currentPosition-1]
        rightChar = state.input[state.currentPosition]
        if (@wordClass.isInClass(leftChar) isnt @wordClass.isInClass(rightChar)) isnt @negated
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
    constructor: (token, @index) ->
        super(token)
        
    reset: () ->
        super()
        @result = 0
        @firstPosition = false
        
    nextMatch: (state, report) ->
        if @result isnt 0
            result = @result
            if result is false
                @reset()
            else
                @result = 0
            return result
            
        if @firstPosition is false
            @firstPosition = state.currentPosition
            
        result = @subtokens[0].nextMatch(state, report)
        switch result
            when 0, -1
                return result
            when false
                @result = false
                state.captures[@index] = undefined
                return 0
            else
                state.captures[@index] = state.input[@firstPosition...result].join("")
                @result = result
                return -1
        
class root.Quantifier extends root.Token
    constructor: (token, @min, @max) ->
        super(token)
        @minGroup = -1
        @nGroups = 0
        @clearer = []
        
    reset: () ->
        super()
        @instances = [@clone(@subtokens[0])] # instances of the subtoken used for the individual repetitions
        @pos = []                            # "current" positions that were used for successful matches
        @result = false
        @captureStack = []                   # remembers the captures of hidden instances on the above stack
        
    # @minGroup is the smallest group number contained in the subtokens of this quantifier
    # @nGroups is the number of groups contained in the subtokens of this quantifier
    setGroupRange: (@minGroup, @nGroups) ->
        for i in [0...@nGroups]
            @clearer[i] = undefined
        
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
                            
            if @captureStack.length > 0
                state.captures[@minGroup...@minGroup+@nGroups] = @captureStack.pop()
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
                if @captureStack.length > 0
                    state.captures[@minGroup...@minGroup+@nGroups] = @captureStack.pop()
                
                return 0
            else
                @instances.push(instance)
                # only the first @min instances are allowed to match empty, to avoid infinite loops
                if result == state.currentPosition and @instances.length > @min
                    return @nextMatch(state, report)

                @captureStack.push(state.captures[@minGroup...@minGroup+@nGroups])
                state.captures[@minGroup...@minGroup+@nGroups] = @clearer
                
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
        
class root.RepeatZeroOrMore extends root.Quantifier
    constructor: (token) ->
        super(token, 0, Infinity)
        
class root.RepeatOneOrMore extends root.Quantifier
    constructor: (token) ->
        super(token, 1, Infinity)