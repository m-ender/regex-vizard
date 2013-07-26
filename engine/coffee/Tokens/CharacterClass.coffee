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

class root.CharacterClass extends root.BasicToken
    # negated is a boolean
    # elements is an array of (string) characters, CharacterRange objects and other CharacterClass tokens
    constructor: (debug, @negated = false, @elements = []) ->
        super(debug)

    setupStateObject: ->
        obj = super
        obj.type = 'characterClass'
        return obj

    addElement: (element) ->
        @elements.push(element)

    addRange: (first, last) ->
        @elements.push(new CharacterRange(first, last))

    matches: (state) ->
        char = state.input[state.currentPosition]
        if @isInClass(char)
            return Result.Success(state.currentPosition + 1)
        else
            return Result.Failure()

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

class root.Wildcard extends root.BasicToken
    constructor: (debug) ->
        super

    setupStateObject: ->
        obj = super
        obj.type = 'wildcard'
        return obj

    matches: (state) ->
        unless state.input[state.currentPosition] in ["\n", "\r", "\u2028", "\u2029", EndGuard]
            return Result.Success(state.currentPosition + 1)
        else
            return Result.Failure()
