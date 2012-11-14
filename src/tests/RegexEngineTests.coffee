tests =
    

TestCase("RegexEngine Tests",
    setUp : () ->
        if typeof module != "undefined" && module.exports
            #On a server
            @RegexEngine = new require("RegexEngine").RegexEngine
        else
            #On a client
            @RegexEngine = new window.RegexEngine
            
    "testMatchSingleCharacter": () -> 
        assertTrue(@RegexEngine.match("a", "bar"))
)