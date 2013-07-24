// Generated by CoffeeScript 1.4.0
(function() {
  var root,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  root = typeof global !== "undefined" && global !== null ? global : window;

  root.Character = (function(_super) {

    __extends(Character, _super);

    function Character(debug, character) {
      this.character = character;
      Character.__super__.constructor.call(this, debug);
    }

    Character.prototype.reset = function(state) {
      Character.__super__.reset.apply(this, arguments);
      state.tokens[this.debug.id].status = Inactive;
      return state.tokens[this.debug.id].attempted = false;
    };

    Character.prototype.setupStateObject = function() {
      return {
        type: 'character',
        status: Inactive,
        attempted: false
      };
    };

    Character.prototype.nextMatch = function(state) {
      var tokenState;
      tokenState = state.tokens[this.debug.id];
      if (tokenState.attempted) {
        return Result.Failure();
      }
      tokenState.attempted = true;
      if (state.input[state.currentPosition] === this.character) {
        tokenState.status = Matched;
        return Result.Success(state.currentPosition + 1);
      } else {
        tokenState.status = Failed;
        return Result.Failure();
      }
    };

    return Character;

  })(root.Token);

}).call(this);
