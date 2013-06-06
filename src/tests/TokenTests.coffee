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
        assertSame(2, token.nextMatch(state))
        assertSame(false, token.nextMatch(state))
        assertSame(2, token.nextMatch(state))
        assertSame(false, token.nextMatch(state))
        state.currentPosition = 2 # advance to position before b
        assertSame(false, token.nextMatch(state))
        state.currentPosition = 3 # advance to end of string
        assertSame(false, token.nextMatch(state))
        assertSame(false, token.nextMatch(state))
        
        state.currentPosition = 1
        # Put together token for regex /b/
        token = new Character("b")
        assertSame(false, token.nextMatch(state))
        state.currentPosition = 2 # advance to position before b
        assertSame(3, token.nextMatch(state))
        assertSame(false, token.nextMatch(state))
        assertSame(3, token.nextMatch(state))
        assertSame(false, token.nextMatch(state))
        state.currentPosition = 3 # advance to end of string
        assertSame(false, token.nextMatch(state))
        assertSame(false, token.nextMatch(state))
    
    "testWildcardToken": () ->
        state = @RegexEngine.setupInitialState("a\nb\r")
        # Put together token for regex /./
        token = new Wildcard()
        assertSame(2, token.nextMatch(state))
        assertSame(false, token.nextMatch(state))
        assertSame(2, token.nextMatch(state))
        assertSame(false, token.nextMatch(state))
        state.currentPosition = 2 # advance to position before \n
        assertSame(false, token.nextMatch(state))
        state.currentPosition = 3 # advance to position before b
        assertSame(4, token.nextMatch(state))
        assertSame(false, token.nextMatch(state))
        assertSame(4, token.nextMatch(state))
        assertSame(false, token.nextMatch(state))
        state.currentPosition = 4 # advance to position before \r
        assertSame(false, token.nextMatch(state))
        state.currentPosition = 5 # advance to end of string
        assertSame(false, token.nextMatch(state))
        assertSame(false, token.nextMatch(state))
            
    "testStartAnchorToken": () ->
        state = @RegexEngine.setupInitialState("ab")
        # Put together token for regex /^/
        token = new StartAnchor()
        assertSame(1, token.nextMatch(state))
        assertSame(false, token.nextMatch(state))
        assertSame(1, token.nextMatch(state))
        assertSame(false, token.nextMatch(state))
        state.currentPosition = 2 # advance to position before b
        assertSame(false, token.nextMatch(state))
        state.currentPosition = 3 # advance to end of string
        assertSame(false, token.nextMatch(state))
        assertSame(false, token.nextMatch(state))
            
    "testEndAnchorToken": () ->
        state = @RegexEngine.setupInitialState("ab")
        # Put together token for regex /$/
        token = new EndAnchor()
        assertSame(false, token.nextMatch(state))
        state.currentPosition = 2 # advance to position before b
        assertSame(false, token.nextMatch(state))
        state.currentPosition = 3 # advance to end of string
        assertSame(3, token.nextMatch(state))
        assertSame(false, token.nextMatch(state))
        assertSame(3, token.nextMatch(state))
        assertSame(false, token.nextMatch(state))
        
    "testOptionToken": () ->
        state = @RegexEngine.setupInitialState("ab")
        # Put together token for regex /a?/
        token = new Option(new Character("a"))
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertSame(2, token.nextMatch(state)) # subtoken "a" matches
            assertSame(0, token.nextMatch(state)) # subtoken "a" cannot backtrack, so subtoken fails 
            assertSame(1, token.nextMatch(state)) # omitting the subtoken matches
            assertSame(false, token.nextMatch(state)) # no more variants to backtrack
        state.currentPosition = 2 # advance to position before b
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertSame(0, token.nextMatch(state)) # subtoken "a" fails
            assertSame(2, token.nextMatch(state)) # omitting the subtoken matches
            assertSame(false, token.nextMatch(state))
        state.currentPosition = 3 # advance to end of string
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertSame(0, token.nextMatch(state)) # subtoken "a" fails
            assertSame(3, token.nextMatch(state)) # omitting the subtoken matches
            assertSame(false, token.nextMatch(state))
            
    "testRepeatZeroOrMoreToken": () ->
        state = @RegexEngine.setupInitialState("aaab")
        # Put together token for regex /a*/
        token = new RepeatZeroOrMore(new Character("a"))
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertSame(0, token.nextMatch(state)) # first three instances of subtoken "a" match, but fourth instance of subtoken "a" fails
            assertSame(4, token.nextMatch(state)) # fourth instance is discarded to give a match
            assertSame(0, token.nextMatch(state)) # third instance of subtoken "a" cannot backtrack, so subtoken fails 
            assertSame(3, token.nextMatch(state)) # third instance is discarded to give another match
            assertSame(0, token.nextMatch(state)) # second instance of subtoken "a" cannot backtrack, so subtoken fails 
            assertSame(2, token.nextMatch(state)) # second instance is discarded to give another match
            assertSame(0, token.nextMatch(state)) # first instance of subtoken "a" cannot backtrack, so subtoken fails 
            assertSame(1, token.nextMatch(state)) # first instance is discarded to give another match
            assertSame(false, token.nextMatch(state)) # no more variants to backtrack
        state.currentPosition = 4 # advance to position before b
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertSame(0, token.nextMatch(state)) # first instance of subtoken "a" fails
            assertSame(4, token.nextMatch(state)) # first instance is discarded to give a match
            assertSame(false, token.nextMatch(state))
        
        
        # Put together token for regex /(a|b)*/ omitting the Group token as it only forwards nextMatch() calls
        state = @RegexEngine.setupInitialState("ab")
        alternation = new Alternation()
        alternation.subtokens.push(new Character("a"))
        alternation.subtokens.push(new Character("b"))
        token = new RepeatZeroOrMore(alternation)
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertSame(0, token.nextMatch(state)) # first instance of subtoken "a|b" matches (with "a"), but second instance fails when trying "a" 
            assertSame(0, token.nextMatch(state)) # second instances of "a|b" backtracks and "b" matches, but third instance fails when trying "a"
            assertSame(0, token.nextMatch(state)) # third instance fails again when trying "b"
            assertSame(0, token.nextMatch(state)) # alternation in third instance reports overall failure
            assertSame(3, token.nextMatch(state)) # third instance is discarded to give a match
            assertSame(0, token.nextMatch(state)) # subtoken "b" of second instance of "a|b" cannot backtrack, so sub(sub)token fails 
            assertSame(0, token.nextMatch(state)) # alternation in second instance reports overall failure
            assertSame(2, token.nextMatch(state)) # second instance is discarded to give another match
            assertSame(0, token.nextMatch(state)) # subtoken "a" of first instance of "a|b" cannot backtrack, so sub(sub)token fails 
            assertSame(0, token.nextMatch(state)) # first instance fails again when trying "b"
            assertSame(0, token.nextMatch(state)) # alternation in first instance reports overall failure
            assertSame(1, token.nextMatch(state)) # first instance is discarded to give another match
            assertSame(false, token.nextMatch(state)) # no more variants to backtrack
            
    "testRepeatOneOrMoreToken": () ->
        state = @RegexEngine.setupInitialState("aaab")
        # Put together token for regex /a+/
        token = new RepeatOneOrMore(new Character("a"))
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertSame(0, token.nextMatch(state)) # first three instances of subtoken "a" match, but fourth instance of subtoken "a" fails
            assertSame(4, token.nextMatch(state)) # fourth instance is discarded to give a match
            assertSame(0, token.nextMatch(state)) # third instance of subtoken "a" cannot backtrack, so subtoken fails 
            assertSame(3, token.nextMatch(state)) # third instance is discarded to give another match
            assertSame(0, token.nextMatch(state)) # second instance of subtoken "a" cannot backtrack, so subtoken fails 
            assertSame(2, token.nextMatch(state)) # second instance is discarded to give another match
            assertSame(0, token.nextMatch(state)) # first instance of subtoken "a" cannot backtrack, so subtoken fails 
            assertSame(0, token.nextMatch(state)) # first instance is discarded, but we need at least 1 repetition
            assertSame(false, token.nextMatch(state)) # no more variants to backtrack
        state.currentPosition = 4 # advance to position before b
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertSame(0, token.nextMatch(state)) # first instance of subtoken "a" fails
            assertSame(0, token.nextMatch(state)) # first instance is discarded, but we need at least 1 repetition
            assertSame(false, token.nextMatch(state))
        
        
        # Put together token for regex /(a|b)+/ omitting the Group token as it only forwards nextMatch() calls
        state = @RegexEngine.setupInitialState("ab")
        alternation = new Alternation()
        alternation.subtokens.push(new Character("a"))
        alternation.subtokens.push(new Character("b"))
        token = new RepeatOneOrMore(alternation)
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertSame(0, token.nextMatch(state)) # first instance of subtoken "a|b" matches (with "a"), but second instance fails when trying "a" 
            assertSame(0, token.nextMatch(state)) # second instances of "a|b" backtracks and "b" matches, but third instance fails when trying "a"
            assertSame(0, token.nextMatch(state)) # third instance fails again when trying "b"
            assertSame(0, token.nextMatch(state)) # alternation in third instance reports overall failure
            assertSame(3, token.nextMatch(state)) # third instance is discarded to give a match
            assertSame(0, token.nextMatch(state)) # subtoken "b" of second instance of "a|b" cannot backtrack, so sub(sub)token fails 
            assertSame(0, token.nextMatch(state)) # alternation in second instance reports overall failure
            assertSame(2, token.nextMatch(state)) # second instance is discarded to give another match
            assertSame(0, token.nextMatch(state)) # subtoken "a" of first instance of "a|b" cannot backtrack, so sub(sub)token fails 
            assertSame(0, token.nextMatch(state)) # first instance fails again when trying "b"
            assertSame(0, token.nextMatch(state)) # alternation in first instance reports overall failure
            assertSame(0, token.nextMatch(state)) # first instance is discarded, but we need at least one repetition
            assertSame(false, token.nextMatch(state)) # no more variants to backtrack
            
    "testInfiniteLoop": () ->
        state = @RegexEngine.setupInitialState("b")
        # Put together token for regex /(a*)*/ omitting the Group token as it only forwards nextMatch() calls
        token = new RepeatZeroOrMore(new RepeatZeroOrMore(new Character("a")))
        #debugger
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertSame(0, token.nextMatch(state)) # first instance of subtoken "a*" fails when trying first instance of "a"
            assertSame(0, token.nextMatch(state)) # first instance of subtoken "a*" matches after discarding first instance of "a", but empty submatches are disregarded, so subtoken fails
            assertSame(1, token.nextMatch(state)) # first instance is discarded to give a match
            assertSame(false, token.nextMatch(state)) # no more variants to backtrack
            
        # Put together token for regex /(a?)+/ omitting the Group token as it only forwards nextMatch() calls
        token = new RepeatOneOrMore(new Option(new Character("a")))
        #debugger
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertSame(0, token.nextMatch(state)) # first instance of subtoken "a?" fails when trying "a"
            assertSame(0, token.nextMatch(state)) # first instance of subtoken "a?" matches empty, but second instance fails when trying "a"
            assertSame(0, token.nextMatch(state)) # first instance of subtoken "a?" matches empty, second instances matches empty, but more than one empty submatch is disregarded, so subtoken fails
            assertSame(1, token.nextMatch(state)) # second instance is discarded to give a match
            assertSame(0, token.nextMatch(state)) # first instance of subtoken "a?" cannot backtrack, so fails
            assertSame(0, token.nextMatch(state)) # first instance is discarded, but we need at least one repetition
            assertSame(false, token.nextMatch(state)) # no more variants to backtrack
            
        
    "testAlternationToken": () ->
        state = @RegexEngine.setupInitialState("abc")
        # Put together token for regex /a|b|c/
        token = new Alternation()
        token.subtokens.push(new Character("a"))
        token.subtokens.push(new Character("b"))
        token.subtokens.push(new Character("c"))
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertSame(2, token.nextMatch(state)) # subtoken "a" matches
            assertSame(0, token.nextMatch(state)) # subtoken "a" cannot backtrack, so subtoken fails
            assertSame(0, token.nextMatch(state)) # subtoken "b" fails
            assertSame(0, token.nextMatch(state)) # subtoken "c" fails
            assertSame(false, token.nextMatch(state)) # no more variations to backtrack
        state.currentPosition = 2 # advance to position before b
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertSame(0, token.nextMatch(state))
            assertSame(3, token.nextMatch(state))
            assertSame(0, token.nextMatch(state))
            assertSame(0, token.nextMatch(state))
            assertSame(false, token.nextMatch(state))
        state.currentPosition = 3 # advance to position before c
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertSame(0, token.nextMatch(state))
            assertSame(0, token.nextMatch(state))
            assertSame(4, token.nextMatch(state))
            assertSame(0, token.nextMatch(state))
            assertSame(false, token.nextMatch(state))
        state.currentPosition = 4 # advance to end of string
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertSame(0, token.nextMatch(state))
            assertSame(0, token.nextMatch(state))
            assertSame(0, token.nextMatch(state))
            assertSame(false, token.nextMatch(state))
        
    "testSequenceToken": () ->
        state = @RegexEngine.setupInitialState("abc")
        # Put together token for regex /abc/
        token = new Sequence()
        token.subtokens.push(new Character("a"))
        token.subtokens.push(new Character("b"))
        token.subtokens.push(new Character("c"))
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertSame(4, token.nextMatch(state)) # all subtokens match on first attempt
            assertSame(3, state.currentPosition)
            assertSame(0, token.nextMatch(state)) # subtoken "c" cannot backtrack, so subtoken fails
            assertSame(2, state.currentPosition)
            assertSame(0, token.nextMatch(state)) # subtoken "b" cannot backtrack, so subtoken fails
            assertSame(1, state.currentPosition)
            assertSame(0, token.nextMatch(state)) # subtoken "a" cannot backtrack, so subtoken fails
            assertSame(1, state.currentPosition)
            assertSame(false, token.nextMatch(state)) # no more variations to backtrack
        
        # Put together token for regex /ab?b/
        token = new Sequence()
        token.subtokens.push(new Character("a"))
        token.subtokens.push(new Option(new Character("b")))
        token.subtokens.push(new Character("b"))
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertSame(0, token.nextMatch(state)) # subtokens "a" and "b?" match, but "b" fails
            assertSame(2, state.currentPosition)
            assertSame(0, token.nextMatch(state)) # the subtoken "b" inside "b?" cannot backtrack, so that fails
            assertSame(2, state.currentPosition)
            assertSame(3, token.nextMatch(state)) # all subtokens match ("b?" matches by omitting its subtoken)
            assertSame(2, state.currentPosition)
            assertSame(0, token.nextMatch(state)) # subtoken "b" cannot backtrack, so subtoken fails
            assertSame(2, state.currentPosition)
            assertSame(0, token.nextMatch(state)) # subtoken "b?" cannot backtrack, so subtoken fails
            assertSame(1, state.currentPosition)
            assertSame(0, token.nextMatch(state)) # subtoken "a" cannot backtrack, so subtoken fails
            assertSame(1, state.currentPosition)
            assertSame(false, token.nextMatch(state)) # no more variations to backtrack
    
    "testEmptySequenceToken": () ->
        state = @RegexEngine.setupInitialState("")
        # Put together token for regex //
        token = new Sequence()
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertSame(1, token.nextMatch(state)) # token matches but does not advance the cursor
            assertSame(false, token.nextMatch(state)) # no more variations to backtrack

        state = @RegexEngine.setupInitialState("a")
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertSame(1, token.nextMatch(state)) # token matches but does not advance the cursor
            assertSame(false, token.nextMatch(state)) # no more variations to backtrack
        state.currentPosition = 2
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertSame(2, token.nextMatch(state)) # token matches but does not advance the cursor
            assertSame(false, token.nextMatch(state)) # no more variations to backtrack
)