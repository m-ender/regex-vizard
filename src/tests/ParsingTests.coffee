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
            type: Group
            subtokens: [
                type: Character
                subtokens: []
            ]
        @assertSyntaxTree(expectedTree, regex)
        
    "testEscapedMetacharacter": () ->
        regex = @Parser.parsePattern("\\?")
        expectedTree =
            type: Group
            subtokens: [
                type: Character
                subtokens: []
            ]
        @assertSyntaxTree(expectedTree, regex)
        
    "testEscapeSequence": () ->
        regex = @Parser.parsePattern("\\n")
        expectedTree =
            type: Group
            subtokens: [
                type: Character
                subtokens: []
            ]
        @assertSyntaxTree(expectedTree, regex)
        
    "testWildcard": () ->
        regex = @Parser.parsePattern(".")
        expectedTree =
            type: Group
            subtokens: [
                type: Wildcard
                subtokens: []
            ]
        @assertSyntaxTree(expectedTree, regex)
        
    "testStartAnchor": () ->
        regex = @Parser.parsePattern("^")
        expectedTree =
            type: Group
            subtokens: [
                type: StartAnchor
                subtokens: []
            ]
        @assertSyntaxTree(expectedTree, regex)
        
    "testEndAnchor": () ->
        regex = @Parser.parsePattern("$")
        expectedTree =
            type: Group
            subtokens: [
                type: EndAnchor
                subtokens: []
            ]
        @assertSyntaxTree(expectedTree, regex)

    "testSequence": () ->
        regex = @Parser.parsePattern("abc")
        expectedTree =
            type: Group
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

    "testDisjunction": () ->
        regex = @Parser.parsePattern("a|b|c")
        expectedTree =
            type: Group
            subtokens: [
                type: Disjunction
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
            type: Group
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
            type: Group
            subtokens: [
                type: RepeatZeroOrMore
                subtokens: [
                    type: Character
                    subtokens: []
                ]
            ]
        @assertSyntaxTree(expectedTree, regex)

    "testRepeatOneOrMore": () ->
        regex = @Parser.parsePattern("a+")
        expectedTree =
            type: Group
            subtokens: [
                type: RepeatOneOrMore
                subtokens: [
                    type: Character
                    subtokens: []
                ]
            ]
        @assertSyntaxTree(expectedTree, regex)
        
    "testGroup": () ->
        regex = @Parser.parsePattern("(a)")
        expectedTree =
            type: Group
            subtokens: [
                type: Group
                subtokens: [
                    type: Character
                    subtokens: []
                ]
            ]
        @assertSyntaxTree(expectedTree, regex)
        
    "testCharacterClass": () ->
        expectedTree =
            type: Group
            subtokens: [
                type: CharacterClass
                subtokens: []
            ]
            
        regex = @Parser.parsePattern("[]")
        @assertSyntaxTree(expectedTree, regex)
            
        regex = @Parser.parsePattern("[a]")
        @assertSyntaxTree(expectedTree, regex)
        
        regex = @Parser.parsePattern("[abc]")
        @assertSyntaxTree(expectedTree, regex)
        
        regex = @Parser.parsePattern("[^]")
        @assertSyntaxTree(expectedTree, regex)
        
        regex = @Parser.parsePattern("[^abc]")
        @assertSyntaxTree(expectedTree, regex)
        
        regex = @Parser.parsePattern("[a-c]")
        @assertSyntaxTree(expectedTree, regex)
        
        regex = @Parser.parsePattern("[a\\]c]")
        @assertSyntaxTree(expectedTree, regex)
        
    "testWordBoundary": () ->
        regex = @Parser.parsePattern("\\b")
        expectedTree =
            type: Group
            subtokens: [
                type: WordBoundary
                subtokens: []
            ]
        
        @assertSyntaxTree(expectedTree, regex)
        
        regex = @Parser.parsePattern("\\B")
        @assertSyntaxTree(expectedTree, regex)
            
    "testComplexExpression": () ->
        regex = @Parser.parsePattern("d.(a[be]?|c|)*$")
        expectedTree =
            type: Group
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
                            type: Disjunction
                            subtokens: [
                                type: Sequence
                                subtokens: [
                                    type: Character
                                    subtokens: []
                                   ,
                                    type: Option
                                    subtokens: [
                                        type: CharacterClass
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
        assertParsingException("[\\", "NothingToEscapeException")
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
        assertParsingException("+", "NothingToRepeatException")
        assertParsingException("a(+)", "NothingToRepeatException")
        assertParsingException("a|+", "NothingToRepeatException")
        assertParsingException("^+", "NothingToRepeatException")
        assertParsingException("$+", "NothingToRepeatException")
        assertParsingException("[", "UnterminatedCharacterClassException")
        assertParsingException("[a", "UnterminatedCharacterClassException")
        assertParsingException("[\\]", "UnterminatedCharacterClassException")
        assertParsingException("[^", "UnterminatedCharacterClassException")
        assertParsingException("[b-a]", "CharacterClassRangeOutOfOrderException")
        assertParsingException("[\\d-a]", "CharacterClassInRangeException")
        assertParsingException("[a-\\d]", "CharacterClassInRangeException")
        
    assertSyntaxTree: (expectedTree, actualTree) ->
        #console.log(actualTree, expectedTree.type)
        assertTrue(actualTree.constructor is expectedTree.type)
        assertEquals(expectedTree.subtokens.length, actualTree.subtokens.length)
        i = 0
        for subtoken in expectedTree.subtokens
            @assertSyntaxTree(subtoken, actualTree.subtokens[i])
            ++i
)