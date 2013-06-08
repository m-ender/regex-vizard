TestCase("MatchingTests",
    setUp : () ->
        if typeof module != "undefined" && module.exports
            #On a server
            #regex = new require("RegexEngine").RegexEngine
        else
            #On a client
            #regex = new window.RegexEngine
            
    "testEmptyPattern": () ->
        regex = new Regex("")
        assertTrue(regex.test(""))
        assertTrue(regex.test("a"))
            
    "testSingleCharacter": () -> 
        regex = new Regex("a")
        assertTrue(regex.test("a"))
        assertTrue(regex.test("bar"))
        assertTrue(regex.test("bra"))
        assertTrue(regex.test("abra"))
        assertFalse(regex.test("b"))
        assertSame("a", regex.match("bar"))

    "testMultipleCharacters": () ->
        regex = new Regex("aa")
        assertTrue(regex.test("aa"))    
        assertTrue(regex.test("baar"))
        assertTrue(regex.test("braa"))
        assertTrue(regex.test("abraa"))
        assertFalse(regex.test("a"))
        assertFalse(regex.test("aba"))
        assertFalse(regex.test("bb"))
        regex = new Regex("ab")
        assertTrue(regex.test("ab"))    
        assertFalse(regex.test("baar"))
        assertFalse(regex.test("braa"))
        assertTrue(regex.test("abraa"))
        assertFalse(regex.test("a"))
        assertTrue(regex.test("aba"))
        assertFalse(regex.test("bb"))
        assertSame("ab", regex.match("aabar"))
        
    "testAnchors": () ->
        regex = new Regex("^")
        assertTrue(regex.test("a"))
        assertSame("", regex.match("a"))
        regex = new Regex("$")
        assertTrue(regex.test("a"))
        assertSame("", regex.match("a"))
        regex = new Regex("^$")
        assertTrue(regex.test(""))
        assertFalse(regex.test("a"))
        regex = new Regex("$^")
        assertTrue(regex.test(""))
        regex = new Regex("^a")
        assertTrue(regex.test("a"))
        assertFalse(regex.test("ba"))
        assertFalse(regex.test("bar"))
        regex = new Regex("a$")
        assertTrue(regex.test("a"))
        assertFalse(regex.test("ab"))
        assertFalse(regex.test("bar"))
        regex = new Regex("^a$")
        assertTrue(regex.test("a"))
        assertFalse(regex.test("ab"))
        assertFalse(regex.test("ba"))
        assertFalse(regex.test("bar"))
        assertSame("a", regex.match("a"))
        regex = new Regex("^bar")
        assertTrue(regex.test("bara"))
        assertFalse(regex.test("abar"))
        regex = new Regex("bar$")
        assertTrue(regex.test("abar"))
        assertFalse(regex.test("bara"))
        regex = new Regex("^bar$")
        assertTrue(regex.test("bar"))
        assertFalse(regex.test("abar"))
        assertFalse(regex.test("bara"))
        assertFalse(regex.test("abara"))
        
    "testWildcard": () ->
        regex = new Regex(".")
        assertFalse(regex.test(""))
        assertTrue(regex.test("."))
        assertTrue(regex.test("a"))
        assertFalse(regex.test("\n"))
        assertFalse(regex.test("\r"))
        assertTrue(regex.test(" "))
        assertTrue(regex.test("\t"))
        assertSame("a", regex.match("a"))
        regex = new Regex("..")
        assertTrue(regex.test("ab"))
        assertTrue(regex.test("cc"))
        assertSame("ab", regex.match("ab"))
        regex = new Regex(".a.")
        assertTrue(regex.test("bar"))
        assertFalse(regex.test("a"))
        regex = new Regex("a.")
        assertFalse(regex.test("a\nb"))
    
    # Note that every \\ becomes a single \ in the string, which then becomes the regex
    # i.e. matching a literal \ requires regex "\\\\", because the engine needs to
    # receive two backslashes, so that the first escapes the second one
    "testEscapedCharacters": () ->
        regex = new Regex("a\\^")
        assertTrue(regex.test("a^"))
        regex = new Regex("\\$a")
        assertTrue(regex.test("$a"))
        regex = new Regex("\\\\")
        assertTrue(regex.test("\\"))
        regex = new Regex("\\(")
        assertTrue(regex.test("("))
        regex = new Regex("\\)")
        assertTrue(regex.test(")"))
        regex = new Regex("^\\(a\\)$")
        assertTrue(regex.test("(a)"))
        regex = new Regex("\\[")
        assertTrue(regex.test("["))
        regex = new Regex("\\]")
        assertTrue(regex.test("]"))
        regex = new Regex("^\\[ab\\]$")
        assertTrue(regex.test("[ab]"))
        regex = new Regex("^a\\|b$")
        assertTrue(regex.test("a|b"))
        regex = new Regex("a\\|b")
        assertFalse(regex.test("a"))
        regex = new Regex("\\*")
        assertTrue(regex.test("*"))
        regex = new Regex("a\\*")
        assertFalse(regex.test("aaa"))
        regex = new Regex("\\+")
        assertTrue(regex.test("+"))
        regex = new Regex("a\\+")
        assertFalse(regex.test("aaa"))
        regex = new Regex("a\\?")
        assertTrue(regex.test("a?"))
        regex = new Regex("a\\?")
        assertFalse(regex.test("?"))
        regex = new Regex("\\.")
        assertTrue(regex.test("."))
        assertFalse(regex.test("a"))
        regex = new Regex("\\{")
        assertTrue(regex.test("{"))
        regex = new Regex("\\}")
        assertTrue(regex.test("}"))
        regex = new Regex("a\\{2}")
        assertTrue(regex.test("a{2}"))
        regex = new Regex("a\\{2\\}")
        assertFalse(regex.test("aa"))
        regex = new Regex("\\^")
        assertSame("^", regex.match("^"))
        
    "testAlternation": () ->
        regex = new Regex("a|b")
        assertTrue(regex.test("a"))
        assertTrue(regex.test("b"))
        assertTrue(regex.test("ab"))
        assertFalse(regex.test(""))
        assertFalse(regex.test("c"))
        regex = new Regex("a|b|c")
        assertTrue(regex.test("c"))
        regex = new Regex("a|b|")
        assertTrue(regex.test("c"))
        regex = new Regex("a||b")
        assertTrue(regex.test("c"))
        regex = new Regex("|a|b")
        assertTrue(regex.test("c"))
        regex = new Regex("^a|b$")
        assertTrue(regex.test("abc"))
        assertTrue(regex.test("cab"))
        assertFalse(regex.test("cabc"))
        regex = new Regex("a|b|ab")
        assertSame("a", regex.match("ab"))
        regex = new Regex("b|ab|a")
        assertSame("ab", regex.match("ab"))
        regex = new Regex("b|a|ab")
        assertSame("a", regex.match("ab"))
        
    "testGrouping": () ->
        regex = new Regex("(a)")
        assertTrue(regex.test("a"))
        regex = new Regex("(a)b")
        assertTrue(regex.test("ab"))
        regex = new Regex("a(b|c)d")
        assertTrue(regex.test("abd"))
        assertTrue(regex.test("acd"))
        assertFalse(regex.test("ab"))
        assertFalse(regex.test("cd"))
        assertFalse(regex.test("ad"))
        regex = new Regex("a(|b|c)d")
        assertTrue(regex.test("ad"))
        regex = new Regex("a(b||c)d")
        assertTrue(regex.test("ad"))
        regex = new Regex("a(b|c|)d")
        assertTrue(regex.test("ad"))
        regex = new Regex("^(a|b)$")
        assertTrue(regex.test("a"))
        assertTrue(regex.test("b"))
        assertFalse(regex.test("abc"))
        regex = new Regex("(a|b)(c|d)")
        assertTrue(regex.test("ac"))
        assertTrue(regex.test("bc"))
        assertTrue(regex.test("ad"))
        assertTrue(regex.test("bd"))
        assertFalse(regex.test("ab"))
        assertFalse(regex.test("cd"))
        regex = new Regex("^(a|b)(c|d)$")
        assertFalse(regex.test("abcd"))
        regex = new Regex("a(b|c(d|e))")
        assertTrue(regex.test("ab"))
        assertTrue(regex.test("acd"))
        assertTrue(regex.test("ace"))
        assertFalse(regex.test("ac"))
        assertFalse(regex.test("ad"))
        assertFalse(regex.test("ae"))
        assertSame("ab", regex.match("ab"))
        regex = new Regex("^a(b|c(d|e))$")
        assertFalse(regex.test("abd"))
        assertFalse(regex.test("abe"))
    
    "testBacktracking": () ->
        regex = new Regex("(a|ab|abc)d")
        assertTrue(regex.test("ad"))
        assertTrue(regex.test("abd"))
        assertTrue(regex.test("abcd"))
        assertSame("abcd", regex.match("abcd"))
        
    "testOption": () ->
        regex = new Regex("ab?c")
        assertTrue(regex.test("abc"))
        assertTrue(regex.test("ac"))
        regex = new Regex("ab?b")
        assertTrue(regex.test("ab"))
        regex = new Regex("a(bc)?d")
        assertTrue(regex.test("abcd"))
        assertTrue(regex.test("ad"))
        assertSame("abcd", regex.match("abcd"))
        
    "testRepeatZeroOrMore": () ->
        regex = new Regex("a*")
        assertTrue(regex.test(""))
        assertTrue(regex.test("a"))
        assertTrue(regex.test("aa"))
        assertTrue(regex.test("aaaaa"))
        regex = new Regex("^a*$")
        assertTrue(regex.test(""))
        assertTrue(regex.test("a"))
        assertTrue(regex.test("aa"))
        assertTrue(regex.test("aaaaa"))
        regex = new Regex("(ab)*")
        assertTrue(regex.test("ababab"))
        regex = new Regex("a*ab")
        assertTrue(regex.test("aaaab"))
        regex = new Regex("^(a|b)*$")
        assertTrue(regex.test("abababbaabab"))
        assertSame("abababbaabab", regex.match("abababbaabab"))
        
    "testRepeatOneOrMore": () ->
        regex = new Regex("a+")
        assertFalse(regex.test(""))
        assertTrue(regex.test("a"))
        assertTrue(regex.test("aa"))
        assertTrue(regex.test("aaaaa"))
        regex = new Regex("^a+$")
        assertFalse(regex.test(""))
        assertTrue(regex.test("a"))
        assertTrue(regex.test("aa"))
        assertTrue(regex.test("aaaaa"))
        regex = new Regex("(ab)+")
        assertTrue(regex.test("ababab"))
        regex = new Regex("a+ab")
        assertTrue(regex.test("aaaab"))
        regex = new Regex("^(a|b)+$")
        assertTrue(regex.test("abababbaabab"))
        assertSame("abababbaabab", regex.match("abababbaabab"))
        
    "testInfiniteLoop": () ->
        regex = new Regex("^(a*)*$")
        assertFalse(regex.test("b"))
        regex = new Regex("^(a?)+$")
        assertFalse(regex.test("b"))
        regex = new Regex("^(a|b|)*$")
        assertFalse(regex.test("abc"))
        
    "testLeftMostMatch": () ->
        regex = new Regex("(a|b)")
        assertSame("a", regex.match("ab"))
        assertSame("b", regex.match("ba"))
        regex = new Regex("a*")
        assertSame("aa", regex.match("aabaaa"))
        
    "testGreediness": () ->
        regex = new Regex("a?")
        assertSame("a", regex.match("a"))
        assertSame("", regex.match("b"))
        assertSame("", regex.match("ba")) # due to left-most matching
        regex = new Regex("a*")
        assertSame("aaaaa", regex.match("aaaaa"))
        assertSame("", regex.match("baaaaa"))
        regex = new Regex("a+")
        assertSame("aaaaa", regex.match("aaaaa"))
        assertSame("aaaaa", regex.match("baaaaa"))
        regex = new Regex("(a|b|bc|d)*c")
        assertSame("abc", regex.match("abcdc"))
        regex = new Regex("(a|bc|b|d)*c")
        assertSame("abcdc", regex.match("abcdc"))
)