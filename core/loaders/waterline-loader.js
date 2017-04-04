// Generated by CoffeeScript 1.8.0
(function() {
  var ModelsLoader, Waterline, WaterlineMysqlAdapter, path, walk,
    __hasProp = {}.hasOwnProperty;

  walk = require('fs-walk');

  path = require("path");

  Waterline = require('waterline');

  WaterlineMysqlAdapter = require('sails-mysql');

  ModelsLoader = (function() {
    function ModelsLoader() {}

    ModelsLoader.orm = new Waterline;

    ModelsLoader.initialize = function(app, dbConfig) {
      dbConfig = ModelsLoader.updateAdapters(dbConfig);
      ModelsLoader.loadModels(path.join(__dirname, '..', '..', dbConfig.modelsPath));
      ModelsLoader.orm.initialize(dbConfig, function(err, models) {
        if (err) {
          throw err;
        }
        app.models = models.collections;
        return app.connections = models.connections;
      });
      return app.getModel = function(name) {
        return app.models[name.toLowerCase()];
      };
    };

    ModelsLoader.updateAdapters = function(dbConfig) {
      var adapter, key, _ref;
      console.log('Updating DB adapters');
      _ref = dbConfig.adapters;
      for (key in _ref) {
        if (!__hasProp.call(_ref, key)) continue;
        adapter = _ref[key];
        if (adapter === 'mysqlAdapter') {
          dbConfig.adapters[key] = WaterlineMysqlAdapter;
        }
      }
      return dbConfig;
    };

    ModelsLoader.loadModels = function(modelsDir) {
      console.log('Loading models');
      walk.walkSync(modelsDir, function(basedir, filename, stat) {
        var re, schemaJson;
        re = /(?:\.([^.]+))?$/;
        if ((filename.indexOf(".") !== 0) && (filename.indexOf("_") !== 0) && (re.exec(filename)[1] === "json")) {
          console.log(' - ' + filename);
          schemaJson = require(path.join(basedir, filename));
          return ModelsLoader.orm.loadCollection(Waterline.Collection.extend(schemaJson));
        }
      });
      return ModelsLoader;
    };

    return ModelsLoader;

  })();

  module.exports = ModelsLoader;

}).call(this);

//# sourceMappingURL=waterline-loader.js.map