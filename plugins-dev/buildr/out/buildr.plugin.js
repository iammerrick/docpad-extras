// Generated by CoffeeScript 1.3.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  module.exports = function(BasePlugin) {
    var BuildrPlugin, child, exec, path;
    path = require('path');
    exec = require('child_process').exec;
    child = false;
    return BuildrPlugin = (function(_super) {

      __extends(BuildrPlugin, _super);

      function BuildrPlugin() {
        return BuildrPlugin.__super__.constructor.apply(this, arguments);
      }

      BuildrPlugin.prototype.name = 'buildr';

      BuildrPlugin.prototype.writeAfter = function(opts, next) {
        var buildrPath, docpad, logger;
        docpad = this.docpad;
        logger = this.logger;
        buildrPath = path.normalize("" + docpad.config.rootPath + "/buildr.coffee");
        return path.exists(buildrPath, function(exists) {
          if (!exists) {
            return typeof next === "function" ? next() : void 0;
          }
          if (child) {
            child.kill();
          }
          return child = exec("coffee " + buildrPath, function(err, stdout, stderr) {
            if (stdout) {
              console.log(stdout.replace(/\s+$/, ''));
            }
            if (stderr) {
              console.log(stderr.replace(/\s+$/, ''));
            }
            return typeof next === "function" ? next(err) : void 0;
          });
        });
      };

      return BuildrPlugin;

    })(BasePlugin);
  };

}).call(this);
