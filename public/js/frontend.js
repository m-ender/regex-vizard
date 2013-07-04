// Generated by CoffeeScript 1.4.0
(function() {
  var regex, root, setupEngine, stepForward, subjectString;

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

  regex = null;

  subjectString = '';

  setupEngine = function() {
    var regexString;
    regexString = $('#input-pattern').val();
    regex = new Regex(regexString);
    subjectString = $('#input-subject').val();
    $('#output-subject').html(subjectString);
    $('#output-pattern').html(regexString);
    return $('#button-step-fw').visible();
  };

  stepForward = function() {
    var result;
    result = regex.match(subjectString);
    $('#output-message').visible();
    if (result) {
      return $('#output-message').html("Match found: " + result[0]);
    } else {
      return $('#output-message').html("No match! :-(");
    }
  };

  $(document).ready(function() {
    JQueryHelper.addJQueryPlugins();
    $('#button-start').on('click', setupEngine);
    return $('#button-step-fw').on('click', stepForward);
  });

}).call(this);
