root = global ? window

class root.Parser
    constructor: () ->    
    
    parsePattern: (string) ->
        # In order not to set up alternations after the first alternative has been read, we treat everything as an
        # alternation of sequences (possibly with only one alternative or only one token in the sequence).
        # Unnecessary alternations and sequences will be removed in the end.
        # We also use a group as the root of the pattern, which will correspond to capturing group 0.
        regex = new Group()
        nestingStack = []
        current = new Alternation(new Sequence())
        regex.subtokens.push(current)
        i = 0
        len = string.length
            
        while i < len
            char = string.charAt(i)
            switch char
                when "\\"
                    if i == len - 1
                        throw { # we need the curly brackets here, because CoffeeScript will cause problems, otherwise
                            name: "NothingToEscapeException"
                            message: "There is nothing to escape. Most likely, the pattern ends in a backslash \"\\\""
                            index: i
                        }
                    actualChar = string.charAt(i+1)
                    @append(current, new Character(actualChar))
                    i += 2
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
                    group = new Group(new Alternation(new Sequence()))
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
        # Now traverse the token tree to remove unnecessary alternations and sequences
        traverse = (token) ->
            if token.subtokens.length > 0
                for i in [0..token.subtokens.length-1]
                    subtoken = token.subtokens[i]
                    while ((subtoken instanceof Alternation) or (subtoken instanceof Sequence)) and (subtoken.subtokens.length == 1)
                        token.subtokens[i] = subtoken.subtokens[0]
                        subtoken = token.subtokens[i]
                    traverse(subtoken)
    
        traverse(regex)
        return regex
        
    parseQuantifier: (current, char, i) ->
        st = current.subtokens
        if st[st.length-1].subtokens.length == 0
            throw {
                name: "NothingToRepeatException"
                message: "The is nothing to repeat for quantifier \"" + char + "\" at index " + i
                index: i
            }
        target = @remove(current)
        unless (target instanceof Group) or (target instanceof Character) or (target instanceof Wildcard)
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