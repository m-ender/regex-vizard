TestCase("ParsingTests",
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
        
        checkError = (pattern, exception) ->
            assertException(
                () -> that.RegexEngine.parsePattern(pattern)
                exception
            )
            
        checkError("\\", "NothingToEscapeException")
        checkError(")", "UnmatchedClosingParenthesisException")
        checkError("())", "UnmatchedClosingParenthesisException")
        checkError("(", "MissingClosingParenthesisException")
        checkError("()(", "MissingClosingParenthesisException")            
        checkError("(()", "MissingClosingParenthesisException")
        checkError("?", "NothingToRepeatException")
        checkError("a(?)", "NothingToRepeatException")
        checkError("a|?", "NothingToRepeatException")
        checkError("^?", "NothingToRepeatException")
        checkError("$?", "NothingToRepeatException")
)