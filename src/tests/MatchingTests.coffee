TestCase("MatchingTests",
    setUp : () ->
        if typeof module != "undefined" && module.exports
            #On a server
            @RegexEngine = new require("RegexEngine").RegexEngine
        else
            #On a client
            @RegexEngine = new window.RegexEngine
            
    "testEmptyPattern": () ->
        assertTrue(@RegexEngine.test("", ""))
        assertTrue(@RegexEngine.test("", "a"))
            
    "testSingleCharacter": () -> 
        assertTrue(@RegexEngine.test("a", "a"))
        assertTrue(@RegexEngine.test("a", "bar"))
        assertTrue(@RegexEngine.test("a", "bra"))
        assertTrue(@RegexEngine.test("a", "abra"))
        assertFalse(@RegexEngine.test("a", "b"))
        assertSame("a", @RegexEngine.match("a", "bar"))

    "testMultipleCharacters": () ->
        assertTrue(@RegexEngine.test("aa", "aa"))    
        assertTrue(@RegexEngine.test("aa", "baar"))
        assertTrue(@RegexEngine.test("aa", "braa"))
        assertTrue(@RegexEngine.test("aa", "abraa"))
        assertFalse(@RegexEngine.test("aa", "a"))
        assertFalse(@RegexEngine.test("aa", "aba"))
        assertFalse(@RegexEngine.test("aa", "bb"))
        assertTrue(@RegexEngine.test("ab", "ab"))    
        assertFalse(@RegexEngine.test("ab", "baar"))
        assertFalse(@RegexEngine.test("ab", "braa"))
        assertTrue(@RegexEngine.test("ab", "abraa"))
        assertFalse(@RegexEngine.test("ab", "a"))
        assertTrue(@RegexEngine.test("ab", "aba"))
        assertFalse(@RegexEngine.test("ab", "bb"))
        assertSame("ab", @RegexEngine.match("ab", "aabar"))
        
    "testAnchors": () ->
        assertTrue(@RegexEngine.test("^$", ""))
        assertTrue(@RegexEngine.test("$^", ""))
        assertTrue(@RegexEngine.test("^", "a"))
        assertTrue(@RegexEngine.test("$", "a"))
        assertTrue(@RegexEngine.test("^a", "a"))
        assertTrue(@RegexEngine.test("a$", "a"))
        assertTrue(@RegexEngine.test("^a$", "a"))
        assertTrue(@RegexEngine.test("^bar", "bara"))
        assertTrue(@RegexEngine.test("bar$", "abar"))
        assertTrue(@RegexEngine.test("^bar$", "bar"))
        assertFalse(@RegexEngine.test("^$", "a"))
        assertFalse(@RegexEngine.test("^a", "ba"))
        assertFalse(@RegexEngine.test("^a", "bar"))
        assertFalse(@RegexEngine.test("a$", "ab"))
        assertFalse(@RegexEngine.test("a$", "bar"))
        assertFalse(@RegexEngine.test("^a$", "ab"))
        assertFalse(@RegexEngine.test("^a$", "ba"))
        assertFalse(@RegexEngine.test("^a$", "bar"))
        assertFalse(@RegexEngine.test("^bar", "abar"))
        assertFalse(@RegexEngine.test("bar$", "bara"))
        assertFalse(@RegexEngine.test("^bar$", "abar"))
        assertFalse(@RegexEngine.test("^bar$", "bara"))
        assertFalse(@RegexEngine.test("^bar$", "abara"))
        assertSame("", @RegexEngine.match("^", "a"))
        assertSame("", @RegexEngine.match("$", "a"))
        assertSame("a", @RegexEngine.match("^a$", "a"))
        
    "testWildcard": () ->
        assertFalse(@RegexEngine.test(".", ""))
        assertTrue(@RegexEngine.test(".", "."))
        assertTrue(@RegexEngine.test(".", "a"))
        assertTrue(@RegexEngine.test("..", "ab"))
        assertTrue(@RegexEngine.test("..", "cc"))
        assertTrue(@RegexEngine.test(".a.", "bar"))
        assertFalse(@RegexEngine.test(".a.", "a"))
        assertFalse(@RegexEngine.test(".", "\n"))
        assertFalse(@RegexEngine.test(".", "\r"))
        assertTrue(@RegexEngine.test(".", " "))
        assertTrue(@RegexEngine.test(".", "\t"))
        assertFalse(@RegexEngine.test("a.", "a\nb"))
        assertSame("a", @RegexEngine.match(".", "a"))
        assertSame("ab", @RegexEngine.match("..", "ab"))
    
    # Note that every \\ becomes a single \ in the string, which then becomes the regex
    # i.e. matching a literal \ requires regex "\\\\", because the engine needs to
    # receive two backslashes, so that the first escapes the second one
    "testEscapedCharacters": () ->
        assertTrue(@RegexEngine.test("a\\^", "a^"))
        assertTrue(@RegexEngine.test("\\$a", "$a"))
        assertTrue(@RegexEngine.test("\\\\", "\\"))
        assertTrue(@RegexEngine.test("\\(", "("))
        assertTrue(@RegexEngine.test("\\)", ")"))
        assertTrue(@RegexEngine.test("^\\(a\\)$", "(a)"))
        assertTrue(@RegexEngine.test("\\[", "["))
        assertTrue(@RegexEngine.test("\\]", "]"))
        assertTrue(@RegexEngine.test("^\\[ab\\]$", "[ab]"))
        assertTrue(@RegexEngine.test("^a\\|b$", "a|b"))
        assertFalse(@RegexEngine.test("a\\|b", "a"))
        assertTrue(@RegexEngine.test("\\*", "*"))
        assertFalse(@RegexEngine.test("a\\*", "aaa"))
        assertTrue(@RegexEngine.test("\\+", "+"))
        assertFalse(@RegexEngine.test("a\\+", "aaa"))
        assertTrue(@RegexEngine.test("a\\?", "a?"))
        assertFalse(@RegexEngine.test("a\\?", "?"))
        assertTrue(@RegexEngine.test("\\.", "."))
        assertFalse(@RegexEngine.test("\\.", "a"))
        assertTrue(@RegexEngine.test("\\{", "{"))
        assertTrue(@RegexEngine.test("\\}", "}"))
        assertTrue(@RegexEngine.test("a\\{2}", "a{2}"))
        assertFalse(@RegexEngine.test("a\\{2\\}", "aa"))
        assertSame("^", @RegexEngine.match("\\^", "^"))
        
    "testAlternation": () ->
        assertTrue(@RegexEngine.test("a|b", "a"))
        assertTrue(@RegexEngine.test("a|b", "b"))
        assertTrue(@RegexEngine.test("a|b", "ab"))
        assertFalse(@RegexEngine.test("a|b", ""))
        assertFalse(@RegexEngine.test("a|b", "c"))
        assertTrue(@RegexEngine.test("a|b|c", "c"))
        assertTrue(@RegexEngine.test("a|b|", "c"))
        assertTrue(@RegexEngine.test("a||b", "c"))
        assertTrue(@RegexEngine.test("|a|b", "c"))
        assertTrue(@RegexEngine.test("^a|b$", "abc"))
        assertTrue(@RegexEngine.test("^a|b$", "cab"))
        assertFalse(@RegexEngine.test("^a|b$", "cabc"))
        assertSame("a", @RegexEngine.match("a|b|ab", "ab"))
        assertSame("ab", @RegexEngine.match("b|ab|a", "ab"))
        assertSame("a", @RegexEngine.match("b|a|ab", "ab"))
        
    "testGrouping": () ->
        assertTrue(@RegexEngine.test("(a)", "a"))
        assertTrue(@RegexEngine.test("(a)b", "ab"))
        assertTrue(@RegexEngine.test("a(b|c)d", "abd"))
        assertTrue(@RegexEngine.test("a(b|c)d", "acd"))
        assertFalse(@RegexEngine.test("a(b|c)d", "ab"))
        assertFalse(@RegexEngine.test("a(b|c)d", "cd"))
        assertFalse(@RegexEngine.test("a(b|c)d", "ad"))
        assertTrue(@RegexEngine.test("a(|b|c)d", "ad"))
        assertTrue(@RegexEngine.test("a(b||c)d", "ad"))
        assertTrue(@RegexEngine.test("a(b|c|)d", "ad"))
        assertTrue(@RegexEngine.test("^(a|b)$", "a"))
        assertTrue(@RegexEngine.test("^(a|b)$", "b"))
        assertFalse(@RegexEngine.test("^(a|b)$", "abc"))
        assertTrue(@RegexEngine.test("(a|b)(c|d)", "ac"))
        assertTrue(@RegexEngine.test("(a|b)(c|d)", "bc"))
        assertTrue(@RegexEngine.test("(a|b)(c|d)", "ad"))
        assertTrue(@RegexEngine.test("(a|b)(c|d)", "bd"))
        assertFalse(@RegexEngine.test("^(a|b)(c|d)$", "abcd"))
        assertFalse(@RegexEngine.test("(a|b)(c|d)", "ab"))
        assertFalse(@RegexEngine.test("(a|b)(c|d)", "cd"))
        assertTrue(@RegexEngine.test("a(b|c(d|e))", "ab"))
        assertTrue(@RegexEngine.test("a(b|c(d|e))", "acd"))
        assertTrue(@RegexEngine.test("a(b|c(d|e))", "ace"))
        assertFalse(@RegexEngine.test("a(b|c(d|e))", "ac"))
        assertFalse(@RegexEngine.test("a(b|c(d|e))", "ad"))
        assertFalse(@RegexEngine.test("a(b|c(d|e))", "ae"))
        assertFalse(@RegexEngine.test("^a(b|c(d|e))$", "abd"))
        assertFalse(@RegexEngine.test("^a(b|c(d|e))$", "abe"))
        assertSame("ab", @RegexEngine.match("a(b|c(d|e))", "ab"))
    
    "testBacktracking": () ->
        assertTrue(@RegexEngine.test("(a|ab|abc)d", "ad"))
        assertTrue(@RegexEngine.test("(a|ab|abc)d", "abd"))
        assertTrue(@RegexEngine.test("(a|ab|abc)d", "abcd"))
        assertSame("abcd", @RegexEngine.match("(a|ab|abc)d", "abcd"))
        
    "testOption": () ->
        assertTrue(@RegexEngine.test("ab?c", "abc"))
        assertTrue(@RegexEngine.test("ab?c", "ac"))
        assertTrue(@RegexEngine.test("ab?b", "ab"))
        assertTrue(@RegexEngine.test("a(bc)?d", "abcd"))
        assertTrue(@RegexEngine.test("a(bc)?d", "ad"))
        assertSame("abcd", @RegexEngine.match("a(bc)?d", "abcd"))
        
    "testRepeatZeroOrMore": () ->
        assertTrue(@RegexEngine.test("a*", ""))
        assertTrue(@RegexEngine.test("a*", "a"))
        assertTrue(@RegexEngine.test("a*", "aa"))
        assertTrue(@RegexEngine.test("a*", "aaaaa"))
        assertTrue(@RegexEngine.test("^a*$", ""))
        assertTrue(@RegexEngine.test("^a*$", "a"))
        assertTrue(@RegexEngine.test("^a*$", "aa"))
        assertTrue(@RegexEngine.test("^a*$", "aaaaa"))
        assertTrue(@RegexEngine.test("(ab)*", "ababab"))
        assertTrue(@RegexEngine.test("a*ab", "aaaab"))
        assertTrue(@RegexEngine.test("^(a|b)*$", "abababbaabab"))
        assertSame("abababbaabab", @RegexEngine.match("^(a|b)*$", "abababbaabab"))
        
    "testRepeatOneOrMore": () ->
        assertFalse(@RegexEngine.test("a+", ""))
        assertTrue(@RegexEngine.test("a+", "a"))
        assertTrue(@RegexEngine.test("a+", "aa"))
        assertTrue(@RegexEngine.test("a+", "aaaaa"))
        assertFalse(@RegexEngine.test("^a+$", ""))
        assertTrue(@RegexEngine.test("^a+$", "a"))
        assertTrue(@RegexEngine.test("^a+$", "aa"))
        assertTrue(@RegexEngine.test("^a+$", "aaaaa"))
        assertTrue(@RegexEngine.test("(ab)+", "ababab"))
        assertTrue(@RegexEngine.test("a+ab", "aaaab"))
        assertTrue(@RegexEngine.test("^(a|b)+$", "abababbaabab"))
        assertSame("abababbaabab", @RegexEngine.match("^(a|b)+$", "abababbaabab"))
        
    "testInfiniteLoop": () ->
        assertFalse(@RegexEngine.test("^(a*)*$", "b"))
        assertFalse(@RegexEngine.test("^(a?)+$", "b"))
        
    "testLeftMostMatch": () ->
        assertSame("a", @RegexEngine.match("(a|b)", "ab"))
        assertSame("b", @RegexEngine.match("(a|b)", "ba"))
        assertSame("aa", @RegexEngine.match("a*", "aabaaa"))
        
    "testGreediness": () ->
        assertSame("a", @RegexEngine.match("a?", "a"))
        assertSame("", @RegexEngine.match("a?", "b"))
        assertSame("", @RegexEngine.match("a?", "ba")) # due to left-most matching
        assertSame("aaaaa", @RegexEngine.match("a*", "aaaaa"))
        assertSame("", @RegexEngine.match("a*", "baaaaa"))
        assertSame("aaaaa", @RegexEngine.match("a+", "aaaaa"))
        assertSame("aaaaa", @RegexEngine.match("a+", "baaaaa"))
        assertSame("abc", @RegexEngine.match("(a|b|bc|d)*c", "abcdc"))
        assertSame("abcdc", @RegexEngine.match("(a|bc|b|d)*c", "abcdc"))
)