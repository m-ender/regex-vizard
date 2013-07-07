// Generated by CoffeeScript 1.4.0
(function() {
  var root;

  root = typeof global !== "undefined" && global !== null ? global : window;

  root.Matcher = (function() {

    function Matcher(regex, nGroups, subject) {
      this.regex = regex;
      this.startingPosition = 1;
      this.success = false;
      this.state = this.setupInitialState(subject, nGroups);
    }

    Matcher.prototype.setupInitialState = function(str, nGroups) {
      var i, state, _i;
      if (nGroups == null) {
        nGroups = 0;
      }
      state = {
        inputString: str,
        input: this.parseInput(str),
        currentPosition: 1,
        captures: []
      };
      for (i = _i = 0; 0 <= nGroups ? _i <= nGroups : _i >= nGroups; i = 0 <= nGroups ? ++_i : --_i) {
        state.captures[i] = void 0;
      }
      return state;
    };

    Matcher.prototype.parseInput = function(inputString) {
      var input;
      input = [StartGuard].concat(inputString.split(""));
      input.push(EndGuard);
      return input;
    };

    Matcher.prototype.stepForward = function() {
      switch (this.regex.nextMatch(this.state, false)) {
        case false:
          this.state.currentPosition = ++this.startingPosition;
          return this.startingPosition < this.state.input.length;
        case 0:
        case -1:
          return true;
        default:
          this.success = true;
          return false;
      }
    };

    Matcher.prototype.group = function(n) {
      if (n == null) {
        n = 0;
      }
      return this.state.captures[n];
    };

    Matcher.prototype.groups = function() {
      return this.state.captures;
    };

    return Matcher;

  })();

}).call(this);