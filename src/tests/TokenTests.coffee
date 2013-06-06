TestCase("TokenTests",
    setUp : () ->
        if typeof module != "undefined" && module.exports
            #On a server
            @RegexEngine = new require("RegexEngine").RegexEngine
        else
            #On a client
            @RegexEngine = new window.RegexEngine
            
    "testCharacterToken": () ->
        state = @RegexEngine.setupInitialState("ab")
        # Put together token for regex /a/
        token = new Character("a")
        @assertNextMatchSequence(token, state, [
            2
        ])
        state.currentPosition = 2 # advance to position before b
        @assertNextMatchSequence(token, state, [])
        state.currentPosition = 3 # advance to end of string
        @assertNextMatchSequence(token, state, [])
        
        state.currentPosition = 1
        # Put together token for regex /b/
        token = new Character("b")
        @assertNextMatchSequence(token, state, [])
        state.currentPosition = 2 # advance to position before b
        @assertNextMatchSequence(token, state, [
            3
        ])
        state.currentPosition = 3 # advance to end of string
        @assertNextMatchSequence(token, state, [])
    
    "testWildcardToken": () ->
        state = @RegexEngine.setupInitialState("a\nb\r")
        # Put together token for regex /./
        token = new Wildcard()
        @assertNextMatchSequence(token, state, [
            2
        ])
        state.currentPosition = 2 # advance to position before \n
        @assertNextMatchSequence(token, state, [])
        state.currentPosition = 3 # advance to position before b
        @assertNextMatchSequence(token, state, [
            4
        ])
        state.currentPosition = 4 # advance to position before \r
        @assertNextMatchSequence(token, state, [])
        state.currentPosition = 5 # advance to end of string
        @assertNextMatchSequence(token, state, [])
            
    "testStartAnchorToken": () ->
        state = @RegexEngine.setupInitialState("ab")
        # Put together token for regex /^/
        token = new StartAnchor()
        @assertNextMatchSequence(token, state, [
            1
        ])
        state.currentPosition = 2 # advance to position before b
        @assertNextMatchSequence(token, state, [])
        state.currentPosition = 3 # advance to end of string
        @assertNextMatchSequence(token, state, [])
            
    "testEndAnchorToken": () ->
        state = @RegexEngine.setupInitialState("ab")
        # Put together token for regex /$/
        token = new EndAnchor()
        @assertNextMatchSequence(token, state, [])
        state.currentPosition = 2 # advance to position before b
        @assertNextMatchSequence(token, state, [])
        state.currentPosition = 3 # advance to end of string
        @assertNextMatchSequence(token, state, [
            3
        ])
        
    "testAlternationToken": () ->
        state = @RegexEngine.setupInitialState("abc")
        # Put together token for regex /a|b|c/
        token = new Alternation()
        token.subtokens.push(new Character("a"))
        token.subtokens.push(new Character("b"))
        token.subtokens.push(new Character("c"))
        @assertNextMatchSequence(token, state, [
            2 # subtoken "a" matches
            0 # subtoken "a" cannot backtrack, so subtoken fails
            0 # subtoken "b" fails
            0 # subtoken "c" fails
        ])
        state.currentPosition = 2 # advance to position before b
        @assertNextMatchSequence(token, state, [
            0
            3
            0
            0
        ])
        state.currentPosition = 3 # advance to position before c
        @assertNextMatchSequence(token, state, [
            0
            0
            4
            0
        ])
        state.currentPosition = 4 # advance to end of string
        @assertNextMatchSequence(token, state, [
            0
            0
            0
        ])
        
    "testSequenceToken": () ->
        state = @RegexEngine.setupInitialState("abc")
        # Put together token for regex /abc/
        token = new Sequence()
        token.subtokens.push(new Character("a"))
        token.subtokens.push(new Character("b"))
        token.subtokens.push(new Character("c"))
        @assertNextMatchSequence(token, state, [
            4 # all subtokens match on first attempt
            0 # subtoken "c" cannot backtrack, so subtoken fails
            0 # subtoken "b" cannot backtrack, so subtoken fails
            0 # subtoken "a" cannot backtrack, so subtoken fails
        ])
        
        # Put together token for regex /ab?b/
        token = new Sequence()
        token.subtokens.push(new Character("a"))
        token.subtokens.push(new Option(new Character("b")))
        token.subtokens.push(new Character("b"))
        @assertNextMatchSequence(token, state, [
            0 # subtokens "a" and "b?" match, but "b" fails
            0 # the subtoken "b" inside "b?" cannot backtrack, so that fails
            3 # all subtokens match ("b?" matches by omitting its subtoken)
            0 # subtoken "b" cannot backtrack, so subtoken fails 
            0 # subtoken "b?" cannot backtrack, so subtoken fails
            0 # subtoken "a" cannot backtrack, so subtoken fails  
        ])
    
    "testEmptySequenceToken": () ->
        state = @RegexEngine.setupInitialState("")
        # Put together token for regex //
        token = new Sequence()
        @assertNextMatchSequence(token, state, [
            1 # token matches but does not advance the cursor
        ])
        state = @RegexEngine.setupInitialState("a")
        @assertNextMatchSequence(token, state, [
            1 # token matches but does not advance the cursor
        ])
        state.currentPosition = 2
        @assertNextMatchSequence(token, state, [
            2 # token matches but does not advance the cursor
        ])
        
    "testOptionToken": () ->
        state = @RegexEngine.setupInitialState("ab")
        # Put together token for regex /a?/
        token = new Option(new Character("a"))
        @assertNextMatchSequence(token, state, [
            2 # subtoken "a" matches
            0 # subtoken "a" cannot backtrack, so subtoken fails 
            1 # omitting the subtoken matches
        ])
        state.currentPosition = 2 # advance to position before b
        @assertNextMatchSequence(token, state, [
            0 # subtoken "a" fails
            2 # omitting the subtoken matches
        ])
        state.currentPosition = 3 # advance to end of string
        @assertNextMatchSequence(token, state, [
            0 # subtoken "a" fails
            3 # omitting the subtoken matches
        ])
            
    "testRepeatZeroOrMoreToken": () ->
        state = @RegexEngine.setupInitialState("aaab")
        # Put together token for regex /a*/
        token = new RepeatZeroOrMore(new Character("a"))
        @assertNextMatchSequence(token, state, [
            0 # first three instances of subtoken "a" match, but fourth instance of subtoken "a" fails
            4 # fourth instance is discarded to give a match
            0 # third instance of subtoken "a" cannot backtrack, so subtoken fails 
            3 # third instance is discarded to give another match
            0 # second instance of subtoken "a" cannot backtrack, so subtoken fails 
            2 # second instance is discarded to give another match
            0 # first instance of subtoken "a" cannot backtrack, so subtoken fails 
            1 # first instance is discarded to give another match
        ])
        state.currentPosition = 4 # advance to position before b
        @assertNextMatchSequence(token, state, [
            0 # first instance of subtoken "a" fails # subtoken "a" fails
            4 # first instance is discarded to give a match # omitting the subtoken matches
        ])        
        
        # Put together token for regex /(a|b)*/ omitting the Group token as it only forwards nextMatch() calls
        state = @RegexEngine.setupInitialState("ab")
        alternation = new Alternation()
        alternation.subtokens.push(new Character("a"))
        alternation.subtokens.push(new Character("b"))
        token = new RepeatZeroOrMore(alternation)
        @assertNextMatchSequence(token, state, [
            0 # first instance of subtoken "a|b" matches (with "a"), but second instance fails when trying "a" 
            0 # second instances of "a|b" backtracks and "b" matches, but third instance fails when trying "a"
            0 # third instance fails again when trying "b"
            0 # alternation in third instance reports overall failure
            3 # third instance is discarded to give a match
            0 # subtoken "b" of second instance of "a|b" cannot backtrack, so sub(sub)token fails 
            0 # alternation in second instance reports overall failure
            2 # second instance is discarded to give another match
            0 # subtoken "a" of first instance of "a|b" cannot backtrack, so sub(sub)token fails 
            0 # first instance fails again when trying "b"
            0 # alternation in first instance reports overall failure
            1 # first instance is discarded to give another match
        ])
            
    "testRepeatOneOrMoreToken": () ->
        state = @RegexEngine.setupInitialState("aaab")
        # Put together token for regex /a+/
        token = new RepeatOneOrMore(new Character("a"))
        @assertNextMatchSequence(token, state, [
            0 # first three instances of subtoken "a" match, but fourth instance of subtoken "a" fails
            4 # fourth instance is discarded to give a match
            0 # third instance of subtoken "a" cannot backtrack, so subtoken fails 
            3 # third instance is discarded to give another match
            0 # second instance of subtoken "a" cannot backtrack, so subtoken fails 
            2 # second instance is discarded to give another match
            0 # first instance of subtoken "a" cannot backtrack, so subtoken fails 
            0 # first instance is discarded, but we need at least 1 repetition
        ])
        state.currentPosition = 4 # advance to position before b
        @assertNextMatchSequence(token, state, [
            0 # first instance of subtoken "a" fails
            0 # first instance is discarded, but we need at least 1 repetition
        ])
        
        
        # Put together token for regex /(a|b)+/ omitting the Group token as it only forwards nextMatch() calls
        state = @RegexEngine.setupInitialState("ab")
        alternation = new Alternation()
        alternation.subtokens.push(new Character("a"))
        alternation.subtokens.push(new Character("b"))
        token = new RepeatOneOrMore(alternation)
        @assertNextMatchSequence(token, state, [
            0 # first instance of subtoken "a|b" matches (with "a"), but second instance fails when trying "a" 
            0 # second instances of "a|b" backtracks and "b" matches, but third instance fails when trying "a"
            0 # third instance fails again when trying "b"
            0 # alternation in third instance reports overall failure
            3 # third instance is discarded to give a match
            0 # subtoken "b" of second instance of "a|b" cannot backtrack, so sub(sub)token fails 
            0 # alternation in second instance reports overall failure
            2 # second instance is discarded to give another match
            0 # subtoken "a" of first instance of "a|b" cannot backtrack, so sub(sub)token fails 
            0 # first instance fails again when trying "b"
            0 # alternation in first instance reports overall failure
            0 # first instance is discarded, but we need at least one repetition
        ])
            
    "testInfiniteLoop": () ->
        state = @RegexEngine.setupInitialState("b")
        # Put together token for regex /(a*)*/ omitting the Group token as it only forwards nextMatch() calls
        token = new RepeatZeroOrMore(new RepeatZeroOrMore(new Character("a")))
        @assertNextMatchSequence(token, state, [
            0 # first instance of subtoken "a*" fails when trying first instance of "a"
            0 # first instance of subtoken "a*" matches after discarding first instance of "a", but empty submatches are disregarded, so subtoken fails
            1 # first instance is discarded to give a match
        ])
            
        # Put together token for regex /(a?)+/ omitting the Group token as it only forwards nextMatch() calls
        token = new RepeatOneOrMore(new Option(new Character("a")))
        @assertNextMatchSequence(token, state, [
            0 # first instance of subtoken "a?" fails when trying "a"
            0 # first instance of subtoken "a?" matches empty, but second instance fails when trying "a"
            0 # first instance of subtoken "a?" matches empty, second instances matches empty, but more than one empty submatch is disregarded, so subtoken fails
            1 # second instance is discarded to give a match
            0 # first instance of subtoken "a?" cannot backtrack, so fails
            0 # first instance is discarded, but we need at least one repetition
        ])

    # This function assumes that the sequence does not contain the ultimate "false"
    assertNextMatchSequence: (token, state, sequence) ->
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            for expectedResult in sequence
                assertSame(expectedResult, token.nextMatch(state))
            assertSame(false, token.nextMatch(state))
)