root = global ? window

# Represents a character range for use inside character classes
# All methods can take either an integer or a string (whose first
# character will be taken).
class root.CharacterRange
    constructor: (first, last) ->
        @first = @sanitize first
        @last = @sanitize last

    isInRange: (char) ->
        @first <= @sanitize(char) <= @last

    sanitize: (char) ->
        if typeof char is "string" then char.charCodeAt 0 else char

class root.CharacterClass extends root.Token
    # negated is a boolean
    # elements is an array of (string) characters, anonymous range objects and other CharacterClass tokens
    constructor: (debug, @negated = false, @elements = []) ->
        super(debug)

    reset: (state) ->
        super
        state.tokens[@debug.id].attempted = false

    setupStateObject: ->
        type: 'characterClass'
        subtype: 'customClass'
        status: Inactive
        attempted: false

    register: (state) ->
        state.tokens[@debug.id] = @setupStateObject()
        # do not recurse into subtokens as they are not "full-fledged" tokens

    addElement: (element) ->
        @elements.push(element)

    addRange: (first, last) ->
        @elements.push(new CharacterRange(first, last))

    nextMatch: (state) ->
        tokenState = state.tokens[@debug.id]
        if tokenState.attempted
            @reset(state)
            return false

        char = state.input[state.currentPosition]

        if @isInClass(char)
            tokenState.attempted = true
            return state.currentPosition + 1

        return false

    # This can be used to query whether a character is inside the class without changing the token's
    # internal state. This is useful for nested character classes and word boundaries.
    isInClass: (char) ->
        if char in [StartGuard, EndGuard] # the StartGuard is only included for use in word boundaries
            return false

        for element in @elements
            if (typeof element is "string"        and char is element or
                element instanceof CharacterClass and element.isInClass(char) or
                element instanceof CharacterRange and element.isInRange(char))
              return not @negated

        return @negated

# For built-in \d and \D
class root.DigitClass extends root.CharacterClass
    constructor: (debug, negated = false) ->
        super(debug, negated, [new CharacterRange("0", "9")])

    setupStateObject: ->
        obj = super
        obj.subtype = 'digitClass'
        return obj

# For built-in \w and \W
class root.WordClass extends root.CharacterClass
    constructor: (debug, negated = false) ->
        super(debug, negated, [
            new CharacterRange("A", "Z")
            new CharacterRange("a", "z")
            new CharacterRange("0", "9")
            "_"
        ])

    setupStateObject: ->
        obj = super
        obj.subtype = 'wordClass'
        return obj

# For built-in \s and \S
class root.WhitespaceClass extends root.CharacterClass
    constructor: (debug, negated = false) ->
        super(debug, negated, [
            new CharacterRange(0x9, 0xd) # horizontal tab, line feed, vertical tab, form feed, carriage return
            "\u0020" # space
            "\u00a0" # no-break space
            "\u1680" # ogham space mark
            "\u180e" # mongolian vowel separator
            new CharacterRange(0x2000, 0x200a) # various punctuation and typesetting related characters
            "\u2028" # Unicode line separator
            "\u2029" # Unicode paragraph separator
            "\u202f" # narrow no-break space
            "\u205f" # medium mathematical space
            "\u3000" # ideographic space
            "\ufeff" # zero-width no-break space
        ])

    setupStateObject: ->
        obj = super
        obj.subtype = 'whitespaceClass'
        return obj

class root.Wildcard extends root.Token
    constructor: (debug) ->
        super

    reset: (state) ->
        super
        state.tokens[@debug.id].attempted = false

    setupStateObject: ->
        type: 'wildcard'
        status: Inactive
        attempted: false

    nextMatch: (state) ->
        tokenState = state.tokens[@debug.id]
        if tokenState.attempted
            @reset(state)
            return false

        unless state.input[state.currentPosition] in ["\n", "\r", "\u2028", "\u2029", EndGuard]
            tokenState.attempted = true
            return state.currentPosition + 1
        return false