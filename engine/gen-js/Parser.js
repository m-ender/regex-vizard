// Generated by CoffeeScript 1.4.0
(function() {
  var root;

  root = typeof global !== "undefined" && global !== null ? global : window;

  root.Parser = (function() {

    function Parser() {}

    Parser.parsePattern = function(string) {
      var char, current, debug, element, fillGroupRanges, group, i, lastCaptureIndex, lastId, nGroups, nestingStack, squash, start, treeRoot, _, _ref, _ref1;
      lastId = -1;
      treeRoot = new Group({
        sourceOpen: '',
        sourceClose: '',
        id: ++lastId
      }, new Disjunction({
        id: ++lastId
      }, new Sequence({
        id: ++lastId
      })), 0);
      nestingStack = [];
      current = treeRoot.subtokens[0];
      i = 0;
      lastCaptureIndex = 0;
      while (i < string.length) {
        char = string.charAt(i);
        switch (char) {
          case "\\":
            start = i;
            _ref = this.parseEscapeSequence(false, string, i + 1), i = _ref[0], element = _ref[1];
            element.debug = {
              source: string.substring(start, i),
              id: ++lastId
            };
            this.append(current, element);
            break;
          case "[":
            i = this.parseCharacterClass(string, current, i + 1, ++lastId);
            break;
          case "^":
            debug = {
              source: char,
              id: ++lastId
            };
            this.append(current, new StartAnchor(debug));
            ++i;
            break;
          case "$":
            debug = {
              source: char,
              id: ++lastId
            };
            this.append(current, new EndAnchor(debug));
            ++i;
            break;
          case ".":
            debug = {
              source: char,
              id: ++lastId
            };
            this.append(current, new Wildcard(debug));
            ++i;
            break;
          case "|":
            current.subtokens.push(new Sequence({
              id: ++lastId
            }));
            ++i;
            break;
          case "(":
            debug = {
              sourceOpen: '(',
              sourceClose: ')',
              id: ++lastId
            };
            group = new Group(debug, new Disjunction({
              id: ++lastId
            }, new Sequence({
              id: ++lastId
            })), ++lastCaptureIndex);
            this.append(current, group);
            nestingStack.push(current);
            current = group.subtokens[0];
            ++i;
            break;
          case ")":
            if (nestingStack.length === 0) {
              throw {
                name: "UnmatchedClosingParenthesisException",
                message: "Unmatched closing parenthesis \")\" at index " + i,
                index: i
              };
            }
            current = nestingStack.pop();
            ++i;
            break;
          case "?":
          case "*":
          case "+":
            i = this.parseQuantifier(current, char, i, ++lastId);
            break;
          default:
            debug = {
              source: char,
              id: ++lastId
            };
            this.append(current, new Character(debug, char));
            ++i;
        }
      }
      if (nestingStack.length !== 0) {
        throw {
          name: "MissingClosingParenthesisException",
          message: "Missing closing parenthesis \")\""
        };
      }
      squash = function(token) {
        var subtoken, _i, _ref1, _results;
        if (token.subtokens.length === 0) {
          return;
        }
        _results = [];
        for (i = _i = 0, _ref1 = token.subtokens.length - 1; 0 <= _ref1 ? _i <= _ref1 : _i >= _ref1; i = 0 <= _ref1 ? ++_i : --_i) {
          subtoken = token.subtokens[i];
          while (((subtoken instanceof Disjunction) || (subtoken instanceof Sequence)) && (subtoken.subtokens.length === 1)) {
            token.subtokens[i] = subtoken.subtokens[0];
            subtoken = token.subtokens[i];
          }
          _results.push(squash(subtoken));
        }
        return _results;
      };
      squash(treeRoot);
      fillGroupRanges = function(token) {
        var max, min, subMax, subMin, subtoken, _i, _len, _ref1, _ref2;
        if (token instanceof Group) {
          min = token.index;
          max = token.index;
        } else {
          min = Infinity;
          max = -Infinity;
        }
        if (token.subtokens.length > 0) {
          _ref1 = token.subtokens;
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            subtoken = _ref1[_i];
            _ref2 = fillGroupRanges(subtoken), subMin = _ref2[0], subMax = _ref2[1];
            min = Math.min(min, subMin);
            max = Math.max(max, subMax);
          }
        }
        if (token instanceof Quantifier && min < Infinity && max > -Infinity) {
          token.setGroupRange(min, max - min + 1);
        }
        return [min, max];
      };
      _ref1 = fillGroupRanges(treeRoot), _ = _ref1[0], nGroups = _ref1[1];
      return [treeRoot, nGroups];
    };

    Parser.parseCharacterClass = function(string, current, i, id) {
      var char, debug, element, elements, endC, lastElement, negated, newI, nextElement, start, startC, _ref, _ref1;
      if (i < string.length && string.charAt(i) === "^") {
        negated = true;
        ++i;
      } else {
        negated = false;
      }
      elements = [];
      start = i;
      while (i < string.length) {
        char = string.charAt(i);
        switch (char) {
          case "]":
            debug = {
              sourceOpen: negated ? '[^' : '[',
              sourceClose: string.substring(start, i),
              sourceCloseLength: ']',
              id: id
            };
            this.append(current, new CharacterClass(debug, negated, elements));
            return i + 1;
          case "\\":
            _ref = this.parseEscapeSequence(true, string, i + 1), i = _ref[0], element = _ref[1];
            elements.push(element);
            break;
          case "-":
            lastElement = elements[elements.length - 1];
            if (lastElement instanceof CharacterClass) {
              throw {
                name: "CharacterClassInRangeException",
                message: "Built-in character classes cannot be used in ranges"
              };
            }
            if (typeof lastElement === "string" && i + 1 < string.length && (nextElement = string.charAt(i + 1)) !== "]") {
              newI = i + 2;
              if (nextElement === "\\") {
                _ref1 = this.parseEscapeSequence(true, string, i + 2), newI = _ref1[0], nextElement = _ref1[1];
              }
              if (nextElement instanceof CharacterClass) {
                throw {
                  name: "CharacterClassInRangeException",
                  message: "Built-in character classes cannot be used in ranges"
                };
              }
              startC = lastElement.charCodeAt(0);
              endC = nextElement.charCodeAt(0);
              if (startC > endC) {
                throw {
                  name: "CharacterClassRangeOutOfOrderException",
                  message: "The character class \"" + lastElement + "\" to \"" + nextElement + "\" is out of order."
                };
              }
              elements.pop();
              elements.push(new CharacterRange(startC, endC));
              i = newI;
            } else {
              elements.push(char);
              ++i;
            }
            break;
          default:
            elements.push(char);
            ++i;
        }
      }
      throw {
        name: "UnterminatedCharacterClassException",
        message: "Missing closing bracket \"]\"",
        index: i
      };
    };

    Parser.parseEscapeSequence = function(inCharacterClass, string, i) {
      var char, element, negated;
      if (i === string.length) {
        throw {
          name: "NothingToEscapeException",
          message: "There is nothing to escape. Most likely, the pattern ends in a backslash \"\\\"",
          index: i - 1
        };
      }
      char = string.charAt(i);
      switch (char) {
        case "0":
          element = "\0";
          break;
        case "f":
          element = "\f";
          break;
        case "n":
          element = "\n";
          break;
        case "r":
          element = "\r";
          break;
        case "t":
          element = "\t";
          break;
        case "v":
          element = "\v";
          break;
        case "d":
        case "D":
          negated = char === "D";
          element = new DigitClass(null, negated);
          break;
        case "w":
        case "W":
          negated = char === "W";
          element = new WordClass(null, negated);
          break;
        case "s":
        case "S":
          negated = char === "S";
          element = new WhitespaceClass(null, negated);
          break;
        case "b":
          element = inCharacterClass ? "\b" : new WordBoundary(null, false);
          break;
        case "B":
          element = inCharacterClass ? "B" : new WordBoundary(null, true);
          break;
        default:
          element = char;
      }
      if (typeof element === "string" && !inCharacterClass) {
        element = new Character(null, element);
      }
      return [i + 1, element];
    };

    Parser.parseQuantifier = function(current, char, i, id) {
      var debug, quantifierClass, st, target;
      st = current.subtokens;
      if (st[st.length - 1].subtokens.length === 0) {
        throw {
          name: "NothingToRepeatException",
          message: "The is nothing to repeat for quantifier \"" + char + "\" at index " + i,
          index: i
        };
      }
      target = this.remove(current);
      if (!((target instanceof Group) || (target instanceof Character) || (target instanceof Wildcard) || (target instanceof CharacterClass))) {
        throw {
          name: "NothingToRepeatException",
          message: "The is nothing to repeat for quantifier \"" + char + "\" at index " + i + ". Only groups, characters and wildcard may be quantified.",
          index: i
        };
      }
      debug = {
        source: char,
        id: id
      };
      quantifierClass = {
        "*": RepeatZeroOrMore,
        "+": RepeatOneOrMore,
        "?": Option
      };
      this.append(current, new quantifierClass[char](debug, target));
      return i + 1;
    };

    Parser.append = function(current, token) {
      var st;
      st = current.subtokens;
      return st[st.length - 1].subtokens.push(token);
    };

    Parser.remove = function(current) {
      var st;
      st = current.subtokens;
      return st[st.length - 1].subtokens.pop();
    };

    return Parser;

  })();

}).call(this);
