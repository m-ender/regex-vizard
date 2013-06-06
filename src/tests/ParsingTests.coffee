TestCase("ParsingTests",
    setUp : () ->
        if typeof module != "undefined" && module.exports
            #On a server
            @Parser = new require("Parser").Parser
        else
            #On a client
            @Parser = new window.Parser
        
    "testCharacter": () ->
        regex = @Parser.parsePattern("a")
        expectedTree =
            type: RootToken
            subtokens: [
                type: Character
                subtokens: []
            ]
        @assertSyntaxTree(expectedTree, regex)
        
    "testEscapedCharacter": () ->
        regex = @Parser.parsePattern("\\?")
        expectedTree =
            type: RootToken
            subtokens: [
                type: Character
                subtokens: []
            ]
        @assertSyntaxTree(expectedTree, regex)
        
    "testWildcard": () ->
        regex = @Parser.parsePattern(".")
        expectedTree =
            type: RootToken
            subtokens: [
                type: Wildcard
                subtokens: []
            ]
        @assertSyntaxTree(expectedTree, regex)
        
    "testStartAnchor": () ->
        regex = @Parser.parsePattern("^")
        expectedTree =
            type: RootToken
            subtokens: [
                type: StartAnchor
                subtokens: []
            ]
        @assertSyntaxTree(expectedTree, regex)
        
    "testEndAnchor": () ->
        regex = @Parser.parsePattern("$")
        expectedTree =
            type: RootToken
            subtokens: [
                type: EndAnchor
                subtokens: []
            ]
        @assertSyntaxTree(expectedTree, regex)

    "testSequence": () ->
        regex = @Parser.parsePattern("abc")
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
        regex = @Parser.parsePattern("a|b|c")
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
        regex = @Parser.parsePattern("a?")
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
        regex = @Parser.parsePattern("a*")
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
        regex = @Parser.parsePattern("(a)")
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
        regex = @Parser.parsePattern("d.(ab?|c|)*$")
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
                    type: RepeatZeroOrMore
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
        @assertSyntaxTree(expectedTree, regex)
    
    "testInvalidSyntax": () ->
        that = this
        
        assertParsingException = (pattern, exception) ->
            assertException(
                () -> that.Parser.parsePattern(pattern)
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
        console.log(actualTree.constructor, expectedTree.type)
        assertTrue(actualTree.constructor is expectedTree.type)
        assertEquals(expectedTree.subtokens.length, actualTree.subtokens.length)
        i = 0
        for subtoken in expectedTree.subtokens
            @assertSyntaxTree(subtoken, actualTree.subtokens[i])
            ++i
)