TestCase("TokenTests",
    setUp : () ->
        if typeof module != "undefined" && module.exports
            #On a server
            @Regex = new require("Regex").Regex("")
        else
            #On a client
            @Regex = new window.Regex("")
            
    "testCharacterToken": () ->
        state = @Regex.setupInitialState("ab")
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
        state = @Regex.setupInitialState("a\nb\r")
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
        state = @Regex.setupInitialState("ab")
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
        state = @Regex.setupInitialState("ab")
        # Put together token for regex /$/
        token = new EndAnchor()
        @assertNextMatchSequence(token, state, [])
        state.currentPosition = 2 # advance to position before b
        @assertNextMatchSequence(token, state, [])
        state.currentPosition = 3 # advance to end of string
        @assertNextMatchSequence(token, state, [
            3
        ])
        
    "testDisjunctionToken": () ->
        state = @Regex.setupInitialState("abc")
        # Put together token for regex /a|b|c/
        token = new Disjunction()
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
        state = @Regex.setupInitialState("abc")
        # Put together token for regex /abc/
        token = new Sequence()
        token.subtokens.push(new Character("a"))
        token.subtokens.push(new Character("b"))
        token.subtokens.push(new Character("c"))
        @assertNextMatchSequence(token, state, [
           -1 # subtoken "a" matches
           -1 # subtoken "b" matches
            4 # last subtoken "c" matches, so report overall match
            0 # subtoken "c" cannot backtrack, so subtoken fail
            0 # subtoken "b" cannot backtrack, so subtoken fails
            0 # subtoken "a" cannot backtrack, so subtoken fails
        ])
        
        # Put together token for regex /ab?b/
        token = new Sequence()
        token.subtokens.push(new Character("a"))
        token.subtokens.push(new Option(new Character("b")))
        token.subtokens.push(new Character("b"))
        @assertNextMatchSequence(token, state, [
           -1 # subtoken "a" matches
           -1 # subsubtoken "b" matches
           -1 # therefore, subtoken "b?" matches
            0 # subtoken "b" fails
            0 # the subtoken "b" inside "b?" cannot backtrack, so that fails
           -1 # subtoken "b?" matches (with "")
            3 # last subtoken "b" matches, so report overall match
            0 # subtoken "b" cannot backtrack, so subtoken fails 
            0 # subtoken "b?" cannot backtrack, so subtoken fails
            0 # subtoken "a" cannot backtrack, so subtoken fails  
        ])
    
    "testEmptySequenceToken": () ->
        state = @Regex.setupInitialState("")
        # Put together token for regex //
        token = new Sequence()
        @assertNextMatchSequence(token, state, [
            1 # token matches but does not advance the cursor
        ])
        state = @Regex.setupInitialState("a")
        @assertNextMatchSequence(token, state, [
            1 # token matches but does not advance the cursor
        ])
        state.currentPosition = 2
        @assertNextMatchSequence(token, state, [
            2 # token matches but does not advance the cursor
        ])
        
    "testOptionToken": () ->
        state = @Regex.setupInitialState("ab")
        # Put together token for regex /a?/
        token = new Option(new Character("a"))
        @assertNextMatchSequence(token, state, [
           -1 # subtoken "a" matches
            2 # subtoken has matched, so report overall match
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
        
    "testGroupToken": () ->
        state = @Regex.setupInitialState("a")
        # Put together token for regex /(a?)/
        token = new Group(new Option(new Character("a")))
        @assertNextMatchSequence(token, state, [
           -1 # subsubtoken "a" matches
           -1 # subsubtoken has matched, so subtoken "a?" matches
            2 # subtoken has matched, so report overall match
            0 # subsubtoken "a" cannot backtrack, so subsubtoken fails
           -1 # subtoken "a?" matches by omitting the subsubtoken
            1 # subtoken has matched, so report overall match
            0 # subtoken "a?" cannot backtrack, so subtoken fails
            #false: the group reports overall failure after the subtoken has ultimately failed
        ])
            
    "testRepeatZeroOrMoreToken": () ->
        state = @Regex.setupInitialState("aaab")
        # Put together token for regex /a*/
        token = new RepeatZeroOrMore(new Character("a"))
        @assertNextMatchSequence(token, state, [
           -1 # first instance of subtoken "a" matches
           -1 # second instance of subtoken "a" matches
           -1 # third instances of subtokn "a" matches
            0 # fourth instance of subtoken "a" fails
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
        
        # Put together token for regex /(a|b)*/
        state = @Regex.setupInitialState("ab")
        disjunction = new Disjunction()
        disjunction.subtokens.push(new Character("a"))
        disjunction.subtokens.push(new Character("b"))
        token = new RepeatZeroOrMore(new Group(disjunction))
        @assertNextMatchSequence(token, state, [
           -1 # subsubtoken "a" matches
           -1 # therefore, first instance of subtoken "(a|b)" matches
            0 # second instance fails when trying "a" 
           -1 # second instance matches with subsubtoken "b"
           -1 # therefore, second instance of subtoken "(a|b)" matches
            0 # third instance fails when trying "a"
            0 # third instance fails again when trying "b"
            0 # disjunction in third instance reports overall failure
            0 # therefore, third instance of subtoken "(a|b)" fails
            3 # third instance is discarded to give a match
            0 # second instance fails when trying to backtrack "b"
            0 # disjunction in second instance reports overall failure
            0 # therefore, second instance of subtoken "(a|b)" fails
            2 # second instance is discarded to give another match
            0 # first instance fails when trying to backtrack "a"
            0 # first instance fails again when trying "b"
            0 # disjunction in first instance reports overall failure
            0 # therefore, first instance of subtoken "(a|b)" fails
            1 # first instance is discarded to give another match
        ])
            
    "testRepeatOneOrMoreToken": () ->
        state = @Regex.setupInitialState("aaab")
        # Put together token for regex /a+/
        token = new RepeatOneOrMore(new Character("a"))
        @assertNextMatchSequence(token, state, [
           -1 # first instance of subtoken "a" matches
           -1 # second instance of subtoken "a" matches
           -1 # third instances of subtokn "a" matches
            0 # fourth instance of subtoken "a" fails
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
        
        # Put together token for regex /(a|b)+/
        state = @Regex.setupInitialState("ab")
        disjunction = new Disjunction()
        disjunction.subtokens.push(new Character("a"))
        disjunction.subtokens.push(new Character("b"))
        token = new RepeatOneOrMore(new Group(disjunction))
        @assertNextMatchSequence(token, state, [
           -1 # subsubtoken "a" matches
           -1 # therefore, first instance of subtoken "(a|b)" matches
            0 # second instance fails when trying "a" 
           -1 # second instance matches with subsubtoken "b"
           -1 # therefore, second instance of subtoken "(a|b)" matches
            0 # third instance fails when trying "a"
            0 # third instance fails again when trying "b"
            0 # disjunction in third instance reports overall failure
            0 # therefore, third instance of subtoken "(a|b)" fails
            3 # third instance is discarded to give a match
            0 # second instance fails when trying to backtrack "b"
            0 # disjunction in second instance reports overall failure
            0 # therefore, second instance of subtoken "(a|b)" fails
            2 # second instance is discarded to give another match
            0 # first instance fails when trying to backtrack "a"
            0 # first instance fails again when trying "b"
            0 # disjunction in first instance reports overall failure
            0 # therefore, first instance of subtoken "(a|b)" fails
            0 # first instance is discarded, but we need at least one repetition
        ])
            
    "testInfiniteLoop": () ->
        state = @Regex.setupInitialState("b")
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
           -1 # first instance of subtoken "a?" matches empty
            0 # second instance fails when trying "a"
            0 # second instance of subtoken "a?" matches empty, but more than one empty submatch is disregarded, so subtoken fails
            1 # second instance is discarded to give a match
            0 # first instance of subtoken "a?" cannot backtrack, so fails
            0 # first instance is discarded, but we need at least one repetition
        ])
        
    "testBasicCharacterClass": () ->
        state = @Regex.setupInitialState("abc")
        # Put together token for regex /[ac]/
        token = new CharacterClass()
        token.addCharacter("a")
        token.addCharacter("c")
        
        @assertNextMatchSequence(token, state, [
            2 # "a" is part of the class
        ])
        
        state.currentPosition = 2 # advance to position before b
        @assertNextMatchSequence(token, state, []) # "b" is not part of the class
        
        state.currentPosition = 3 # advance to position before c
        @assertNextMatchSequence(token, state, [
            4 # "c" is part of the class
        ])
        
    "testNegatedCharacterClass": () ->
        state = @Regex.setupInitialState("abc")
        # Put together token for regex /[^ac]/
        token = new CharacterClass(true)
        token.addCharacter("a")
        token.addCharacter("c")
        
        @assertNextMatchSequence(token, state, [])
        
        state.currentPosition = 2 # advance to position before b
        @assertNextMatchSequence(token, state, [
            3 # "b" is not part of the class
        ])
        
        state.currentPosition = 3 # advance to position before c
        @assertNextMatchSequence(token, state, [])
        
    "testCharacterClassRange": () ->
        state = @Regex.setupInitialState("abcd")
        # Put together token for regex /[a-c]/
        token = new CharacterClass()
        token.addRange("a","c")
        
        @assertNextMatchSequence(token, state, [
            2 # "a" is part of the class
        ])
        
        state.currentPosition = 2 # advance to position before b
        @assertNextMatchSequence(token, state, [
            3 # "b" is part of the class (as it's between "a" and "c")
        ])
        
        state.currentPosition = 3 # advance to position before c
        @assertNextMatchSequence(token, state, [
            4 # "c" is part of the class
        ])
        
        state.currentPosition = 4 # advance to position before d
        @assertNextMatchSequence(token, state, [])     

    # This function assumes that the sequence does not contain the ultimate "false"
    assertNextMatchSequence: (token, state, sequence) ->
        for i in [1..2] # run twice to make sure that token's state is reset after reporting "false"
            step = 0
            for expectedResult in sequence
                assertSame("Assertion failed at step #{step}:", expectedResult, token.nextMatch(state))
                ++step
            assertSame(false, token.nextMatch(state))
)