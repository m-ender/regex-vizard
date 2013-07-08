// Generated by CoffeeScript 1.4.0
(function() {

  TestCase("TokenTests", {
    setUp: function() {
      if (typeof module !== "undefined" && module.exports) {
        return this.Matcher = require("Matcher").Matcher;
      } else {
        return this.Matcher = window.Matcher;
      }
    },
    "testCharacterToken": function() {
      var state, token;
      state = this.Matcher.setupInitialState("ab");
      token = new Character({
        id: 0
      }, "a");
      token.register(state);
      this.assertNextMatchSequence(token, state, [2]);
      state.currentPosition = 2;
      this.assertNextMatchSequence(token, state, []);
      state.currentPosition = 3;
      this.assertNextMatchSequence(token, state, []);
      state = this.Matcher.setupInitialState("ab");
      token = new Character({
        id: 0
      }, "b");
      token.register(state);
      this.assertNextMatchSequence(token, state, []);
      state.currentPosition = 2;
      this.assertNextMatchSequence(token, state, [3]);
      state.currentPosition = 3;
      return this.assertNextMatchSequence(token, state, []);
    },
    "testWildcardToken": function() {
      var state, token;
      state = this.Matcher.setupInitialState("a\nb\r");
      token = new Wildcard({
        id: 0
      });
      token.register(state);
      this.assertNextMatchSequence(token, state, [2]);
      state.currentPosition = 2;
      this.assertNextMatchSequence(token, state, []);
      state.currentPosition = 3;
      this.assertNextMatchSequence(token, state, [4]);
      state.currentPosition = 4;
      this.assertNextMatchSequence(token, state, []);
      state.currentPosition = 5;
      return this.assertNextMatchSequence(token, state, []);
    },
    "testStartAnchorToken": function() {
      var state, token;
      state = this.Matcher.setupInitialState("ab");
      token = new StartAnchor({
        id: 0
      });
      token.register(state);
      this.assertNextMatchSequence(token, state, [1]);
      state.currentPosition = 2;
      this.assertNextMatchSequence(token, state, []);
      state.currentPosition = 3;
      return this.assertNextMatchSequence(token, state, []);
    },
    "testEndAnchorToken": function() {
      var state, token;
      state = this.Matcher.setupInitialState("ab");
      token = new EndAnchor({
        id: 0
      });
      token.register(state);
      this.assertNextMatchSequence(token, state, []);
      state.currentPosition = 2;
      this.assertNextMatchSequence(token, state, []);
      state.currentPosition = 3;
      return this.assertNextMatchSequence(token, state, [3]);
    },
    "testDisjunctionToken": function() {
      var state, token;
      state = this.Matcher.setupInitialState("abc");
      token = new Disjunction({
        id: 0
      });
      token.subtokens.push(new Character({
        id: 1
      }, "a"));
      token.subtokens.push(new Character({
        id: 2
      }, "b"));
      token.subtokens.push(new Character({
        id: 3
      }, "c"));
      token.register(state);
      this.assertNextMatchSequence(token, state, [2, 0, 0, 0]);
      state.currentPosition = 2;
      this.assertNextMatchSequence(token, state, [0, 3, 0, 0]);
      state.currentPosition = 3;
      this.assertNextMatchSequence(token, state, [0, 0, 4, 0]);
      state.currentPosition = 4;
      return this.assertNextMatchSequence(token, state, [0, 0, 0]);
    },
    "testSequenceToken": function() {
      var state, token;
      state = this.Matcher.setupInitialState("abc");
      token = new Sequence({
        id: 0
      });
      token.subtokens.push(new Character({
        id: 1
      }, "a"));
      token.subtokens.push(new Character({
        id: 2
      }, "b"));
      token.subtokens.push(new Character({
        id: 3
      }, "c"));
      token.register(state);
      this.assertNextMatchSequence(token, state, [-1, -1, 4, 0, 0, 0]);
      state = this.Matcher.setupInitialState("abc");
      token = new Sequence({
        id: 0
      });
      token.subtokens.push(new Character({
        id: 1
      }, "a"));
      token.subtokens.push(new Option({
        id: 2
      }, new Character({
        id: 3
      }, "b")));
      token.subtokens.push(new Character({
        id: 4
      }, "b"));
      token.register(state);
      return this.assertNextMatchSequence(token, state, [-1, -1, -1, 0, 0, -1, 3, 0, 0, 0]);
    },
    "testEmptySequenceToken": function() {
      var state, token;
      state = this.Matcher.setupInitialState("");
      token = new Sequence({
        id: 0
      });
      token.register(state);
      this.assertNextMatchSequence(token, state, [1]);
      state = this.Matcher.setupInitialState("a");
      token.register(state);
      this.assertNextMatchSequence(token, state, [1]);
      state.currentPosition = 2;
      return this.assertNextMatchSequence(token, state, [2]);
    },
    "testOptionToken": function() {
      var state, token;
      state = this.Matcher.setupInitialState("ab");
      token = new Option({
        id: 0
      }, new Character({
        id: 1
      }, "a"));
      token.register(state);
      this.assertNextMatchSequence(token, state, [-1, 2, 0, 1]);
      state.currentPosition = 2;
      this.assertNextMatchSequence(token, state, [0, 2]);
      state.currentPosition = 3;
      return this.assertNextMatchSequence(token, state, [0, 3]);
    },
    "testGroupToken": function() {
      var state, token;
      state = this.Matcher.setupInitialState("a");
      token = new Group({
        id: 0
      }, new Option({
        id: 1
      }, new Character({
        id: 2
      }, "a")));
      token.register(state);
      return this.assertNextMatchSequence(token, state, [-1, -1, 2, 0, -1, 1, 0]);
    },
    "testRepeatZeroOrMoreToken": function() {
      var disjunction, state, token;
      state = this.Matcher.setupInitialState("aaab");
      token = new RepeatZeroOrMore({
        id: 0
      }, new Character({
        id: 1
      }, "a"));
      token.register(state);
      this.assertNextMatchSequence(token, state, [-1, -1, -1, 0, 4, 0, 3, 0, 2, 0, 1]);
      state.currentPosition = 4;
      this.assertNextMatchSequence(token, state, [0, 4]);
      state = this.Matcher.setupInitialState("ab");
      disjunction = new Disjunction({
        id: 0
      });
      disjunction.subtokens.push(new Character({
        id: 1
      }, "a"));
      disjunction.subtokens.push(new Character({
        id: 2
      }, "b"));
      token = new RepeatZeroOrMore({
        id: 3
      }, new Group({
        id: 4
      }, disjunction));
      token.register(state);
      return this.assertNextMatchSequence(token, state, [-1, -1, 0, -1, -1, 0, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 0, 1]);
    },
    "testRepeatOneOrMoreToken": function() {
      var disjunction, state, token;
      state = this.Matcher.setupInitialState("aaab");
      token = new RepeatOneOrMore({
        id: 0
      }, new Character({
        id: 1
      }, "a"));
      token.register(state);
      this.assertNextMatchSequence(token, state, [-1, -1, -1, 0, 4, 0, 3, 0, 2, 0, 0]);
      state.currentPosition = 4;
      this.assertNextMatchSequence(token, state, [0, 0]);
      state = this.Matcher.setupInitialState("ab");
      disjunction = new Disjunction({
        id: 0
      });
      disjunction.subtokens.push(new Character({
        id: 1
      }, "a"));
      disjunction.subtokens.push(new Character({
        id: 2
      }, "b"));
      token = new RepeatOneOrMore({
        id: 3
      }, new Group({
        id: 4
      }, disjunction));
      token.register(state);
      return this.assertNextMatchSequence(token, state, [-1, -1, 0, -1, -1, 0, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 0, 0]);
    },
    "testInfiniteLoop": function() {
      var state, token;
      state = this.Matcher.setupInitialState("b");
      token = new RepeatZeroOrMore({
        id: 0
      }, new RepeatZeroOrMore({
        id: 1
      }, new Character({
        id: 2
      }, "a")));
      token.register(state);
      this.assertNextMatchSequence(token, state, [0, 0, 1]);
      state = this.Matcher.setupInitialState("b");
      token = new RepeatOneOrMore({
        id: 0
      }, new Option({
        id: 1
      }, new Character({
        id: 2
      }, "a")));
      token.register(state);
      return this.assertNextMatchSequence(token, state, [0, -1, 0, 0, 1, 0, 0]);
    },
    "testBasicCharacterClass": function() {
      var state, token;
      state = this.Matcher.setupInitialState("abc");
      token = new CharacterClass({
        id: 0
      });
      token.addCharacter("a");
      token.addCharacter("c");
      token.register(state);
      this.assertNextMatchSequence(token, state, [2]);
      state.currentPosition = 2;
      this.assertNextMatchSequence(token, state, []);
      state.currentPosition = 3;
      return this.assertNextMatchSequence(token, state, [4]);
    },
    "testNegatedCharacterClass": function() {
      var state, token;
      state = this.Matcher.setupInitialState("abc");
      token = new CharacterClass({
        id: 0
      }, true);
      token.addCharacter("a");
      token.addCharacter("c");
      token.register(state);
      this.assertNextMatchSequence(token, state, []);
      state.currentPosition = 2;
      this.assertNextMatchSequence(token, state, [3]);
      state.currentPosition = 3;
      return this.assertNextMatchSequence(token, state, []);
    },
    "testCharacterClassRange": function() {
      var state, token;
      state = this.Matcher.setupInitialState("abcd");
      token = new CharacterClass({
        id: 0
      });
      token.addRange("a", "c");
      token.register(state);
      this.assertNextMatchSequence(token, state, [2]);
      state.currentPosition = 2;
      this.assertNextMatchSequence(token, state, [3]);
      state.currentPosition = 3;
      this.assertNextMatchSequence(token, state, [4]);
      state.currentPosition = 4;
      return this.assertNextMatchSequence(token, state, []);
    },
    "testNestedCharacterClass": function() {
      var state, token;
      state = this.Matcher.setupInitialState("0");
      token = new CharacterClass({
        id: 0
      }, false, [
        new DigitClass({
          id: 1
        })
      ]);
      token.register(state);
      return this.assertNextMatchSequence(token, state, [2]);
    },
    "testWordBoundary": function() {
      var state, token;
      state = this.Matcher.setupInitialState("a_0-b");
      token = new WordBoundary({
        id: 0
      });
      token.register(state);
      this.assertNextMatchSequence(token, state, [1]);
      state.currentPosition = 2;
      this.assertNextMatchSequence(token, state, []);
      state.currentPosition = 3;
      this.assertNextMatchSequence(token, state, []);
      state.currentPosition = 4;
      this.assertNextMatchSequence(token, state, [4]);
      state.currentPosition = 5;
      this.assertNextMatchSequence(token, state, [5]);
      state.currentPosition = 6;
      this.assertNextMatchSequence(token, state, [6]);
      state = this.Matcher.setupInitialState("");
      token.register(state);
      this.assertNextMatchSequence(token, state, []);
      state = this.Matcher.setupInitialState("-");
      token.register(state);
      this.assertNextMatchSequence(token, state, []);
      state.currentPosition = 2;
      this.assertNextMatchSequence(token, state, []);
      state = this.Matcher.setupInitialState("a_0-b");
      token = new WordBoundary({
        id: 0
      }, true);
      token.register(state);
      this.assertNextMatchSequence(token, state, []);
      state.currentPosition = 2;
      this.assertNextMatchSequence(token, state, [2]);
      state.currentPosition = 3;
      this.assertNextMatchSequence(token, state, [3]);
      state.currentPosition = 4;
      this.assertNextMatchSequence(token, state, []);
      state.currentPosition = 5;
      this.assertNextMatchSequence(token, state, []);
      state.currentPosition = 6;
      this.assertNextMatchSequence(token, state, []);
      state = this.Matcher.setupInitialState("");
      token.register(state);
      this.assertNextMatchSequence(token, state, [1]);
      state = this.Matcher.setupInitialState("-");
      token.register(state);
      this.assertNextMatchSequence(token, state, [1]);
      state.currentPosition = 2;
      return this.assertNextMatchSequence(token, state, [2]);
    },
    assertNextMatchSequence: function(token, state, sequence) {
      var expectedResult, i, step, _i, _j, _len, _results;
      _results = [];
      for (i = _i = 1; _i <= 2; i = ++_i) {
        step = 0;
        for (_j = 0, _len = sequence.length; _j < _len; _j++) {
          expectedResult = sequence[_j];
          assertSame("Assertion failed at step " + step + ":", expectedResult, token.nextMatch(state));
          ++step;
        }
        _results.push(assertSame(false, token.nextMatch(state)));
      }
      return _results;
    }
  });

}).call(this);
