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
        assertFalse(regex.test("\u2028"))
        assertFalse(regex.test("\u2029"))
        assertTrue(regex.test("\v"))
        assertTrue(regex.test("\f"))
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
    "testEscapedMetacharacters": () ->
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
        
    "testEscapeSequences": () ->
        regex = new Regex("\n")
        assertTrue(regex.test("\n"))
        regex = new Regex("\\n")
        assertFalse(regex.test("n"))
        assertTrue(regex.test("\n"))
        regex = new Regex("\r")
        assertTrue(regex.test("\r"))
        regex = new Regex("\\r")
        assertFalse(regex.test("r"))
        assertTrue(regex.test("\r"))
        regex = new Regex("\t")
        assertTrue(regex.test("\t"))
        regex = new Regex("\\t")
        assertFalse(regex.test("t"))
        assertTrue(regex.test("\t"))
        regex = new Regex("\f")
        assertTrue(regex.test("\f"))
        regex = new Regex("\\f")
        assertFalse(regex.test("f"))
        assertTrue(regex.test("\f"))
        regex = new Regex("\v")
        assertTrue(regex.test("\v"))
        regex = new Regex("\\v")
        assertFalse(regex.test("v"))
        assertTrue(regex.test("\v"))
        regex = new Regex("\0")
        assertTrue(regex.test("\0"))
        regex = new Regex("\\0")
        assertFalse(regex.test("0"))
        assertTrue(regex.test("\0"))
        
    "testDisjunction": () ->
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
        
    "testBasicCharacterClass": () ->
        regex = new Regex("[ac]")
        assertTrue(regex.test("a"))
        assertFalse(regex.test("b"))
        assertTrue(regex.test("c"))
        assertSame("a", regex.match("ac"))
        
    "testEmptyCharacterClass": () ->
        regex = new Regex("[]")
        assertFalse(regex.test("a"))
        assertFalse(regex.test(""))
        regex = new Regex("[^]")
        assertFalse(regex.test(""))
        assertTrue(regex.test("a"))
        assertTrue(regex.test("§"))
        
    "testNegatedCharacterClass": () ->
        regex = new Regex("[^ac]")
        assertFalse(regex.test(""))
        assertFalse(regex.test("a"))
        assertTrue(regex.test("b"))
        assertFalse(regex.test("c"))
        assertSame("b", regex.match("acbd"))
        
    "testCharacterClassRange": () ->
        regex = new Regex("[a-c]")
        assertFalse(regex.test(""))
        assertTrue(regex.test("a"))
        assertTrue(regex.test("b"))
        assertTrue(regex.test("c"))
        assertFalse(regex.test("d"))
        regex = new Regex("[A-z]")
        assertFalse(regex.test(""))
        assertTrue(regex.test("Q"))
        assertTrue(regex.test("q"))
        assertTrue(regex.test("[")) # code point lies between Z and a
        assertTrue(regex.test("]")) # code point lies between Z and a
        assertTrue(regex.test("_")) # code point lies between Z and a
        assertFalse(regex.test("@"))
        assertFalse(regex.test("{"))
        regex = new Regex("[aA-Z0-9]")
        assertFalse(regex.test(""))
        assertTrue(regex.test("a"))
        assertFalse(regex.test("b"))
        assertTrue(regex.test("B"))
        assertTrue(regex.test("Z"))
        assertTrue(regex.test("5"))
        assertFalse(regex.test("="))
        regex = new Regex("^[[-\\]]$")
        assertTrue(regex.test("["))
        assertTrue(regex.test("\\"))
        assertTrue(regex.test("]"))
        assertFalse(regex.test("-"))
        
    "testNegatedCharacterClassRange": () ->
        regex = new Regex("[^a-c]")
        assertFalse(regex.test(""))
        assertFalse(regex.test("a"))
        assertFalse(regex.test("b"))
        assertFalse(regex.test("c"))
        assertTrue(regex.test("d"))
        regex = new Regex("[^A-z]")
        assertFalse(regex.test(""))
        assertFalse(regex.test("Q"))
        assertFalse(regex.test("q"))
        assertFalse(regex.test("[")) # code point lies between Z and a
        assertFalse(regex.test("]")) # code point lies between Z and a
        assertFalse(regex.test("_")) # code point lies between Z and a
        assertTrue(regex.test("@"))
        assertTrue(regex.test("{"))
        regex = new Regex("[^aA-Z0-9]")
        assertFalse(regex.test(""))
        assertFalse(regex.test("a"))
        assertTrue(regex.test("b"))
        assertFalse(regex.test("B"))
        assertFalse(regex.test("Z"))
        assertFalse(regex.test("5"))
        assertTrue(regex.test("="))
    
    # This tests both escape sequences and situations in which metacharacters do not have to be escaped.
    "testCharacterClassEscapeSequences": () ->
        regex = new Regex("^[\\b]$")
        assertTrue(regex.test("\b"))
        regex = new Regex("^[\\]]$")
        assertTrue(regex.test("]"))
        regex = new Regex("^[a\\-c]$")
        assertTrue(regex.test("a"))
        assertFalse(regex.test("b"))
        assertTrue(regex.test("c"))
        assertTrue(regex.test("-"))
        regex = new Regex("^[-ac]$")
        assertTrue(regex.test("a"))
        assertFalse(regex.test("b"))
        assertTrue(regex.test("c"))
        assertTrue(regex.test("-"))
        regex = new Regex("^[ac-]$")
        assertTrue(regex.test("a"))
        assertFalse(regex.test("b"))
        assertTrue(regex.test("c"))
        assertTrue(regex.test("-"))
        regex = new Regex("^[a-c-e]$")
        assertTrue(regex.test("a"))
        assertTrue(regex.test("b"))
        assertTrue(regex.test("c"))
        assertFalse(regex.test("d"))
        assertTrue(regex.test("e"))
        assertTrue(regex.test("-"))
        regex = new Regex("^[\\^a]$")
        assertTrue(regex.test("a"))
        assertTrue(regex.test("^"))
        regex = new Regex("^[a^]$")
        assertTrue(regex.test("a"))
        assertTrue(regex.test("^"))
        
    "testQuantifyCharacterClass": () ->
        regex = new Regex("[ac]+")
        assertTrue(regex.test("aaccacac"))
        assertFalse(regex.test("bde"))
        assertSame("aca", regex.match("bacaba"))
        
    "testBuiltInCharacterClasses": () ->
        assertCharCodeTrue = (cl, charCodeRange) ->
            for i in charCodeRange
                char = String.fromCharCode(i)
                assertTrue("#{cl} failed to match character #{i} (0x#{i.toString(16)}): #{char}", regex.test(char))
            
        assertCharCodeFalse = (cl, charCodeRange) ->
            for i in charCodeRange
                char = String.fromCharCode(i)
                assertFalse("#{cl} erroneously match character #{i} (0x#{i.toString(16)}): #{char}", regex.test(char))
            
        regex = new Regex("^\\d$")
        assertCharCodeFalse("\\d", [0..47])
        assertCharCodeTrue("\\d", [48..57]) # digits 0 to 9
        assertCharCodeFalse("\\d", [58..0xffff])
        
        regex = new Regex("^\\D$")
        assertFalse(regex.test(""))
        assertCharCodeTrue("\\D", [0..47])
        assertCharCodeFalse("\\D", [48..57]) # digits 0 to 9
        assertCharCodeTrue("\\D", [58..0xffff])
            
        regex = new Regex("^\\w$")
        assertCharCodeFalse("\\w", [0..47])
        assertCharCodeTrue("\\w", [48..57]) # digits 0 to 9
        assertCharCodeFalse("\\w", [58..64])
        assertCharCodeTrue("\\w", [65..90]) # letters A to Z
        assertCharCodeFalse("\\w", [91..94])
        assertCharCodeTrue("\\w", [95]) # "_"
        assertCharCodeFalse("\\w", [96]) # "`"
        assertCharCodeTrue("\\w", [97..122]) # letters a to z
        assertCharCodeFalse("\\w", [123..0xffff])
        
        regex = new Regex("^\\W$")
        assertFalse(regex.test(""))
        assertCharCodeTrue("\\W", [0..47])
        assertCharCodeFalse("\\W", [48..57]) # digits 0 to 9
        assertCharCodeTrue("\\W", [58..64])
        assertCharCodeFalse("\\W", [65..90]) # letters A to Z
        assertCharCodeTrue("\\W", [91..94])
        assertCharCodeFalse("\\W", [95]) # "_"
        assertCharCodeTrue("\\W", [96]) # "`"
        assertCharCodeFalse("\\W", [97..122]) # letters a to z
        assertCharCodeTrue("\\W", [123..0xffff])
        
        regex = new Regex("^\\s$")
        assertCharCodeFalse("\\s", [0x0..0x8])
        assertCharCodeTrue("\\s", [0x9..0xd]) # horizontal tab, line feed, vertical tab, form feed, carriage return
        assertCharCodeFalse("\\s", [0xe..0x1f])
        assertCharCodeTrue("\\s", [0x20]) # space
        assertCharCodeFalse("\\s", [0x21..0x9f])
        assertCharCodeTrue("\\s", [0xa0]) # no-break space
        assertCharCodeFalse("\\s", [0xa1..0x167f])
        assertCharCodeTrue("\\s", [0x1680]) # ogham space mark
        assertCharCodeFalse("\\s", [0x1681..0x180d])
        assertCharCodeTrue("\\s", [0x180e]) # mongolian vowel separator
        assertCharCodeFalse("\\s", [0x180f..0x1fff])
        assertCharCodeTrue("\\s", [0x2000..0x200a]) # several punctuation and typesetting related spaces
        assertCharCodeFalse("\\s", [0x200b..0x2027])
        assertCharCodeTrue("\\s", [0x2028..0x2029]) # Unicode line separator and paragraph separator
        assertCharCodeFalse("\\s", [0x202a..0x202e])
        assertCharCodeTrue("\\s", [0x202f]) # Narrow no-break space
        assertCharCodeFalse("\\s", [0x2030..0x205e])
        assertCharCodeTrue("\\s", [0x205f]) # Medium mathematical space
        assertCharCodeFalse("\\s", [0x2060..0x2fff])
        assertCharCodeTrue("\\s", [0x3000]) # Ideographic space
        assertCharCodeFalse("\\s", [0x3001..0xfefe])
        assertCharCodeTrue("\\s", [0xfeff]) # Zero-width no-break space
        assertCharCodeFalse("\\s", [0xff00..0xffff])
        
        regex = new Regex("^\\S$")
        assertCharCodeTrue("\\S", [0x0..0x8])
        assertCharCodeFalse("\\S", [0x9..0xd]) # horizontal tab, line feed, vertical tab, form feed, carriage return
        assertCharCodeTrue("\S", [0xe..0x1f])
        assertCharCodeFalse("\\S", [0x20]) # space
        assertCharCodeTrue("\S", [0x21..0x9f])
        assertCharCodeFalse("\\S", [0xa0]) # no-break space
        assertCharCodeTrue("\\S", [0xa1..0x167f])
        assertCharCodeFalse("\\S", [0x1680]) # ogham space mark
        assertCharCodeTrue("\\S", [0x1681..0x180d])
        assertCharCodeFalse("\\S", [0x180e]) # mongolian vowel separator
        assertCharCodeTrue("\\S", [0x180f..0x1fff])
        assertCharCodeFalse("\\S", [0x2000..0x200a]) # several punctuation and typesetting related spaces
        assertCharCodeTrue("\\S", [0x200b..0x2027])
        assertCharCodeFalse("\\S", [0x2028..0x2029]) # Unicode line separator and paragraph separator
        assertCharCodeTrue("\\S", [0x202a..0x202e])
        assertCharCodeFalse("\\S", [0x202f]) # Narrow no-break space
        assertCharCodeTrue("\\S", [0x2030..0x205e])
        assertCharCodeFalse("\\S", [0x205f]) # Medium mathematical space
        assertCharCodeTrue("\\S", [0x2060..0x2fff])
        assertCharCodeFalse("\\S", [0x3000]) # Ideographic space
        assertCharCodeTrue("\\S", [0x3001..0xfefe])
        assertCharCodeFalse("\\S", [0xfeff]) # Zero-width no-break space
        assertCharCodeTrue("\\S", [0xff00..0xffff])
        
    "testNestedCharacterClass": () ->
        assertCharCodeTrue = (cl, charCodeRange) ->
            for i in charCodeRange
                char = String.fromCharCode(i)
                assertTrue("#{cl} failed to match character #{i} (0x#{i.toString(16)}): #{char}", regex.test(char))
            
        assertCharCodeFalse = (cl, charCodeRange) ->
            for i in charCodeRange
                char = String.fromCharCode(i)
                assertFalse("#{cl} erroneously match character #{i} (0x#{i.toString(16)}): #{char}", regex.test(char))
            
        regex = new Regex("^[\\d]$")
        assertCharCodeFalse("[\\d]", [0..47])
        assertCharCodeTrue("[\\d]", [48..57]) # digits 0 to 9
        assertCharCodeFalse("[\\d]", [58..0xffff])
        
        regex = new Regex("^[\\D]$")
        assertFalse(regex.test(""))
        assertCharCodeTrue("[\\D]", [0..47])
        assertCharCodeFalse("[\\D]", [48..57]) # digits 0 to 9
        assertCharCodeTrue("[\\D]", [58..0xffff])
            
        regex = new Regex("^[^\\D]$")
        assertCharCodeFalse("[^\\D]", [0..47])
        assertCharCodeTrue("[^\\D]", [48..57]) # digits 0 to 9
        assertCharCodeFalse("[^\\D]", [58..0xffff])
        
        regex = new Regex("^[^\\d]$")
        assertFalse(regex.test(""))
        assertCharCodeTrue("[^\\d]", [0..47])
        assertCharCodeFalse("[^\\d]", [48..57]) # digits 0 to 9
        assertCharCodeTrue("[^\\d]", [58..0xffff])
        
        regex = new Regex("^[\\s\\S]$")
        assertFalse(regex.test(""))
        assertCharCodeTrue("[\\s\\S]", [0..0xffff])
        
        regex = new Regex("^[^\\s\\S]$")
        assertFalse(regex.test(""))
        assertCharCodeFalse("[^\\s\\S]", [0..0xffff])
        
)