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
      state.tokens[this.debug.id].subtokenFailed = false;
      return state.tokens[this.debug.id].pos = [];
    };

    Sequence.prototype.setupStateObject = function() {
      return {
        status: Inactive,
        i: 0,
        pos: [],
        subtokenFailed: false
      };
    };

    Sequence.prototype.nextMatch = function(state) {
      var currentToken, result, tokenState;
      tokenState = state.tokens[this.debug.id];
      if (tokenState.subtokenFailed) {
        this.subtokens[tokenState.i].reset(state);
        --tokenState.i;
        if (tokenState.pos.length > 0) {
          state.currentPosition = tokenState.pos.pop();
        }
        tokenState.subtokenFailed = false;
        return Result.Indeterminate();
      }
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
          tokenState.subtokenFailed = true;
          return Result.Indeterminate();
        case Indeterminate:
          return result;
        case Success:
          if (tokenState.i === this.subtokens.length - 1) {
            tokenState.wasFinal = true;
            return result;
          } else {
            tokenState.pos.push(state.currentPosition);
            state.currentPosition = result.nextPosition;
            ++tokenState.i;
            return Result.Indeterminate();
          }
      }
    };

    return Sequence;

  })(Token);

}).call(this);
