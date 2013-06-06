root = global ? window

class root.RegexEngine
    constructor: () ->      

    match: (regexString, inputString, report = false) ->
        console.log("Regex string:", regexString) if report
        regex = @parsePattern(regexString)
        console.log("Regex pattern:", regex) if report
        
        # Build character array and surround it with -1 and 1 as guards for the
        # start and end of the input string
        console.log("Input string:", inputString) if report
        state = @setupInitialState(inputString)        
        console.log("Input:", state.input) if report

        while state.startingPosition < state.input.length
            result = regex.nextMatch(state, report)
            while result == 0
                result = regex.nextMatch(state, report)
            if result == false
                state.currentPosition = ++state.startingPosition
            else
                break
        
        return state.startingPosition < state.input.length
        
    parsePattern: (string) ->
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
                    actualChar = string.charAt(i+1)
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
                    if st[st.length-1].subtokens.length == 0
                        throw {
                            name: "NothingToRepeatException"
                            message: "The is nothing to repeat for quantifier \"" + char + "\" at index " + i
                            index: i
                        }
                    target = remove()
                    unless (target instanceof Group) or (target instanceof Character) or (target instanceof Wildcard)
                        throw {
                            name: "NothingToRepeatException"
                            message: "The is nothing to repeat for quantifier \"" + char + "\" at index " + i + ". Only groups, characters and wildcard may be quantified."
                            index: i
                        }
                    append(new Option(target)) # take the currently last token, stuff it into an Option token and append the option instead
                    ++i
                when "*"
                    st = current.subtokens
                    if st[st.length-1].subtokens.length == 0
                        throw {
                            name: "NothingToRepeatException"
                            message: "The is nothing to repeat for quantifier \"" + char + "\" at index " + i
                            index: i
                        }
                    target = remove()
                    unless (target instanceof Group) or (target instanceof Character) or (target instanceof Wildcard)
                        throw {
                            name: "NothingToRepeatException"
                            message: "The is nothing to repeat for quantifier \"" + char + "\" at index " + i + ". Only groups, characters and wildcard may be quantified."
                            index: i
                        }
                    append(new RepeatZeroOrMore(target)) # take the currently last token, stuff it into an RepeatZeroOrMore token and append the option instead
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
        
    parseInput: (inputString) ->
        input = [-1].concat(inputString.split(""))
        input.push(1)
        return input
        
    setupInitialState: (str) ->
        return {
            inputString: str
            input: @parseInput(str)
            startingPosition: 1
            currentPosition: 1
            report: () ->
                console.log("Current match: " + @inputString[@startingPosition-1...@currentPosition-1])
        }