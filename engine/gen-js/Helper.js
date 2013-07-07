// Generated by CoffeeScript 1.4.0
(function() {
  var root;

  root = typeof global !== "undefined" && global !== null ? global : window;

  root.Helper = (function() {

    function Helper() {}

    Helper.clone = function(obj) {
      var key, newInstance;
      if (!(obj != null) || typeof obj !== 'object') {
        return obj;
      }
      newInstance = new obj.constructor();
      for (key in obj) {
        newInstance[key] = this.clone(obj[key]);
      }
      return newInstance;
    };

    return Helper;

  })();

}).call(this);