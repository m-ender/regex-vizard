root = global ? window

class root.Parser
    constructor: () -> 
    
    parsePattern: (string) ->
        # In order not to patch in disjunctions once the first | has been read, we treat everything as an
        # disjunction of sequences (possibly with only one alternative or only one token in the sequence).
        # Unnecessary disjunctions and sequences will be removed at the end.
        # We also use a group as the root of the pattern, which will correspond to capturing group 0.
        regex = new Group()
        nestingStack = []
        current = new Disjunction(new Sequence())
        regex.subtokens.push(current)
        i = 0

        while i < string.length
            char = string.charAt(i)
            switch char
                when "\\"
                    i = @parseEscapeSequence(string, current, i+1)
                when "["
                    i = @parseCharacterClass(string, current, i+1)
                when "^"
                    @append(current, new StartAnchor())
                    ++i
                when "$"
                    @append(current, new EndAnchor())
                    ++i
                when "."
                    @append(current, new Wildcard())
                    ++i
                when "|"
                    current.subtokens.push(new Sequence())
                    ++i
                when "("
                    group = new Group(new Disjunction(new Sequence()))
                    @append(current, group)
                    nestingStack.push(current)
                    current = group.subtokens[0]
                    ++i
                when ")"
                    if nestingStack.length == 0
                        throw {
                            name: "UnmatchedClosingParenthesisException"
                            message: "Unmatched closing parenthesis \")\" at index " + i
                            index: i
                        }
                    current = nestingStack.pop()
                    ++i
                when "?", "*", "+"
                    i = @parseQuantifier(current, char, i)
                else
                    @append(current, new Character(char))
                    ++i
        if nestingStack.length != 0
            throw {
                name: "MissingClosingParenthesisException"
                message: "Missing closing parenthesis \")\""
            }
        # Now traverse the token tree to remove unnecessary disjunctions and sequences
        traverse = (token) ->
            if token.subtokens.length > 0
                for i in [0..token.subtokens.length-1]
                    subtoken = token.subtokens[i]
                    while ((subtoken instanceof Disjunction) or (subtoken instanceof Sequence)) and (subtoken.subtokens.length == 1)
                        token.subtokens[i] = subtoken.subtokens[0]
                        subtoken = token.subtokens[i]
                    traverse(subtoken)
    
        traverse(regex)
        return regex
        
    parseEscapeSequence: (string, current, i) ->
        if i == string.length
            throw { # we need the curly brackets here, because CoffeeScript will cause problems, otherwise
                name: "NothingToEscapeException"
                message: "There is nothing to escape. Most likely, the pattern ends in a backslash \"\\\""
                index: i-1
            }
        char = string.charAt(i)
        switch char
            # special characters
            when "0"
                @append(current, new Character("\0"))
            when "f"
                @append(current, new Character("\f"))
            when "n"
                @append(current, new Character("\n"))
            when "r"
                @append(current, new Character("\r"))
            when "t"
                @append(current, new Character("\t"))
            when "v"
                @append(current, new Character("\v"))
                
            # built-in character classes
            when "d", "D"
                negated = char is "D"
                @append(current, new CharacterClass(negated, [], [
                    start: "0".charCodeAt(0)
                    end:   "9".charCodeAt(0)
                ]))
            when "w", "W"
                negated = char is "W"
                @append(current, new CharacterClass(negated, ["_"], [
                    start: "A".charCodeAt(0)
                    end:   "Z".charCodeAt(0)
                   ,
                    start: "a".charCodeAt(0)
                    end:   "z".charCodeAt(0)
                   ,
                    start: "0".charCodeAt(0)
                    end:   "9".charCodeAt(0)
                ]))
            when "s", "S"
                negated = char is "S"
                @append(current, new CharacterClass(negated, [
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
                ]))
                
            # all other characters are treated literally
            else
                @append(current, new Character(char))
        
        return i + 1
        
    parseCharacterClass: (string, current, i) ->
        if i < string.length and string.charAt(i) == "^"
            negated = true
            ++i
        else
            negated = false
            
        lastElement = false
        characters = []
        ranges = []
        subclasses = []
        
        while i < string.length                
            char = string.charAt(i)
            switch char
                when "]"
                    @append(current, new CharacterClass(negated, characters, ranges, subclasses))
                    return i+1
                when "\\"
                    [i, lastElement] = @parseCharacterClassEscapeSequence(string, i+1)
                    if lastElement instanceof CharacterClass
                        subclasses.push(lastElement)
                    else
                        characters.push(lastElement)
                when "-"
                    if lastElement and i+1 < string.length and (nextElement = string.charAt(i+1)) != "]"
                        
                        newI = i + 2
                        if nextElement == "\\"
                            [newI, nextElement] = @parseCharacterClassEscapeSequence(string, i+2)
                        
                        if lastElement instanceof CharacterClass or nextElement instanceof CharacterClass
                            throw {
                                name: "CharacterClassInRangeException"
                                message: "Built-in character classes cannot be used in ranges"
                            }
                        
                        startC = lastElement.charCodeAt(0)
                        endC = nextElement.charCodeAt(0)
                                                
                        if startC > endC
                            throw {
                                name: "CharacterClassRangeOutOfOrderException"
                                message: "The character class \"#{lastElement}\" to \"#{nextElement}\" is out of order."
                            }
                        characters.pop()
                        lastElement = false
                        ranges.push(
                            start: startC
                            end:   endC
                        )
                        i = newI
                    else
                        lastElement = char
                        characters.push(lastElement)                        
                        ++i
                else
                    lastElement = char
                    characters.push(lastElement)
                    ++i
        
        throw { # we need the curly brackets here, because CoffeeScript will cause problems, otherwise
            name: "UnterminatedCharacterClassException"
            message: "Missing closing bracket \"]\""
            index: i
        }
        
    parseCharacterClassEscapeSequence: (string, i) ->
        if i == string.length
            throw { # we need the curly brackets here, because CoffeeScript will cause problems, otherwise
                name: "NothingToEscapeException"
                message: "There is nothing to escape. Most likely, the pattern ends in a backslash \"\\\""
                index: i-1
            }
        char = string.charAt(i)
        switch char
            # special characters
            when "0"
                element = "\0"
            when "f"
                element = "\f"
            when "n"
                element = "\n"
            when "r"
                element = "\r"
            when "t"
                element = "\t"
            when "v"
                element = "\v"
            when "b" # this one is special to character classes
                element = "\b"
                
            # built-in character classes
            when "d", "D"
                negated = char is "D"
                element = new CharacterClass(negated, [], [
                    start: "0".charCodeAt(0)
                    end:   "9".charCodeAt(0)
                ])
            when "w", "W"
                negated = char is "W"
                element = new CharacterClass(negated, ["_"], [
                    start: "A".charCodeAt(0)
                    end:   "Z".charCodeAt(0)
                   ,
                    start: "a".charCodeAt(0)
                    end:   "z".charCodeAt(0)
                   ,
                    start: "0".charCodeAt(0)
                    end:   "9".charCodeAt(0)
                ])
            when "s", "S"
                negated = char is "S"
                element = new CharacterClass(negated, [
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
                
            # all other characters are treated literally
            else
                element = char
        
        return [i + 1, element]
        
    parseQuantifier: (current, char, i) ->
        st = current.subtokens
        if st[st.length-1].subtokens.length == 0
            throw {
                name: "NothingToRepeatException"
                message: "The is nothing to repeat for quantifier \"" + char + "\" at index " + i
                index: i
            }
        target = @remove(current)
        unless (target instanceof Group) or (target instanceof Character) or (target instanceof Wildcard) or (target instanceof CharacterClass)
            throw {
                name: "NothingToRepeatException"
                message: "The is nothing to repeat for quantifier \"" + char + "\" at index " + i + ". Only groups, characters and wildcard may be quantified."
                index: i
            }
        
        quantifierClass =
            "*": RepeatZeroOrMore
            "+": RepeatOneOrMore
            "?": Option
            
        @append(current, new (quantifierClass[char])(target)) # take the currently last token, stuff it into an appropriate quantifier token and append the option instead
        return i+1
        
    append: (current, token) ->
        st = current.subtokens
        st[st.length-1].subtokens.push(token)
        
    remove: (current) ->
        st = current.subtokens
        return st[st.length-1].subtokens.pop()