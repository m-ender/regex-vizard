root = global ? window

class root.Parser
    constructor: () -> 
    
    parsePattern: (string) ->
        # In order not to patch in disjunctions once the first | has been read, we treat everything as an
        # disjunction of sequences (possibly with only one alternative or only one token in the sequence).
        # Unnecessary disjunctions and sequences will be removed at the end.
        # We also use a group as the root of the pattern, which will correspond to capturing group 0.
        debug =
            sourceOpenLength: 0
            sourceCloseLength: 0
            id: 0
        treeRoot = new Group(debug, new Disjunction(null, new Sequence()), 0)
        nestingStack = []
        current = treeRoot.subtokens[0]
        i = 0
        
        lastCaptureIndex = 0
        lastId = 0
        while i < string.length
            char = string.charAt(i)
            switch char
                when "\\"
                    start = i
                    [i, element] = @parseEscapeSequence(false, string, i+1)
                    element.debug =
                        sourceLength: i - start
                        id: ++lastId
                    @append(current, element)
                when "["
                    i = @parseCharacterClass(string, current, i+1, ++lastId)
                when "^"
                    debug =
                        sourceLength: 1
                        id: ++lastId
                    @append(current, new StartAnchor(debug))
                    ++i
                when "$"
                    debug =
                        sourceLength: 1
                        id: ++lastId
                    @append(current, new EndAnchor(debug))
                    ++i
                when "."
                    debug =
                        sourceLength: 1
                        id: ++lastId
                    @append(current, new Wildcard(debug))
                    ++i
                when "|"
                    current.subtokens.push(new Sequence())
                    ++i
                when "("
                    debug =
                        sourceOpenLength: 1
                        sourceCloseLength: 1
                        id: ++lastId
                    group = new Group(debug, new Disjunction(null, new Sequence()), ++lastCaptureIndex)
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
                    i = @parseQuantifier(current, char, i, ++lastId)
                else
                    debug =
                        sourceLength: 1
                        id: ++lastId
                    @append(current, new Character(debug, char))
                    ++i
        if nestingStack.length != 0
            throw {
                name: "MissingClosingParenthesisException"
                message: "Missing closing parenthesis \")\""
            }
        # Now traverse the token tree to remove unnecessary disjunctions and sequences
        squash = (token) ->
            if token.subtokens.length > 0
                for i in [0..token.subtokens.length-1]
                    subtoken = token.subtokens[i]
                    while ((subtoken instanceof Disjunction) or (subtoken instanceof Sequence)) and (subtoken.subtokens.length == 1)
                        token.subtokens[i] = subtoken.subtokens[0]
                        subtoken = token.subtokens[i]
                    squash(subtoken)
        
        squash(treeRoot)
        
        # Now traverse token tree again to tell quantifiers which groups they contain
        fillGroupRanges = (token) ->
            if token instanceof Group
                min = token.index
                max = token.index
            else
                min = Infinity
                max = -Infinity
                
            if token.subtokens.length > 0
                for subtoken in token.subtokens
                    [subMin, subMax] = fillGroupRanges(subtoken)
                    min = Math.min(min, subMin)
                    max = Math.max(max, subMax)
                    
            if token instanceof Quantifier and min < Infinity and max > -Infinity
                    token.setGroupRange(min, max-min+1)
                    
            return [min, max]
        
        [_, maxGroup] = fillGroupRanges(treeRoot)
        
        return [treeRoot, maxGroup]
        
    parseCharacterClass: (string, current, i, id) ->
        if i < string.length and string.charAt(i) == "^"
            negated = true
            ++i
        else
            negated = false
            
        elements = []
        
        while i < string.length                
            char = string.charAt(i)
            switch char
                when "]"
                    debug =
                        sourceOpenLength: if negated then 2 else 1
                        sourceCloseLength: 1
                        id: id
                    @append(current, new CharacterClass(debug, negated, elements))
                    return i+1
                when "\\"
                    [i, element] = @parseEscapeSequence(true, string, i+1)
                    elements.push(element)
                when "-"
                    lastElement = elements[elements.length-1]
                    if lastElement instanceof CharacterClass
                        throw {
                            name: "CharacterClassInRangeException"
                            message: "Built-in character classes cannot be used in ranges"
                        }
                    if typeof lastElement is "string" and i+1 < string.length and (nextElement = string.charAt(i+1)) != "]"
                        newI = i + 2
                        if nextElement == "\\"
                            [newI, nextElement] = @parseEscapeSequence(true, string, i+2)
                        
                        if nextElement instanceof CharacterClass
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
                        elements.pop()
                        elements.push(
                            start: startC
                            end:   endC
                        )
                        i = newI
                    else
                        elements.push(char)                        
                        ++i
                else
                    elements.push(char)
                    ++i
        
        throw { # we need the curly brackets here, because CoffeeScript will cause problems, otherwise
            name: "UnterminatedCharacterClassException"
            message: "Missing closing bracket \"]\""
            index: i
        }
        
    # inCharacterClass is a boolean that indicates where the current sequence was found
    parseEscapeSequence: (inCharacterClass, string, i) ->
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
                
            # built-in character classes
            when "d", "D"
                negated = char is "D"
                element = new DigitClass(null, negated)
            when "w", "W"
                negated = char is "W"
                element = new WordClass(null, negated)
            when "s", "S"
                negated = char is "S"
                element = new WhitespaceClass(null, negated)
                
            # treat b correctly
            when "b"
                element = if inCharacterClass then "\b" else new WordBoundary(null, false)
            when "B"
                element = if inCharacterClass then "B" else new WordBoundary(null, true)
                
            # all other characters are treated literally
            else
                element = char
        
        if typeof element is "string" and not inCharacterClass
            element = new Character(null, element)
        
        return [i + 1, element]
        
    parseQuantifier: (current, char, i, id) ->
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
        
        debug =
            sourceLength: 1
            id: id
        
        quantifierClass =
            "*": RepeatZeroOrMore
            "+": RepeatOneOrMore
            "?": Option
            
        @append(current, new (quantifierClass[char])(debug, target)) # take the currently last token, stuff it into an appropriate quantifier token and append the option instead
        return i+1
        
    append: (current, token) ->
        st = current.subtokens
        st[st.length-1].subtokens.push(token)
        
    remove: (current) ->
        st = current.subtokens
        return st[st.length-1].subtokens.pop()