// Generated by CoffeeScript 1.6.2
/* Constants
*/


(function() {
  var CODE_CHANGE_TIMEOUT, MODEL_FORMATTING_INDENTATION, MessageType, SPINNER_OPTS, adjustEditorToSize, automaticallyUpdatingModel, clearCodeInCache, clearMessage, currentActions, currentAssets, currentFrame, currentLayout, currentLoadedAssets, currentModel, currentModelData, editors, executeCode, getFormattedTime, globals, handleAnimation, handleResize, initCanvas, isPlaying, loadCodeFromCache, loadIntoEditor, log, notifyCodeChange, reloadCode, resetLogContent, saveCodeToCache, setCodeFromCache, setupButtonHandlers, setupEditor, setupLayout, showMessage, spinner;

  globals = this;

  CODE_CHANGE_TIMEOUT = 1000;

  MODEL_FORMATTING_INDENTATION = 2;

  MessageType = GE.makeConstantSet("Error", "Info");

  SPINNER_OPTS = {
    lines: 9,
    length: 7,
    width: 4,
    radius: 10,
    corners: 1,
    rotate: 0,
    color: '#000',
    speed: 1,
    trail: 60,
    shadow: false,
    hwaccel: false,
    className: 'spinner',
    zIndex: 2e9,
    top: 'auto',
    left: 'auto'
  };

  /* Globals
  */


  editors = {};

  log = null;

  spinner = new Spinner(SPINNER_OPTS);

  currentModel = new GE.Model();

  currentFrame = 0;

  currentModelData = null;

  currentAssets = null;

  currentActions = null;

  currentLayout = null;

  currentLoadedAssets = null;

  isPlaying = false;

  automaticallyUpdatingModel = false;

  /* Functions
  */


  initCanvas = function() {
    var canvas, context;

    canvas = $("#gameCanvas");
    context = canvas[0].getContext("2d");
    context.setFillColor("black");
    return context.fillRect(0, 0, canvas.width(), canvas.height());
  };

  adjustEditorToSize = function(editor) {
    var characterWidth, contentWidth, limit, session;

    session = editor.session;
    editor.resize();
    if (session.getUseWrapMode()) {
      characterWidth = editor.renderer.characterWidth;
      contentWidth = editor.renderer.scroller.clientWidth;
      if (contentWidth > 0) {
        limit = parseInt(contentWidth / characterWidth, 10);
        return session.setWrapLimitRange(limit, limit);
      }
    }
  };

  handleResize = function() {
    var editor, editorName;

    for (editorName in editors) {
      editor = editors[editorName];
      adjustEditorToSize(editor);
    }
    return adjustEditorToSize(log);
  };

  showMessage = function(messageType, message) {
    switch (messageType) {
      case MessageType.Error:
        $("#topAlertMessage").html(message);
        return $("#topAlert").show();
      case MessageType.Info:
        $("#topInfoMessage").html(message);
        return $("#topInfo").show();
      default:
        throw new Error("Incorrect messageType");
    }
  };

  clearMessage = function() {
    return $("#topAlert, #topInfo").hide();
  };

  setupLayout = function() {
    $("#saveButton").button({
      icons: {
        primary: "ui-icon-transferthick-e-w"
      }
    });
    $("#shareButton").button({
      icons: {
        primary: "ui-icon-link"
      }
    });
    $("#playButton").button({
      icons: {
        primary: "ui-icon-play"
      },
      text: false
    });
    $("#timeSlider").slider({
      orientation: "horizontal",
      range: "min",
      min: 0,
      max: 0,
      step: 1,
      value: 0
    });
    $("#resetButton").button({
      icons: {
        primary: "ui-icon-arrowreturnthick-1-w"
      },
      text: false
    });
    $("#west").tabs();
    $("#south").tabs().addClass("ui-tabs-vertical ui-helper-clearfix");
    $("#south li").removeClass("ui-corner-top").addClass("ui-corner-left");
    $("#south li a").click(handleResize);
    return $('body').layout({
      north__resizable: false,
      north__closable: false,
      north__size: 50,
      west__size: 300,
      applyDefaultStyles: true,
      onresize: handleResize
    });
  };

  setupButtonHandlers = function() {
    $("#playButton").on("click", function() {
      var editor, editorId;

      if (isPlaying) {
        isPlaying = false;
        for (editorId in editors) {
          editor = editors[editorId];
          editor.setReadOnly(false);
        }
        return $(this).button("option", {
          label: "Play",
          icons: {
            primary: "ui-icon-play"
          }
        });
      } else {
        isPlaying = true;
        for (editorId in editors) {
          editor = editors[editorId];
          editor.setReadOnly(true);
        }
        handleAnimation();
        return $(this).button("option", {
          label: "Pause",
          icons: {
            primary: "ui-icon-pause"
          }
        });
      }
    });
    $("#resetButton").on("click", function() {
      currentFrame = 0;
      currentModel = currentModel.atVersion(0);
      resetLogContent();
      $("#timeSlider").slider("option", {
        value: 0,
        max: 0
      });
      automaticallyUpdatingModel = true;
      editors.modelEditor.setValue(JSON.stringify(currentModel.data, null, MODEL_FORMATTING_INDENTATION));
      editors.modelEditor.selection.clearSelection();
      automaticallyUpdatingModel = false;
      return executeCode();
    });
    return $("#timeSlider").on("slide", function() {
      currentFrame = $(this).slider("value");
      return GE.doLater(function() {
        automaticallyUpdatingModel = true;
        editors.modelEditor.setValue(JSON.stringify(currentModel.atVersion(currentFrame).data, null, MODEL_FORMATTING_INDENTATION));
        editors.modelEditor.selection.clearSelection();
        automaticallyUpdatingModel = false;
        return executeCode();
      });
    });
  };

  setupEditor = function(id, mode) {
    var editor;

    if (mode == null) {
      mode = "";
    }
    editor = ace.edit(id);
    if (mode) {
      editor.getSession().setMode(mode);
    }
    editor.getSession().setUseWrapMode(true);
    editor.setWrapBehavioursEnabled(true);
    return editor;
  };

  loadIntoEditor = function(editor, url) {
    return $.ajax({
      url: url,
      dataType: "text",
      cache: false,
      success: function(data) {
        editor.setValue(data);
        return editor.selection.clearSelection();
      }
    });
  };

  reloadCode = function(callback) {
    var error,
      _this = this;

    try {
      currentAssets = JSON.parse(editors.assetsEditor.getValue());
    } catch (_error) {
      error = _error;
      GE.logger.log(GE.logLevels.ERROR, "Assets error. " + error);
      return showMessage(MessageType.Error, "<strong>Assets error.</strong> " + error);
    }
    try {
      currentModelData = JSON.parse(editors.modelEditor.getValue());
    } catch (_error) {
      error = _error;
      GE.logger.log(GE.logLevels.ERROR, "Model error. " + error);
      return showMessage(MessageType.Error, "<strong>Model error.</strong> " + error);
    }
    try {
      currentActions = eval(editors.actionsEditor.getValue());
    } catch (_error) {
      error = _error;
      GE.logger.log(GE.logLevels.ERROR, "Actions error. " + error);
      return showMessage(MessageType.Error, "<strong>Actions error.</strong> " + error);
    }
    try {
      currentLayout = JSON.parse(editors.layoutEditor.getValue());
    } catch (_error) {
      error = _error;
      GE.logger.log(GE.logLevels.ERROR, "Layout error. " + error);
      return showMessage(MessageType.Error, "<strong>Layout error.</strong> " + error);
    }
    return GE.loadAssets(currentAssets, function(err, loadedAssets) {
      if (err != null) {
        GE.logger.log(GE.logLevels.ERROR, "Cannot load assets");
        showMessage(MessageType.Error, "Cannot load assets");
        callback(err);
      }
      currentLoadedAssets = loadedAssets;
      currentModel.atVersion(currentFrame).data = currentModelData;
      $("#timeSlider").slider("option", {
        value: currentFrame,
        max: currentFrame
      });
      GE.logger.log(GE.logLevels.INFO, "Game updated");
      showMessage(MessageType.Info, "Game updated");
      return callback(null);
    });
  };

  executeCode = function() {
    var modelAtFrame, patches, result, _ref;

    modelAtFrame = currentModel.atVersion(currentFrame);
    _ref = GE.runStep(modelAtFrame, currentLoadedAssets, currentActions, currentLayout), result = _ref[0], patches = _ref[1];
    return modelAtFrame.applyPatches(patches);
  };

  notifyCodeChange = function() {
    var timeoutCallback;

    if (automaticallyUpdatingModel) {
      return false;
    }
    timeoutCallback = function() {
      spinner.stop();
      saveCodeToCache();
      return reloadCode(function(err) {
        if (!err) {
          return executeCode();
        }
      });
    };
    spinner.spin($("#north")[0]);
    clearMessage();
    if (notifyCodeChange.timeoutId) {
      window.clearTimeout(notifyCodeChange.timeoutId);
      notifyCodeChange.timeoutId = null;
    }
    return notifyCodeChange.timeoutId = window.setTimeout(timeoutCallback, CODE_CHANGE_TIMEOUT);
  };

  handleAnimation = function() {
    if (!isPlaying) {
      return false;
    }
    currentModel = executeCode();
    currentFrame++;
    $("#timeSlider").slider("option", {
      value: currentFrame,
      max: currentFrame
    });
    automaticallyUpdatingModel = true;
    editors.modelEditor.setValue(JSON.stringify(currentModel.data, null, MODEL_FORMATTING_INDENTATION));
    editors.modelEditor.selection.clearSelection();
    automaticallyUpdatingModel = false;
    return requestAnimationFrame(handleAnimation);
  };

  saveCodeToCache = function() {
    var cachedCodeJson, codeToCache, editor, id, programId;

    programId = window.location.hash.slice(1);
    if (!programId) {
      throw new Error("No program ID to save");
    }
    codeToCache = {};
    for (id in editors) {
      editor = editors[id];
      codeToCache[id] = editor.getValue();
    }
    cachedCodeJson = JSON.stringify(codeToCache);
    return localStorage.setItem(programId, cachedCodeJson);
  };

  loadCodeFromCache = function() {
    var programId;

    programId = window.location.hash.slice(1);
    if (!programId) {
      throw new Error("No program ID to load");
    }
    return localStorage.getItem(programId);
  };

  setCodeFromCache = function(cachedCodeJson) {
    var cachedCode, editor, id, _results;

    cachedCode = JSON.parse(cachedCodeJson);
    _results = [];
    for (id in editors) {
      editor = editors[id];
      editor.setValue(cachedCode[id]);
      _results.push(editor.selection.clearSelection());
    }
    return _results;
  };

  clearCodeInCache = function() {
    var programId;

    programId = window.location.hash.slice(1);
    if (!programId) {
      throw new Error("No program ID to remove");
    }
    return localStorage.removeItem(programId);
  };

  resetLogContent = function() {
    GE.logger.log(GE.logLevels.WARN, "Log content is being reset");
    log.setValue("");
    log.clearSelection();
    return GE.logger.log(GE.logLevels.INFO, "Reset log");
  };

  getFormattedTime = function() {
    var date;

    date = new Date();
    return date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds();
  };

  /* Main
  */


  $(document).ready(function() {
    var cachedCodeJson, id, loadedCode, prefixedLog, url, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _ref3;

    initCanvas();
    setupLayout();
    setupButtonHandlers();
    _ref = ["modelEditor", "assetsEditor", "actionsEditor", "layoutEditor"];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      id = _ref[_i];
      editors[id] = setupEditor(id, "ace/mode/javascript");
    }
    log = setupEditor("log");
    log.setReadOnly(true);
    prefixedLog = function(logType, message, newLine) {
      if (newLine == null) {
        newLine = true;
      }
      if (GE.logLevels[logType]) {
        log.clearSelection();
        log.navigateFileEnd();
        return log.insert(logType + ": " + getFormattedTime() + " " + message + (newLine ? "\n" : ""));
      } else {
        return prefixedLog("error", "bad logType parameter '" + logType + "' in log for message '" + message + "'");
      }
    };
    GE.logger.log = prefixedLog;
    resetLogContent();
    if (!window.location.hash) {
      window.location.hash = "optics";
    }
    loadedCode = false;
    cachedCodeJson = loadCodeFromCache();
    if (cachedCodeJson) {
      if (window.confirm("You had made changes to this code. Should we load your last version?")) {
        setCodeFromCache(cachedCodeJson);
        loadedCode = true;
      } else {
        clearCodeInCache();
      }
    }
    if (!loadedCode) {
      _ref1 = [["modelEditor", "optics/model.json"], ["assetsEditor", "optics/assets.json"], ["actionsEditor", "optics/actions.js"], ["layoutEditor", "optics/layout.json"]];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        _ref2 = _ref1[_j], id = _ref2[0], url = _ref2[1];
        loadIntoEditor(editors[id], url);
      }
    }
    _ref3 = ["modelEditor", "assetsEditor", "actionsEditor", "layoutEditor"];
    for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
      id = _ref3[_k];
      editors[id].getSession().on("change", function() {
        return notifyCodeChange();
      });
    }
    globals.editors = editors;
    $(window).on("onresize", handleResize);
    return notifyCodeChange();
  });

}).call(this);
