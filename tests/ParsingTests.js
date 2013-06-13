// Generated by CoffeeScript 1.4.0
(function() {

  TestCase("ParsingTests", {
    setUp: function() {
      if (typeof module !== "undefined" && module.exports) {
        return this.Parser = new require("Parser").Parser;
      } else {
        return this.Parser = new window.Parser;
      }
    },
    "testCharacter": function() {
      var expectedTree, regex;
      regex = this.Parser.parsePattern("a");
      expectedTree = {
        type: Group,
        subtokens: [
          {
            type: Character,
            subtokens: []
          }
        ]
      };
      return this.assertSyntaxTree(expectedTree, regex);
    },
    "testEscapedMetacharacter": function() {
      var expectedTree, regex;
      regex = this.Parser.parsePattern("\\?");
      expectedTree = {
        type: Group,
        subtokens: [
          {
            type: Character,
            subtokens: []
          }
        ]
      };
      return this.assertSyntaxTree(expectedTree, regex);
    },
    "testEscapeSequence": function() {
      var expectedTree, regex;
      regex = this.Parser.parsePattern("\\n");
      expectedTree = {
        type: Group,
        subtokens: [
          {
            type: Character,
            subtokens: []
          }
        ]
      };
      return this.assertSyntaxTree(expectedTree, regex);
    },
    "testWildcard": function() {
      var expectedTree, regex;
      regex = this.Parser.parsePattern(".");
      expectedTree = {
        type: Group,
        subtokens: [
          {
            type: Wildcard,
            subtokens: []
          }
        ]
      };
      return this.assertSyntaxTree(expectedTree, regex);
    },
    "testStartAnchor": function() {
      var expectedTree, regex;
      regex = this.Parser.parsePattern("^");
      expectedTree = {
        type: Group,
        subtokens: [
          {
            type: StartAnchor,
            subtokens: []
          }
        ]
      };
      return this.assertSyntaxTree(expectedTree, regex);
    },
    "testEndAnchor": function() {
      var expectedTree, regex;
      regex = this.Parser.parsePattern("$");
      expectedTree = {
        type: Group,
        subtokens: [
          {
            type: EndAnchor,
            subtokens: []
          }
        ]
      };
      return this.assertSyntaxTree(expectedTree, regex);
    },
    "testSequence": function() {
      var expectedTree, regex;
      regex = this.Parser.parsePattern("abc");
      expectedTree = {
        type: Group,
        subtokens: [
          {
            type: Sequence,
            subtokens: [
              {
                type: Character,
                subtokens: []
              }, {
                type: Character,
                subtokens: []
              }, {
                type: Character,
                subtokens: []
              }
            ]
          }
        ]
      };
      return this.assertSyntaxTree(expectedTree, regex);
    },
    "testDisjunction": function() {
      var expectedTree, regex;
      regex = this.Parser.parsePattern("a|b|c");
      expectedTree = {
        type: Group,
        subtokens: [
          {
            type: Disjunction,
            subtokens: [
              {
                type: Character,
                subtokens: []
              }, {
                type: Character,
                subtokens: []
              }, {
                type: Character,
                subtokens: []
              }
            ]
          }
        ]
      };
      return this.assertSyntaxTree(expectedTree, regex);
    },
    "testOption": function() {
      var expectedTree, regex;
      regex = this.Parser.parsePattern("a?");
      expectedTree = {
        type: Group,
        subtokens: [
          {
            type: Option,
            subtokens: [
              {
                type: Character,
                subtokens: []
              }
            ]
          }
        ]
      };
      return this.assertSyntaxTree(expectedTree, regex);
    },
    "testRepeatZeroOrMore": function() {
      var expectedTree, regex;
      regex = this.Parser.parsePattern("a*");
      expectedTree = {
        type: Group,
        subtokens: [
          {
            type: RepeatZeroOrMore,
            subtokens: [
              {
                type: Character,
                subtokens: []
              }
            ]
          }
        ]
      };
      return this.assertSyntaxTree(expectedTree, regex);
    },
    "testRepeatOneOrMore": function() {
      var expectedTree, regex;
      regex = this.Parser.parsePattern("a+");
      expectedTree = {
        type: Group,
        subtokens: [
          {
            type: RepeatOneOrMore,
            subtokens: [
              {
                type: Character,
                subtokens: []
              }
            ]
          }
        ]
      };
      return this.assertSyntaxTree(expectedTree, regex);
    },
    "testGroup": function() {
      var expectedTree, regex;
      regex = this.Parser.parsePattern("(a)");
      expectedTree = {
        type: Group,
        subtokens: [
          {
            type: Group,
            subtokens: [
              {
                type: Character,
                subtokens: []
              }
            ]
          }
        ]
      };
      return this.assertSyntaxTree(expectedTree, regex);
    },
    "testCharacterClass": function() {
      var expectedTree, regex;
      expectedTree = {
        type: Group,
        subtokens: [
          {
            type: CharacterClass,
            subtokens: []
          }
        ]
      };
      regex = this.Parser.parsePattern("[]");
      this.assertSyntaxTree(expectedTree, regex);
      regex = this.Parser.parsePattern("[a]");
      this.assertSyntaxTree(expectedTree, regex);
      regex = this.Parser.parsePattern("[abc]");
      this.assertSyntaxTree(expectedTree, regex);
      regex = this.Parser.parsePattern("[^]");
      this.assertSyntaxTree(expectedTree, regex);
      regex = this.Parser.parsePattern("[^abc]");
      this.assertSyntaxTree(expectedTree, regex);
      regex = this.Parser.parsePattern("[a-c]");
      this.assertSyntaxTree(expectedTree, regex);
      regex = this.Parser.parsePattern("[a\\]c]");
      return this.assertSyntaxTree(expectedTree, regex);
    },
    "testWordBoundary": function() {
      var expectedTree, regex;
      regex = this.Parser.parsePattern("\\b");
      expectedTree = {
        type: Group,
        subtokens: [
          {
            type: WordBoundary,
            subtokens: []
          }
        ]
      };
      this.assertSyntaxTree(expectedTree, regex);
      regex = this.Parser.parsePattern("\\B");
      return this.assertSyntaxTree(expectedTree, regex);
    },
    "testComplexExpression": function() {
      var expectedTree, regex;
      regex = this.Parser.parsePattern("d.(a[be]?|c|)*$");
      console.log(regex);
      expectedTree = {
        type: Group,
        subtokens: [
          {
            type: Sequence,
            subtokens: [
              {
                type: Character,
                subtokens: []
              }, {
                type: Wildcard,
                subtokens: []
              }, {
                type: RepeatZeroOrMore,
                subtokens: [
                  {
                    type: Group,
                    subtokens: [
                      {
                        type: Disjunction,
                        subtokens: [
                          {
                            type: Sequence,
                            subtokens: [
                              {
                                type: Character,
                                subtokens: []
                              }, {
                                type: Option,
                                subtokens: [
                                  {
                                    type: CharacterClass,
                                    subtokens: []
                                  }
                                ]
                              }
                            ]
                          }, {
                            type: Character,
                            subtokens: []
                          }, {
                            type: Sequence,
                            subtokens: []
                          }
                        ]
                      }
                    ]
                  }
                ]
              }, {
                type: EndAnchor,
                subtokens: []
              }
            ]
          }
        ]
      };
      return this.assertSyntaxTree(expectedTree, regex);
    },
    "testInvalidSyntax": function() {
      var assertParsingException, that;
      that = this;
      assertParsingException = function(pattern, exception) {
        return assertException(function() {
          return that.Parser.parsePattern(pattern);
        }, exception);
      };
      assertParsingException("\\", "NothingToEscapeException");
      assertParsingException("[\\", "NothingToEscapeException");
      assertParsingException(")", "UnmatchedClosingParenthesisException");
      assertParsingException("())", "UnmatchedClosingParenthesisException");
      assertParsingException("(", "MissingClosingParenthesisException");
      assertParsingException("()(", "MissingClosingParenthesisException");
      assertParsingException("(()", "MissingClosingParenthesisException");
      assertParsingException("?", "NothingToRepeatException");
      assertParsingException("a(?)", "NothingToRepeatException");
      assertParsingException("a|?", "NothingToRepeatException");
      assertParsingException("^?", "NothingToRepeatException");
      assertParsingException("$?", "NothingToRepeatException");
      assertParsingException("*", "NothingToRepeatException");
      assertParsingException("a(*)", "NothingToRepeatException");
      assertParsingException("a|*", "NothingToRepeatException");
      assertParsingException("^*", "NothingToRepeatException");
      assertParsingException("$*", "NothingToRepeatException");
      assertParsingException("+", "NothingToRepeatException");
      assertParsingException("a(+)", "NothingToRepeatException");
      assertParsingException("a|+", "NothingToRepeatException");
      assertParsingException("^+", "NothingToRepeatException");
      assertParsingException("$+", "NothingToRepeatException");
      assertParsingException("[", "UnterminatedCharacterClassException");
      assertParsingException("[a", "UnterminatedCharacterClassException");
      assertParsingException("[\\]", "UnterminatedCharacterClassException");
      assertParsingException("[^", "UnterminatedCharacterClassException");
      assertParsingException("[b-a]", "CharacterClassRangeOutOfOrderException");
      assertParsingException("[\\d-a]", "CharacterClassInRangeException");
      return assertParsingException("[a-\\d]", "CharacterClassInRangeException");
    },
    assertSyntaxTree: function(expectedTree, actualTree) {
      var i, subtoken, _i, _len, _ref, _results;
      assertTrue(actualTree.constructor === expectedTree.type);
      assertEquals(expectedTree.subtokens.length, actualTree.subtokens.length);
      i = 0;
      _ref = expectedTree.subtokens;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        subtoken = _ref[_i];
        this.assertSyntaxTree(subtoken, actualTree.subtokens[i]);
        _results.push(++i);
      }
      return _results;
    }
  });

}).call(this);
