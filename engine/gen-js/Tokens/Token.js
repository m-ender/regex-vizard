// Generated by CoffeeScript 1.4.0
(function() {
  var root;

  root = typeof global !== "undefined" && global !== null ? global : window;

  root.Token = (function() {

    function Token(debug, token) {
      this.debug = debug;
      this.subtokens = [];
      if (token && token instanceof Token) {
        this.subtokens.push(token);
      }
    }

    Token.prototype.reset = function(state) {
      var subtoken, _i, _len, _ref, _results;
      _ref = this.subtokens;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        subtoken = _ref[_i];
        _results.push(subtoken.reset(state));
      }
      return _results;
    };

    Token.prototype.register = function(state) {
      var subtoken, _i, _len, _ref;
      _ref = this.subtokens;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        subtoken = _ref[_i];
        subtoken.register(state);
      }
      return state.tokens[this.debug.id] = this.setupStateObject(state);
    };

    Token.prototype.setupStateObject = function() {
      return {};
    };

    Token.prototype.nextMatch = function(state) {
      return false;
    };

    return Token;

  })();

}).call(this);
