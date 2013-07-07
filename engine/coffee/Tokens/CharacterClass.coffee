root = global ? window

class root.CharacterClass extends root.Token
    # negated is a boolean
    # elements is an array of (string) characters, anonymous range objects and other CharacterClass tokens
    constructor: (debug, @negated = false, @elements = []) ->
        super(debug)

    reset: () ->
        super()
        @attempted = false

    addCharacter: (character) ->
        @elements.push(character)

    addRange: (startCharacter, endCharacter) ->
        @elements.push(
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
        for element in @elements
            if (typeof element is "string" and char is element or
                element instanceof CharacterClass and element.isInClass(char) or
                element.start <= char.charCodeAt(0) <= element.end)
              inSet = true
              break

        return inSet isnt @negated

# For built-in \d and \D
class root.DigitClass extends root.CharacterClass
    constructor: (debug, negated = false) ->
        super(debug, negated, [
            start: "0".charCodeAt(0)
            end:   "9".charCodeAt(0)
        ])

# For built-in \w and \W
class root.WordClass extends root.CharacterClass
    constructor: (debug, negated = false) ->
        super(debug, negated, [
            start: "A".charCodeAt(0)
            end:   "Z".charCodeAt(0)
           ,
            start: "a".charCodeAt(0)
            end:   "z".charCodeAt(0)
           ,
            start: "0".charCodeAt(0)
            end:   "9".charCodeAt(0)
           ,
            "_"
        ])

# For built-in \s and \S
class root.WhitespaceClass extends root.CharacterClass
    constructor: (debug, negated = false) ->
        super(debug, negated, [
            start: 0x9    # horizontal tab, line feed, vertical tab, form feed, carriage return
            end:   0xd
           ,
            "\u0020" # space
            "\u00a0" # no-break space
            "\u1680" # ogham space mark
            "\u180e" # mongolian vowel separator
           ,
            start: 0x2000 # various punctuation and typesetting related characters
            end:   0x200a
           ,
            "\u2028" # Unicode line separator
            "\u2029" # Unicode paragraph separator
            "\u202f" # narrow no-break space
            "\u205f" # medium mathematical space
            "\u3000" # ideographic space
            "\ufeff" # zero-width no-break space
        ])

class root.Wildcard extends root.Token
    constructor: (debug) ->
        super(debug)

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
