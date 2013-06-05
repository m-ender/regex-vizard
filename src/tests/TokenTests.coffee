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
        assertEquals(2, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
        assertEquals(2, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
        state.currentPosition = 2 # advance to position before b
        assertEquals(false, token.nextMatch(state))
        state.currentPosition = 3 # advance to end of string
        assertEquals(false, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
        
        state.currentPosition = 1
        # Put together token for regex /b/
        token = new Character("b")
        assertEquals(false, token.nextMatch(state))
        state.currentPosition = 2 # advance to position before b
        assertEquals(3, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
        assertEquals(3, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
        state.currentPosition = 3 # advance to end of string
        assertEquals(false, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
    
    "testWildcardToken": () ->
        state = @RegexEngine.setupInitialState("a\nb\r")
        # Put together token for regex /./
        token = new Wildcard()
        assertEquals(2, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
        assertEquals(2, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
        state.currentPosition = 2 # advance to position before \n
        assertEquals(false, token.nextMatch(state))
        state.currentPosition = 3 # advance to position before b
        assertEquals(4, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
        assertEquals(4, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
        state.currentPosition = 4 # advance to position before \r
        assertEquals(false, token.nextMatch(state))
        state.currentPosition = 5 # advance to end of string
        assertEquals(false, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
            
    "testStartAnchorToken": () ->
        state = @RegexEngine.setupInitialState("ab")
        # Put together token for regex /^/
        token = new StartAnchor()
        assertEquals(1, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
        assertEquals(1, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
        state.currentPosition = 2 # advance to position before b
        assertEquals(false, token.nextMatch(state))
        state.currentPosition = 3 # advance to end of string
        assertEquals(false, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
            
    "testEndAnchorToken": () ->
        state = @RegexEngine.setupInitialState("ab")
        # Put together token for regex /$/
        token = new EndAnchor()
        assertEquals(false, token.nextMatch(state))
        state.currentPosition = 2 # advance to position before b
        assertEquals(false, token.nextMatch(state))
        state.currentPosition = 3 # advance to end of string
        assertEquals(3, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
        assertEquals(3, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
        
    "testOptionToken": () ->
        state = @RegexEngine.setupInitialState("ab")
        # Put together token for regex /a?/
        token = new Option(new Character("a"))
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertEquals(2, token.nextMatch(state)) # subtoken "a" matches
            assertEquals(0, token.nextMatch(state)) # subtoken "a" cannot backtrack, so subtoken fails 
            assertEquals(1, token.nextMatch(state)) # omitting the subtoken matches
            assertEquals(false, token.nextMatch(state)) # no more variants to backtrack
        state.currentPosition = 2 # advance to position before b
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertEquals(0, token.nextMatch(state)) # subtoken "a" fails
            assertEquals(2, token.nextMatch(state)) # omitting the subtoken matches
            assertEquals(false, token.nextMatch(state))
        state.currentPosition = 3 # advance to end of string
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertEquals(0, token.nextMatch(state)) # subtoken "a" fails
            assertEquals(3, token.nextMatch(state)) # omitting the subtoken matches
            assertEquals(false, token.nextMatch(state))
        
    "testAlternationToken": () ->
        state = @RegexEngine.setupInitialState("abc")
        # Put together token for regex /a|b|c/
        token = new Alternation()
        token.subtokens.push(new Character("a"))
        token.subtokens.push(new Character("b"))
        token.subtokens.push(new Character("c"))
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertEquals(2, token.nextMatch(state)) # subtoken "a" matches
            assertEquals(0, token.nextMatch(state)) # subtoken "a" cannot backtrack, so subtoken fails
            assertEquals(0, token.nextMatch(state)) # subtoken "b" fails
            assertEquals(0, token.nextMatch(state)) # subtoken "c" fails
            assertEquals(false, token.nextMatch(state)) # no more variations to backtrack
        state.currentPosition = 2 # advance to position before b
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertEquals(0, token.nextMatch(state))
            assertEquals(3, token.nextMatch(state))
            assertEquals(0, token.nextMatch(state))
            assertEquals(0, token.nextMatch(state))
            assertEquals(false, token.nextMatch(state))
        state.currentPosition = 3 # advance to position before c
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertEquals(0, token.nextMatch(state))
            assertEquals(0, token.nextMatch(state))
            assertEquals(4, token.nextMatch(state))
            assertEquals(0, token.nextMatch(state))
            assertEquals(false, token.nextMatch(state))
        state.currentPosition = 4 # advance to end of string
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertEquals(0, token.nextMatch(state))
            assertEquals(0, token.nextMatch(state))
            assertEquals(0, token.nextMatch(state))
            assertEquals(false, token.nextMatch(state))
        
    "testSequenceToken": () ->
        state = @RegexEngine.setupInitialState("abc")
        # Put together token for regex /abc/
        token = new Sequence()
        token.subtokens.push(new Character("a"))
        token.subtokens.push(new Character("b"))
        token.subtokens.push(new Character("c"))
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertEquals(4, token.nextMatch(state)) # all subtokens match on first attempt
            assertEquals(3, state.currentPosition)
            assertEquals(0, token.nextMatch(state)) # subtoken "c" cannot backtrack, so subtoken fails
            assertEquals(2, state.currentPosition)
            assertEquals(0, token.nextMatch(state)) # subtoken "b" cannot backtrack, so subtoken fails
            assertEquals(1, state.currentPosition)
            assertEquals(0, token.nextMatch(state)) # subtoken "a" cannot backtrack, so subtoken fails
            assertEquals(1, state.currentPosition)
            assertEquals(false, token.nextMatch(state)) # no more variations to backtrack
        
        # Put together token for regex /ab?b/
        token = new Sequence()
        token.subtokens.push(new Character("a"))
        token.subtokens.push(new Option(new Character("b")))
        token.subtokens.push(new Character("b"))
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertEquals(0, token.nextMatch(state)) # subtokens "a" and "b?" match, but "b" fails
            assertEquals(2, state.currentPosition)
            assertEquals(0, token.nextMatch(state)) # the subtoken "b" inside "b?" cannot backtrack, so that fails
            assertEquals(2, state.currentPosition)
            assertEquals(3, token.nextMatch(state)) # all subtokens match ("b?" matches by omitting its subtoken)
            assertEquals(2, state.currentPosition)
            assertEquals(0, token.nextMatch(state)) # subtoken "b" cannot backtrack, so subtoken fails
            assertEquals(2, state.currentPosition)
            assertEquals(0, token.nextMatch(state)) # subtoken "b?" cannot backtrack, so subtoken fails
            assertEquals(1, state.currentPosition)
            assertEquals(0, token.nextMatch(state)) # subtoken "a" cannot backtrack, so subtoken fails
            assertEquals(1, state.currentPosition)
            assertEquals(false, token.nextMatch(state)) # no more variations to backtrack
    
    "testEmptySequenceToken": () ->
        state = @RegexEngine.setupInitialState("")
        # Put together token for regex //
        token = new Sequence()
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertEquals(1, token.nextMatch(state)) # token matches but does not advance the cursor
            assertEquals(false, token.nextMatch(state)) # no more variations to backtrack

        state = @RegexEngine.setupInitialState("a")
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertEquals(1, token.nextMatch(state)) # token matches but does not advance the cursor
            assertEquals(false, token.nextMatch(state)) # no more variations to backtrack
        state.currentPosition = 2
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            assertEquals(2, token.nextMatch(state)) # token matches but does not advance the cursor
            assertEquals(false, token.nextMatch(state)) # no more variations to backtrack
)