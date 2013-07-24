TestCase("MatchingTests",
    # Asserts that the given character class matches all character codes given by the
    # array charCodeRange. The error message may be nonsense if the character codes
    # are not consecutive.
    assertCharCodeTrue: (cl, charCodeRange) ->
        regex = new Regex("^#{cl}*")
        charRange = (String.fromCharCode(i) for i in charCodeRange)
        m = regex.match charRange.join('')
        failedChar = charCodeRange[0] + m[0].length
        assertTrue("#{cl} failed to match character 0x#{failedChar.toString(16)}", m[0].length is charRange.length)

    # Asserts that the given character class matches none of the character codes
    # given by the array charCodeRange.
    assertCharCodeFalse: (cl, charCodeRange) ->
        regex = new Regex(cl)
        charRange = (String.fromCharCode(i) for i in charCodeRange)
        m = regex.match(charRange.join(''))
        char = (m?[0].charCodeAt 0) ? ""
        assertFalse("#{cl} erroneously matched character 0x#{char.toString(16)}", m?)

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
        assertEquals(null, regex.match("b"))
        assertEquals(["a"], regex.match("bar"))

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
        assertEquals(["ab"], regex.match("aabar"))

    "testAnchors": () ->
        regex = new Regex("^")
        assertTrue(regex.test("a"))
        assertEquals([""], regex.match("a"))
        regex = new Regex("$")
        assertTrue(regex.test("a"))
        assertEquals([""], regex.match("a"))
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
        assertEquals(["a"], regex.match("a"))
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
        assertEquals(["a"], regex.match("a"))
        regex = new Regex("..")
        assertTrue(regex.test("ab"))
        assertTrue(regex.test("cc"))
        assertEquals(["ab"], regex.match("ab"))
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
        assertEquals(["^"], regex.match("^"))

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
        assertEquals(["a"], regex.match("ab"))
        regex = new Regex("b|ab|a")
        assertEquals(["ab"], regex.match("ab"))
        regex = new Regex("b|a|ab")
        assertEquals(["a"], regex.match("ab"))

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
        assertEquals(["ab", "b", undefined], regex.match("ab"))
        regex = new Regex("^a(b|c(d|e))$")
        assertFalse(regex.test("abd"))
        assertFalse(regex.test("abe"))

    "testBacktracking": () ->
        regex = new Regex("(a|ab|abc)d")
        assertTrue(regex.test("ad"))
        assertTrue(regex.test("abd"))
        assertTrue(regex.test("abcd"))
        assertEquals(["abcd", "abc"], regex.match("abcd"))

    "testOption": () ->
        regex = new Regex("ab?c")
        assertTrue(regex.test("abc"))
        assertTrue(regex.test("ac"))
        regex = new Regex("ab?b")
        assertTrue(regex.test("ab"))
        regex = new Regex("a(bc)?d")
        assertTrue(regex.test("abcd"))
        assertTrue(regex.test("ad"))
        assertEquals(["abcd", "bc"], regex.match("abcd"))

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
        assertEquals(["abababbaabab", "b"], regex.match("abababbaabab"))

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
        assertEquals(["abababbaabab", "b"], regex.match("abababbaabab"))

    "testInfiniteLoop": () ->
        regex = new Regex("^(a*)*$")
        assertFalse(regex.test("b"))
        regex = new Regex("^(a?)+$")
        assertFalse(regex.test("b"))
        regex = new Regex("^(a|b|)*$")
        assertFalse(regex.test("abc"))
        regex = new Regex("(\b)*a")
        assertFalse(regex.test("b"))

    "testLeftMostMatch": () ->
        regex = new Regex("(a|b)")
        assertEquals(["a", "a"], regex.match("ab"))
        assertEquals(["b", "b"], regex.match("ba"))
        regex = new Regex("a*")
        assertEquals(["aa"], regex.match("aabaaa"))

    "testGreediness": () ->
        regex = new Regex("a?")
        assertEquals(["a"], regex.match("a"))
        assertEquals([""], regex.match("b"))
        assertEquals([""], regex.match("ba")) # due to left-most matching
        regex = new Regex("a*")
        assertEquals(["aaaaa"], regex.match("aaaaa"))
        assertEquals([""], regex.match("baaaaa"))
        regex = new Regex("a+")
        assertEquals(["aaaaa"], regex.match("aaaaa"))
        assertEquals(["aaaaa"], regex.match("baaaaa"))
        regex = new Regex("(a|b|bc|d)*c")
        assertEquals(["abc", "b"], regex.match("abcdc"))
        regex = new Regex("(a|bc|b|d)*c")
        assertEquals(["abcdc", "d"], regex.match("abcdc"))

    "testBasicCharacterClass": () ->
        regex = new Regex("[ac]")
        assertTrue(regex.test("a"))
        assertFalse(regex.test("b"))
        assertTrue(regex.test("c"))
        assertEquals(["a"], regex.match("ac"))

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
        assertEquals(["b"], regex.match("acbd"))

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
        assertEquals(["aca"], regex.match("bacaba"))

    "testBuiltInCharacterClasses": () ->
        @assertCharCodeFalse("\\d", [0..47])
        @assertCharCodeTrue("\\d", [48..57]) # digits 0 to 9
        @assertCharCodeFalse("\\d", [58..0xffff])

        assertFalse(new Regex("^\\D$").test(""))
        @assertCharCodeTrue("\\D", [0..47])
        @assertCharCodeFalse("\\D", [48..57]) # digits 0 to 9
        @assertCharCodeTrue("\\D", [58..0xffff])

        @assertCharCodeFalse("\\w", [0..47])
        @assertCharCodeTrue("\\w", [48..57]) # digits 0 to 9
        @assertCharCodeFalse("\\w", [58..64])
        @assertCharCodeTrue("\\w", [65..90]) # letters A to Z
        @assertCharCodeFalse("\\w", [91..94])
        @assertCharCodeTrue("\\w", [95]) # "_"
        @assertCharCodeFalse("\\w", [96]) # "`"
        @assertCharCodeTrue("\\w", [97..122]) # letters a to z
        @assertCharCodeFalse("\\w", [123..0xffff])

        assertFalse(new Regex("^\\W$").test(""))
        @assertCharCodeTrue("\\W", [0..47])
        @assertCharCodeFalse("\\W", [48..57]) # digits 0 to 9
        @assertCharCodeTrue("\\W", [58..64])
        @assertCharCodeFalse("\\W", [65..90]) # letters A to Z
        @assertCharCodeTrue("\\W", [91..94])
        @assertCharCodeFalse("\\W", [95]) # "_"
        @assertCharCodeTrue("\\W", [96]) # "`"
        @assertCharCodeFalse("\\W", [97..122]) # letters a to z
        @assertCharCodeTrue("\\W", [123..0xffff])

        @assertCharCodeFalse("\\s", [0x0..0x8])
        @assertCharCodeTrue("\\s", [0x9..0xd]) # horizontal tab, line feed, vertical tab, form feed, carriage return
        @assertCharCodeFalse("\\s", [0xe..0x1f])
        @assertCharCodeTrue("\\s", [0x20]) # space
        @assertCharCodeFalse("\\s", [0x21..0x9f])
        @assertCharCodeTrue("\\s", [0xa0]) # no-break space
        @assertCharCodeFalse("\\s", [0xa1..0x167f])
        @assertCharCodeTrue("\\s", [0x1680]) # ogham space mark
        @assertCharCodeFalse("\\s", [0x1681..0x180d])
        @assertCharCodeTrue("\\s", [0x180e]) # mongolian vowel separator
        @assertCharCodeFalse("\\s", [0x180f..0x1fff])
        @assertCharCodeTrue("\\s", [0x2000..0x200a]) # several punctuation and typesetting related spaces
        @assertCharCodeFalse("\\s", [0x200b..0x2027])
        @assertCharCodeTrue("\\s", [0x2028..0x2029]) # Unicode line separator and paragraph separator
        @assertCharCodeFalse("\\s", [0x202a..0x202e])
        @assertCharCodeTrue("\\s", [0x202f]) # Narrow no-break space
        @assertCharCodeFalse("\\s", [0x2030..0x205e])
        @assertCharCodeTrue("\\s", [0x205f]) # Medium mathematical space
        @assertCharCodeFalse("\\s", [0x2060..0x2fff])
        @assertCharCodeTrue("\\s", [0x3000]) # Ideographic space
        @assertCharCodeFalse("\\s", [0x3001..0xfefe])
        @assertCharCodeTrue("\\s", [0xfeff]) # Zero-width no-break space
        @assertCharCodeFalse("\\s", [0xff00..0xffff])

        assertFalse(new Regex("^\\S$").test(""))
        @assertCharCodeTrue("\\S", [0x0..0x8])
        @assertCharCodeFalse("\\S", [0x9..0xd]) # horizontal tab, line feed, vertical tab, form feed, carriage return
        @assertCharCodeTrue("\\S", [0xe..0x1f])
        @assertCharCodeFalse("\\S", [0x20]) # space
        @assertCharCodeTrue("\\S", [0x21..0x9f])
        @assertCharCodeFalse("\\S", [0xa0]) # no-break space
        @assertCharCodeTrue("\\S", [0xa1..0x167f])
        @assertCharCodeFalse("\\S", [0x1680]) # ogham space mark
        @assertCharCodeTrue("\\S", [0x1681..0x180d])
        @assertCharCodeFalse("\\S", [0x180e]) # mongolian vowel separator
        @assertCharCodeTrue("\\S", [0x180f..0x1fff])
        @assertCharCodeFalse("\\S", [0x2000..0x200a]) # several punctuation and typesetting related spaces
        @assertCharCodeTrue("\\S", [0x200b..0x2027])
        @assertCharCodeFalse("\\S", [0x2028..0x2029]) # Unicode line separator and paragraph separator
        @assertCharCodeTrue("\\S", [0x202a..0x202e])
        @assertCharCodeFalse("\\S", [0x202f]) # Narrow no-break space
        @assertCharCodeTrue("\\S", [0x2030..0x205e])
        @assertCharCodeFalse("\\S", [0x205f]) # Medium mathematical space
        @assertCharCodeTrue("\\S", [0x2060..0x2fff])
        @assertCharCodeFalse("\\S", [0x3000]) # Ideographic space
        @assertCharCodeTrue("\\S", [0x3001..0xfefe])
        @assertCharCodeFalse("\\S", [0xfeff]) # Zero-width no-break space
        @assertCharCodeTrue("\\S", [0xff00..0xffff])

    "testNestedCharacterClass": () ->
        @assertCharCodeFalse("[\\d]", [0..47])
        @assertCharCodeTrue("[\\d]", [48..57]) # digits 0 to 9
        @assertCharCodeFalse("[\\d]", [58..0xffff])

        assertFalse(new Regex("^[\\D]$").test(""))
        @assertCharCodeTrue("[\\D]", [0..47])
        @assertCharCodeFalse("[\\D]", [48..57]) # digits 0 to 9
        @assertCharCodeTrue("[\\D]", [58..0xffff])

        @assertCharCodeFalse("[^\\D]", [0..47])
        @assertCharCodeTrue("[^\\D]", [48..57]) # digits 0 to 9
        @assertCharCodeFalse("[^\\D]", [58..0xffff])

        assertFalse(new Regex("^[^\\d]$").test(""))
        @assertCharCodeTrue("[^\\d]", [0..47])
        @assertCharCodeFalse("[^\\d]", [48..57]) # digits 0 to 9
        @assertCharCodeTrue("[^\\d]", [58..0xffff])

        assertFalse(new Regex("^[\\s\\S]$").test(""))
        @assertCharCodeTrue("[\\s\\S]", [0..0xffff])

        assertFalse(new Regex("^[^\\s\\S]$").test(""))
        @assertCharCodeFalse("[^\\s\\S]", [0..0xffff])

    "testWordBoundary": () ->
        regex = new Regex("\\b")
        assertFalse(regex.test(""))
        assertTrue(regex.test("a"))
        assertTrue(regex.test("0"))
        assertTrue(regex.test("_"))
        assertFalse(regex.test(" "))
        assertFalse(regex.test("-"))

        regex = new Regex("\\bfoo\\b")
        assertTrue(regex.test("foo"))
        assertTrue(regex.test("-foo"))
        assertTrue(regex.test("foo-"))
        assertTrue(regex.test("-foo-"))
        assertFalse(regex.test("_foo"))
        assertFalse(regex.test("foo_"))
        assertFalse(regex.test("_foo_"))
        assertFalse(regex.test("afoo"))
        assertFalse(regex.test("fooa"))
        assertFalse(regex.test("afooa"))
        assertFalse(regex.test("0foo"))
        assertFalse(regex.test("foo0"))
        assertFalse(regex.test("0foo0"))

        regex = new Regex("\\B")
        assertTrue(regex.test(""))
        assertFalse(regex.test("a"))
        assertFalse(regex.test("0"))
        assertFalse(regex.test("_"))
        assertTrue(regex.test(" "))
        assertTrue(regex.test("-"))

        regex = new Regex("\\Bfoo\\B")
        assertFalse(regex.test("foo"))
        assertFalse(regex.test("-foo"))
        assertFalse(regex.test("foo-"))
        assertFalse(regex.test("-foo-"))
        assertFalse(regex.test("_foo"))
        assertFalse(regex.test("foo_"))
        assertTrue(regex.test("_foo_"))
        assertFalse(regex.test("afoo"))
        assertFalse(regex.test("fooa"))
        assertTrue(regex.test("afooa"))
        assertFalse(regex.test("0foo"))
        assertFalse(regex.test("foo0"))
        assertTrue(regex.test("0foo0"))

    "testCapturing": () ->
        # The following three test cases are taken straight from the ECMAScript standard's notes on capturing
        # and backtracking.
        regex = new Regex("((a)|(ab))((c)|(bc))")
        assertEquals(["abc", "a", "a", undefined, "bc", undefined, "bc"], regex.match("abc"))
        regex = new Regex("(z)((a+)?(b+)?(c))*")
        assertEquals(["zaacbbbcac", "z", "ac", "a", undefined, "c"], regex.match("zaacbbbcac"))
        regex = new Regex("(aa|aabaac|ba|b|c)*")
        assertEquals(["aaba", "ba"], regex.match("aabaac"))
)
