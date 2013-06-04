TestCase("RegexEngine Tests",
    setUp : () ->
        if typeof module != "undefined" && module.exports
            #On a server
            @RegexEngine = new require("RegexEngine").RegexEngine
        else
            #On a client
            @RegexEngine = new window.RegexEngine
            
    "testParsing": () ->
        @RegexEngine.parsePattern("d.(ab?|c|)*$")
    
    "testInvalidSyntax": () ->
        that = this
        assertException(
            () -> 
                that.RegexEngine.match("\\", "")
            "NothingToEscapeException")
        assertException(
            () -> 
                that.RegexEngine.match(")", "")
            "UnmatchedClosingParenthesisException")
        assertException(
            () -> 
                that.RegexEngine.match("())", "")
            "UnmatchedClosingParenthesisException")
        assertException(
            () -> 
                that.RegexEngine.match("(", "")
            "MissingClosingParenthesisException")
        assertException(
            () -> 
                that.RegexEngine.match("()(", "")
            "MissingClosingParenthesisException")            
        assertException(
            () -> 
                that.RegexEngine.match("(()", "")
            "MissingClosingParenthesisException")
    
    "testCharacterToken": () ->
        state = @RegexEngine.setupInitialState("ab")
        token = new Character("a")
        assertEquals(2, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
        assertEquals(2, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
        state.currentPosition = 2
        assertEquals(false, token.nextMatch(state))
        state.currentPosition = 3
        assertEquals(false, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
        
        state.currentPosition = 1
        token = new Character("b")
        assertEquals(false, token.nextMatch(state))
        state.currentPosition = 2
        assertEquals(3, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
        assertEquals(3, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
        state.currentPosition = 3
        assertEquals(false, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
    
    "testWildcardToken": () ->
        state = @RegexEngine.setupInitialState("a\nb\r")
        token = new Wildcard()
        assertEquals(2, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
        assertEquals(2, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
        state.currentPosition = 2
        assertEquals(false, token.nextMatch(state))
        state.currentPosition = 3
        assertEquals(4, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
        assertEquals(4, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
        state.currentPosition = 4
        assertEquals(false, token.nextMatch(state))
        state.currentPosition = 5
        assertEquals(false, token.nextMatch(state))
        assertEquals(false, token.nextMatch(state))
            
    "testEmptyPattern": () ->
        assertTrue(@RegexEngine.match("", ""))
        assertTrue(@RegexEngine.match("", "a"))
            
    "testSingleCharacter": () -> 
        assertTrue(@RegexEngine.match("a", "a"))
        assertTrue(@RegexEngine.match("a", "bar"))
        assertTrue(@RegexEngine.match("a", "bra"))
        assertTrue(@RegexEngine.match("a", "abra"))
        assertFalse(@RegexEngine.match("a", "b"))

    "testMultipleCharacters": () ->
        assertTrue(@RegexEngine.match("aa", "aa"))    
        assertTrue(@RegexEngine.match("aa", "baar"))
        assertTrue(@RegexEngine.match("aa", "braa"))
        assertTrue(@RegexEngine.match("aa", "abraa"))
        assertFalse(@RegexEngine.match("aa", "a"))
        assertFalse(@RegexEngine.match("aa", "aba"))
        assertFalse(@RegexEngine.match("aa", "bb"))
        assertTrue(@RegexEngine.match("ab", "ab"))    
        assertFalse(@RegexEngine.match("ab", "baar"))
        assertFalse(@RegexEngine.match("ab", "braa"))
        assertTrue(@RegexEngine.match("ab", "abraa"))
        assertFalse(@RegexEngine.match("ab", "a"))
        assertTrue(@RegexEngine.match("ab", "aba"))
        assertFalse(@RegexEngine.match("ab", "bb"))
        
    "testAnchors": () ->
        assertTrue(@RegexEngine.match("^$", ""))
        assertTrue(@RegexEngine.match("$^", ""))
        assertTrue(@RegexEngine.match("^", "a"))
        assertTrue(@RegexEngine.match("$", "a"))
        assertTrue(@RegexEngine.match("^a", "a"))
        assertTrue(@RegexEngine.match("a$", "a"))
        assertTrue(@RegexEngine.match("^a$", "a"))
        assertTrue(@RegexEngine.match("^bar", "bara"))
        assertTrue(@RegexEngine.match("bar$", "abar"))
        assertTrue(@RegexEngine.match("^bar$", "bar"))
        assertFalse(@RegexEngine.match("^$", "a"))
        assertFalse(@RegexEngine.match("^a", "ba"))
        assertFalse(@RegexEngine.match("^a", "bar"))
        assertFalse(@RegexEngine.match("a$", "ab"))
        assertFalse(@RegexEngine.match("a$", "bar"))
        assertFalse(@RegexEngine.match("^a$", "ab"))
        assertFalse(@RegexEngine.match("^a$", "ba"))
        assertFalse(@RegexEngine.match("^a$", "bar"))
        assertFalse(@RegexEngine.match("^bar", "abar"))
        assertFalse(@RegexEngine.match("bar$", "bara"))
        assertFalse(@RegexEngine.match("^bar$", "abar"))
        assertFalse(@RegexEngine.match("^bar$", "bara"))
        assertFalse(@RegexEngine.match("^bar$", "abara"))
        
    "testWildcard": () ->
        assertFalse(@RegexEngine.match(".", ""))
        assertTrue(@RegexEngine.match(".", "."))
        assertTrue(@RegexEngine.match(".", "a"))
        assertTrue(@RegexEngine.match("..", "ab"))
        assertTrue(@RegexEngine.match("..", "cc"))
        assertTrue(@RegexEngine.match(".a.", "bar"))
        assertFalse(@RegexEngine.match(".a.", "a"))
        assertFalse(@RegexEngine.match(".", "\n"))
        assertFalse(@RegexEngine.match(".", "\r"))
        assertTrue(@RegexEngine.match(".", " "))
        assertTrue(@RegexEngine.match(".", "\t"))
        assertFalse(@RegexEngine.match("a.", "a\nb"))
    
    # Note that every \\ becomes a single \ in the string, which then becomes the regex
    # i.e. matching a literal \ requires regex "\\\\", because the engine needs to
    # receive two backslashes, so that the first escapes the second one
    "testEscapedCharacters": () ->
        assertTrue(@RegexEngine.match("a\\^", "a^"))
        assertTrue(@RegexEngine.match("\\$a", "$a"))
        assertTrue(@RegexEngine.match("\\\\", "\\"))
        assertTrue(@RegexEngine.match("\\(", "("))
        assertTrue(@RegexEngine.match("\\)", ")"))
        assertTrue(@RegexEngine.match("^\\(a\\)$", "(a)"))
        assertTrue(@RegexEngine.match("\\[", "["))
        assertTrue(@RegexEngine.match("\\]", "]"))
        assertTrue(@RegexEngine.match("^\\[ab\\]$", "[ab]"))
        assertTrue(@RegexEngine.match("^a\\|b$", "a|b"))
        assertFalse(@RegexEngine.match("a\\|b", "a"))
        assertTrue(@RegexEngine.match("\\*", "*"))
        assertFalse(@RegexEngine.match("a\\*", "aaa"))
        assertTrue(@RegexEngine.match("\\+", "+"))
        assertFalse(@RegexEngine.match("a\\+", "aaa"))
        assertTrue(@RegexEngine.match("a\\?", "a?"))
        assertFalse(@RegexEngine.match("a\\?", "?"))
        assertTrue(@RegexEngine.match("\\.", "."))
        assertFalse(@RegexEngine.match("\\.", "a"))
        assertTrue(@RegexEngine.match("\\{", "{"))
        assertTrue(@RegexEngine.match("\\}", "}"))
        assertTrue(@RegexEngine.match("a\\{2}", "a{2}"))
        assertFalse(@RegexEngine.match("a\\{2\\}", "aa"))
        
    "testAlternation": () ->
        assertTrue(@RegexEngine.match("a|b", "a"))
        assertTrue(@RegexEngine.match("a|b", "b"))
        assertTrue(@RegexEngine.match("a|b", "ab"))
        assertFalse(@RegexEngine.match("a|b", ""))
        assertFalse(@RegexEngine.match("a|b", "c"))
        assertTrue(@RegexEngine.match("a|b|c", "c"))
        assertTrue(@RegexEngine.match("a|b|", "c"))
        assertTrue(@RegexEngine.match("a||b", "c"))
        assertTrue(@RegexEngine.match("|a|b", "c"))
        assertTrue(@RegexEngine.match("^a|b$", "abc"))
        assertTrue(@RegexEngine.match("^a|b$", "cab"))
        assertFalse(@RegexEngine.match("^a|b$", "cabc"))
        
    "testGrouping": () ->
        assertTrue(@RegexEngine.match("(a)", "a"))
        assertTrue(@RegexEngine.match("(a)b", "ab"))
        assertTrue(@RegexEngine.match("a(b|c)d", "abd"))
        assertTrue(@RegexEngine.match("a(b|c)d", "acd"))
        assertFalse(@RegexEngine.match("a(b|c)d", "ab"))
        assertFalse(@RegexEngine.match("a(b|c)d", "cd"))
        assertFalse(@RegexEngine.match("a(b|c)d", "ad"))
        assertTrue(@RegexEngine.match("a(|b|c)d", "ad"))
        assertTrue(@RegexEngine.match("a(b||c)d", "ad"))
        assertTrue(@RegexEngine.match("a(b|c|)d", "ad"))
        assertTrue(@RegexEngine.match("^(a|b)$", "a"))
        assertTrue(@RegexEngine.match("^(a|b)$", "b"))
        assertFalse(@RegexEngine.match("^(a|b)$", "abc"))
        assertTrue(@RegexEngine.match("(a|b)(c|d)", "ac"))
        assertTrue(@RegexEngine.match("(a|b)(c|d)", "bc"))
        assertTrue(@RegexEngine.match("(a|b)(c|d)", "ad"))
        assertTrue(@RegexEngine.match("(a|b)(c|d)", "bd"))
        assertFalse(@RegexEngine.match("^(a|b)(c|d)$", "abcd"))
        assertFalse(@RegexEngine.match("(a|b)(c|d)", "ab"))
        assertFalse(@RegexEngine.match("(a|b)(c|d)", "cd"))
        assertTrue(@RegexEngine.match("a(b|c(d|e))", "ab"))
        assertTrue(@RegexEngine.match("a(b|c(d|e))", "acd"))
        assertTrue(@RegexEngine.match("a(b|c(d|e))", "ace"))
        assertFalse(@RegexEngine.match("a(b|c(d|e))", "ac"))
        assertFalse(@RegexEngine.match("a(b|c(d|e))", "ad"))
        assertFalse(@RegexEngine.match("a(b|c(d|e))", "ae"))
        assertFalse(@RegexEngine.match("^a(b|c(d|e))$", "abd"))
        assertFalse(@RegexEngine.match("^a(b|c(d|e))$", "abe"))
    
    "testBacktracking": () ->
        assertTrue(@RegexEngine.match("(a|ab|abc)d", "ad"))
        assertTrue(@RegexEngine.match("(a|ab|abc)d", "abd"))
        assertTrue(@RegexEngine.match("(a|ab|abc)d", "abcd"))
)