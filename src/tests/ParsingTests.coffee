TestCase("ParsingTests",
    setUp : () ->
        if typeof module != "undefined" && module.exports
            #On a server
            @RegexEngine = new require("RegexEngine").RegexEngine
        else
            #On a client
            @RegexEngine = new window.RegexEngine
        
    "testCharacter": () ->
        regex = @RegexEngine.parsePattern("a")
        expectedTree =
            type: RootToken
            subtokens: [
                type: Character
                subtokens: []
            ]
        @assertSyntaxTree(expectedTree, regex)
        
    "testEscapedCharacter": () ->
        regex = @RegexEngine.parsePattern("\\?")
        expectedTree =
            type: RootToken
            subtokens: [
                type: Character
                subtokens: []
            ]
        @assertSyntaxTree(expectedTree, regex)
        
    "testWildcard": () ->
        regex = @RegexEngine.parsePattern(".")
        expectedTree =
            type: RootToken
            subtokens: [
                type: Wildcard
                subtokens: []
            ]
        @assertSyntaxTree(expectedTree, regex)
        
    "testStartAnchor": () ->
        regex = @RegexEngine.parsePattern("^")
        expectedTree =
            type: RootToken
            subtokens: [
                type: StartAnchor
                subtokens: []
            ]
        @assertSyntaxTree(expectedTree, regex)
        
    "testEndAnchor": () ->
        regex = @RegexEngine.parsePattern("$")
        expectedTree =
            type: RootToken
            subtokens: [
                type: EndAnchor
                subtokens: []
            ]
        @assertSyntaxTree(expectedTree, regex)

    "testSequence": () ->
        regex = @RegexEngine.parsePattern("abc")
        expectedTree =
            type: RootToken
            subtokens: [
                type: Sequence
                subtokens: [
                    type: Character
                    subtokens: []
                   ,
                    type: Character
                    subtokens: []
                   ,
                    type: Character
                    subtokens: []
                ]
            ]
        @assertSyntaxTree(expectedTree, regex)

    "testAlternation": () ->
        regex = @RegexEngine.parsePattern("a|b|c")
        expectedTree =
            type: RootToken
            subtokens: [
                type: Alternation
                subtokens: [
                    type: Character
                    subtokens: []
                   ,
                    type: Character
                    subtokens: []
                   ,
                    type: Character
                    subtokens: []
                ]
            ]
        @assertSyntaxTree(expectedTree, regex)

    "testOption": () ->
        regex = @RegexEngine.parsePattern("a?")
        expectedTree =
            type: RootToken
            subtokens: [
                type: Option
                subtokens: [
                    type: Character
                    subtokens: []
                ]
            ]
        @assertSyntaxTree(expectedTree, regex)

    "testRepeatZeroOrMore": () ->
        regex = @RegexEngine.parsePattern("a*")
        expectedTree =
            type: RootToken
            subtokens: [
                type: RepeatZeroOrMore
                subtokens: [
                    type: Character
                    subtokens: []
                ]
            ]
        @assertSyntaxTree(expectedTree, regex)
        
    "testGroup": () ->
        regex = @RegexEngine.parsePattern("(a)")
        expectedTree =
            type: RootToken
            subtokens: [
                type: Group
                subtokens: [
                    type: Character
                    subtokens: []
                ]
            ]
        @assertSyntaxTree(expectedTree, regex)
            
    "testComplexExpression": () ->
        @RegexEngine.parsePattern("d.(ab?|c|)?$")
        expectedTree =
            type: RootToken
            subtokens: [
                type: Sequence
                subtokens: [
                    type: Character
                    subtokens: []
                   ,
                    type: Wildcard
                    subtokens: []
                   ,
                    type: Option
                    subtokens: [
                        type: Group
                        subtokens: [
                            type: Alternation
                            subtokens: [
                                type: Sequence
                                subtokens: [
                                    type: Character
                                    subtokens: []
                                   ,
                                    type: Option
                                    subtokens: [
                                        type: Character
                                        subtokens: []
                                    ]
                                ]
                               ,
                                type: Character
                                subtokens: []
                               ,
                                type: Sequence
                                subtokens: []
                            ]
                        ]
                    ]
                   ,
                    type: EndAnchor
                    subtokens: []                    
                ]
            ]
    
    "testInvalidSyntax": () ->
        that = this
        
        assertParsingException = (pattern, exception) ->
            assertException(
                () -> that.RegexEngine.parsePattern(pattern)
                exception
            )
            
        assertParsingException("\\", "NothingToEscapeException")
        assertParsingException(")", "UnmatchedClosingParenthesisException")
        assertParsingException("())", "UnmatchedClosingParenthesisException")
        assertParsingException("(", "MissingClosingParenthesisException")
        assertParsingException("()(", "MissingClosingParenthesisException")            
        assertParsingException("(()", "MissingClosingParenthesisException")
        assertParsingException("?", "NothingToRepeatException")
        assertParsingException("a(?)", "NothingToRepeatException")
        assertParsingException("a|?", "NothingToRepeatException")
        assertParsingException("^?", "NothingToRepeatException")
        assertParsingException("$?", "NothingToRepeatException")
        assertParsingException("*", "NothingToRepeatException")
        assertParsingException("a(*)", "NothingToRepeatException")
        assertParsingException("a|*", "NothingToRepeatException")
        assertParsingException("^*", "NothingToRepeatException")
        assertParsingException("$*", "NothingToRepeatException")
        
    assertSyntaxTree: (expectedTree, actualTree) ->
        assertTrue(actualTree.constructor is expectedTree.type)
        assertEquals(expectedTree.subtokens.length, actualTree.subtokens.length)
        i = 0
        for subtoken in expectedTree.subtokens
            @assertSyntaxTree(subtoken, actualTree.subtokens[i])
            ++i
)