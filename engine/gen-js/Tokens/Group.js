// Generated by CoffeeScript 1.4.0
(function() {
  var root,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  root = typeof global !== "undefined" && global !== null ? global : window;

  root.Group = (function(_super) {

    __extends(Group, _super);

    function Group(debug, token, index) {
      this.index = index;
      Group.__super__.constructor.call(this, debug, token);
    }

    Group.prototype.reset = function(state) {
      Group.__super__.reset.apply(this, arguments);
      state.tokens[this.debug.id].result = 0;
      return state.tokens[this.debug.id].firstPosition = false;
    };

    Group.prototype.setupStateObject = function() {
      return {
        result: 0,
        firstPosition: false
      };
    };

    Group.prototype.register = function(state) {
      state.captures[this.index] = void 0;
      return Group.__super__.register.apply(this, arguments);
    };

    Group.prototype.nextMatch = function(state) {
      var result, tokenState;
      tokenState = state.tokens[this.debug.id];
      if (tokenState.result !== 0) {
        result = tokenState.result;
        if (result === false) {
          this.reset(state);
        } else {
          tokenState.result = 0;
        }
        return result;
      }
      if (tokenState.firstPosition === false) {
        tokenState.firstPosition = state.currentPosition;
      }
      result = this.subtokens[0].nextMatch(state);
      switch (result) {
        case 0:
        case -1:
          return result;
        case false:
          tokenState.result = false;
          state.captures[this.index] = void 0;
          return 0;
        default:
          state.captures[this.index] = state.input.slice(tokenState.firstPosition, result).join("");
          tokenState.result = result;
          return -1;
      }
    };

    return Group;

  })(root.Token);

}).call(this);
