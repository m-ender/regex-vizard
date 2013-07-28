// Generated by CoffeeScript 1.4.0
(function() {
  var colGen, defaultColor, failedColor, matcher, pendingColor, regex, regexString, renderer, root, setupEngine, skipColor, stepForward, targetString;

  root = typeof global !== "undefined" && global !== null ? global : window;

  root.JQueryHelper = (function() {

    function JQueryHelper() {}

    JQueryHelper.addJQueryPlugins = function() {
      jQuery.fn.visible = function() {
        return this.css('visibility', 'visible');
      };
      jQuery.fn.invisible = function() {
        return this.css('visibility', 'hidden');
      };
      return jQuery.fn.toggleInvisibility = function() {
        return this.css('visibility', function(i, visibility) {
          if (visibility === 'visible') {
            return 'hidden';
          } else {
            return 'visible';
          }
        });
      };
    };

    return JQueryHelper;

  })();

  root = typeof global !== "undefined" && global !== null ? global : window;

  root.ColorGenerator = (function() {

    function ColorGenerator(baseColor) {
      if (baseColor == null) {
        baseColor = '#74DDF2';
      }
      this.baseColor = jQuery.Color(baseColor);
      this.i = 0;
    }

    ColorGenerator.prototype.nextColor = function(correctHue) {
      if (correctHue == null) {
        correctHue = true;
      }
      if (correctHue) {
        return this.baseColor.hue(this.correctHue(this.baseColor.hue() + this.phi * this.i++));
      } else {
        return this.baseColor.hue(this.baseColor.hue() + this.phi * this.i++);
      }
    };

    ColorGenerator.prototype.phi = 0.61803398874989484820 * 360;

    ColorGenerator.prototype.hueCorrection = [[5, 10], [45, 30], [70, 50], [94, 70], [100, 110], [115, 125], [148, 145], [177, 160], [179, 182], [185, 188], [225, 210], [255, 250]];

    ColorGenerator.prototype.correctHue = function(hue) {
      var lx, ly, newHue, pair, _i, _len, _ref;
      hue = hue * (256 / 360) % 255;
      lx = ly = 0;
      _ref = this.hueCorrection;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        pair = _ref[_i];
        if (hue === pair[0]) {
          return pair[1];
        } else if (hue < pair[0]) {
          newHue = ly + (pair[1] - ly) / (pair[0] - lx) * (hue - lx);
          return Math.floor(newHue * 360 / 256);
        }
        lx = pair[0];
        ly = pair[1];
      }
    };

    return ColorGenerator;

  })();

  root = typeof global !== "undefined" && global !== null ? global : window;

  defaultColor = jQuery.Color("white");

  skipColor = jQuery.Color("#888");

  pendingColor = defaultColor;

  failedColor = jQuery.Color("#f55");

  root.Renderer = (function() {

    function Renderer(regex, target) {
      var collect, token,
        _this = this;
      this.regex = regex;
      this.target = target;
      this.tokens = [];
      this.colGen = new ColorGenerator({
        hue: 180,
        saturation: 1,
        lightness: 0.7,
        alpha: 1
      });
      collect = function(token) {
        var id, subtoken, _i, _len, _ref, _results;
        id = token.debug.id;
        _this.tokens[id] = token;
        _ref = token.subtokens;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          subtoken = _ref[_i];
          _results.push(collect(subtoken));
        }
        return _results;
      };
      collect(this.regex.regex);
      this.colors = (function() {
        var _i, _len, _ref, _results;
        _ref = this.tokens;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          token = _ref[_i];
          _results.push(token != null ? this.getColorOf(token) : void 0);
        }
        return _results;
      }).call(this);
    }

    Renderer.prototype.getColorOf = function(token) {
      switch (false) {
        case !(token instanceof BasicToken):
          return this.colGen.nextColor(true);
        default:
          return defaultColor;
      }
    };

    Renderer.prototype.render = function(state) {
      var color, i, n, p, patternHtml, remainingTarget, skipTarget, targetHtml, token, _i, _len, _ref, _ref1;
      console.log(state);
      targetHtml = '';
      patternHtml = '';
      i = state.startingPosition - 1;
      skipTarget = this.target.substring(0, i);
      targetHtml += "<span style='color: " + (skipColor.toHexString()) + ";'>" + skipTarget + "</span>";
      _ref = this.tokens;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        token = _ref[_i];
        if (token == null) {
          continue;
        }
        switch (false) {
          case !(token instanceof Character):
            _ref1 = this.renderCharacter(state, token), n = _ref1[0], color = _ref1[1], p = _ref1[2];
            targetHtml += n > 0 ? "<span style='color: " + color + ";'>" + (this.target.substr(i, n)) + "</span>" : '';
            i += n;
            patternHtml += p;
        }
      }
      remainingTarget = this.target.substring(i);
      targetHtml += "<span style='color: " + (pendingColor.toHexString()) + "'>" + remainingTarget + "</span>";
      return [targetHtml, patternHtml];
    };

    Renderer.prototype.renderCharacter = function(state, token) {
      var color, id, n, source, tokenState;
      id = token.debug.id;
      source = token.debug.source;
      tokenState = state.tokens[id];
      switch (tokenState.status) {
        case Inactive:
          color = pendingColor.toHexString();
          n = 0;
          break;
        case Failed:
          color = failedColor.toHexString();
          n = 0;
          break;
        case Matched:
          color = this.colors[id].toHexString();
          n = 1;
      }
      return [n, color, "<span style='color: " + color + ";'>" + source + "</span>"];
    };

    return Renderer;

  })();

  regex = null;

  matcher = null;

  renderer = null;

  regexString = '';

  targetString = '';

  colGen = new ColorGenerator({
    hue: 180,
    saturation: 1,
    lightness: 0.7,
    alpha: 1
  });

  setupEngine = function() {
    regexString = $('#input-pattern').val();
    regex = new Regex(regexString);
    targetString = $('#input-target').val();
    matcher = regex.getMatcher(targetString);
    renderer = new Renderer(regex, targetString);
    $('#output-target').html(targetString);
    $('#output-pattern').html(regexString);
    return $('#button-step-fw').visible();
  };

  stepForward = function() {
    var highlight, length, patternHtml, result, s, startPos, targetHtml, _ref;
    s = matcher.subject;
    if (matcher.stepForward()) {
      if (matcher.state.tokens[0].status === Failed) {
        return stepForward();
      }
      _ref = renderer.render(matcher.state), targetHtml = _ref[0], patternHtml = _ref[1];
      $('#output-target').html(targetHtml);
      return $('#output-pattern').html(patternHtml);
    } else {
      $('#button-step-fw').invisible();
      if (matcher.success) {
        result = matcher.state;
        startPos = result.startingPosition - 1;
        length = result.captures[0].length;
        highlight = "<span style='color: #888;'>" + (s.substring(0, startPos)) + "<span class='match'>" + (s.substr(startPos, length)) + "</span>" + (s.substr(startPos + length)) + "</span>";
        $('#output-target').html(highlight);
        return $('#output-pattern').html("<span class='match'>" + regexString + "</span>");
      } else {
        return $('#output-target').html("<span class='nomatch'>" + s + "</span>");
      }
    }
  };

  $(document).ready(function() {
    JQueryHelper.addJQueryPlugins();
    $('#button-start').on('click', setupEngine);
    return $('#button-step-fw').on('click', stepForward);
  });

}).call(this);
