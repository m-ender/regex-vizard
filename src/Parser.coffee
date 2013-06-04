root = global ? window

class root.Parser
    constructor: () ->
    
    parse: (string) ->
        # In order not to set up alternations after the first alternative has been read, we treat everything as an
        # alternation of sequences (possibly with only one alternative or only one token in the sequence).
        # Unnecessary alternations and sequences will be removed in the end.
        regex = new RootToken()
        nestingStack = []
        current = new Alternation(new Sequence())
        regex.subtokens.push(current)
        i = 0
        len = string.length
        
        append = (token) ->
            st = current.subtokens
            st[st.length-1].subtokens.push(token)
        remove = () ->
            st = current.subtokens
            return st[st.length-1].subtokens.pop()
            
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
                    actualChar = patternString.charAt(i+1)
                    append(new Character(actualChar))
                    i += 2
                when "^"
                    append(new StartAnchor())
                    ++i
                when "$"
                    append(new EndAnchor())
                    ++i
                when "."
                    append(new Wildcard())
                    ++i
                when "|"
                    current.subtokens.push(new Sequence())
                    ++i
                when "("
                    group = new Group(new Alternation(new Sequence()))
                    append(group)
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
                when "?"
                    st = current.subtokens
                    st[st.length-1]
                    if st[st.length-1].subtokens.length == 0
                        throw {
                            name: "NothingToRepeatException"
                            message: "The is nothing to repeat for quantifier \"" + char + "\" at index " + i
                            index: i
                        }
                    append(new Option(remove())) # take the currently last token, stuff it into an Option token and append the option instead
                    ++i
                else
                    append(new Character(char))
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