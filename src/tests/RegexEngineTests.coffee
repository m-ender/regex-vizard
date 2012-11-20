TestCase("RegexEngine Tests",
    setUp : () ->
        if typeof module != "undefined" && module.exports
            #On a server
            @RegexEngine = new require("RegexEngine").RegexEngine
        else
            #On a client
            @RegexEngine = new window.RegexEngine
            
    "testMatchSingleCharacter": () -> 
        assertTrue(@RegexEngine.match("a", "a"))
        assertTrue(@RegexEngine.match("a", "bar"))
        assertTrue(@RegexEngine.match("a", "bra"))
        assertTrue(@RegexEngine.match("a", "abra"))
        assertFalse(@RegexEngine.match("a", "b"))

    "testMatchMultipleCharacters": () ->
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
)