root = global ? window

class root.Regex
    constructor: (regexString, report = false) ->
        console.log("Regex string:", regexString) if report
        [@regex, @nGroups] = Parser.parsePattern(regexString)
        console.log("Regex pattern:", @regex) if report

    test: (inputString) ->
        matcher = @getMatcher(inputString)

        continue while matcher.stepForward()

        return matcher.success

    match: (inputString) ->
        matcher = @getMatcher(inputString)

        continue while matcher.stepForward()

        if matcher.success
            return matcher.groups()
        else
            return null

    getMatcher: (inputString) ->
        return new Matcher(@regex, @nGroups, inputString)

    # Build character array and surround it with special objects as guards for the
    # start and end of the input string
    parseInput: (inputString) ->
        input = [StartGuard].concat(inputString.split(""))
        input.push(EndGuard)
        return input

    setupInitialState: (str, maxGroup = 0) ->
        state =
            inputString: str
            input: @parseInput(str)
            startingPosition: 1
            currentPosition: 1
            captures: []
            report: () ->
                console.log("Current match: " + @inputString[@startingPosition-1...@currentPosition-1])

        for i in [0..maxGroup]
            state.captures[i] = undefined

        return state