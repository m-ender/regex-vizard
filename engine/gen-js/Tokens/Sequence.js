// Generated by CoffeeScript 1.4.0
(function() {
  var root,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  root = typeof global !== "undefined" && global !== null ? global : window;

  root.Sequence = (function(_super) {

    __extends(Sequence, _super);

    function Sequence(debug) {
      Sequence.__super__.constructor.call(this, debug);
    }

    Sequence.prototype.reset = function(state) {
      Sequence.__super__.reset.apply(this, arguments);
      state.tokens[this.debug.id].i = 0;
      return state.tokens[this.debug.id].pos = [];
    };

    Sequence.prototype.setupStateObject = function() {
      return {
        type: 'sequence',
        status: Inactive,
        i: 0,
        pos: []
      };
    };

    Sequence.prototype.nextMatch = function(state) {
      var currentToken, result, tokenState;
      tokenState = state.tokens[this.debug.id];
      if (tokenState.i === -1) {
        return Result.Failure();
      }
      if (this.subtokens.length === 0) {
        tokenState.i = -1;
        return Result.Success(state.currentPosition);
      }
      currentToken = this.subtokens[tokenState.i];
      result = currentToken.nextMatch(state);
      switch (result.type) {
        case Failure:
          currentToken.reset(state);
          --tokenState.i;
          if (tokenState.pos.length > 0) {
            state.currentPosition = tokenState.pos.pop();
          }
          return Result.Indeterminate();
        case Indeterminate:
          return result;
        case Success:
          if (tokenState.i === this.subtokens.length - 1) {
            return result;
          } else {
            ++tokenState.i;
            tokenState.pos.push(state.currentPosition);
            state.currentPosition = result.nextPosition;
            return Result.Indeterminate();
          }
      }
    };

    return Sequence;

  })(root.Token);

}).call(this);
