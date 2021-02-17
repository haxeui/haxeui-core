package haxe.ui.tooltips;

import haxe.ui.Toolkit;
import haxe.ui.components.Label;
import haxe.ui.core.Component;
import haxe.ui.core.ItemRenderer;
import haxe.ui.core.Screen;
import haxe.ui.events.MouseEvent;
import haxe.ui.util.Timer;

class ToolTipManager {
    public static var defaultDelay:Int = 500;
    public static var defaultRenderer:ItemRenderer = null;
    public static var fade:Bool = true;

    private static var _instance:ToolTipManager;
    public static var instance(get, null):ToolTipManager;
    private static function get_instance():ToolTipManager {
        if (_instance == null) {
            _instance = new ToolTipManager();
        }
        return _instance;
    }

    //****************************************************************************************************
    // Instance
    //****************************************************************************************************
    private var _lastMouseEvent:MouseEvent = null;
    private var _toolTipOptions:Map<Component, ToolTipOptions>;

    private function new() {
        _toolTipOptions = new Map<Component, ToolTipOptions>();
    }

    public function registerTooltip(target:Component, options:ToolTipOptions = null) {
        if (_toolTipOptions.exists(target)) {
            return;
        }

        if (options == null) options = {};
        if (options.tipData == null) options.tipData = { text: target.tooltip };
        _toolTipOptions.set(target, options);
        target.registerEvent(MouseEvent.MOUSE_OVER, onTargetMouseOver);
    }

    public function unregisterTooltip(target:Component) {
        target.unregisterEvent(MouseEvent.MOUSE_OVER, onTargetMouseOver);
        target.unregisterEvent(MouseEvent.MOUSE_OUT, onTargetMouseOut);
        target.unregisterEvent(MouseEvent.MOUSE_MOVE, onTargetMouseMove);
        _toolTipOptions.remove(target);
    }

    public function getTooltipOptions(target:Component):ToolTipOptions {
        return _toolTipOptions.get(target);
    }

    public function updateTooltipRenderer(target:Component, renderer:ItemRenderer) {
        if (!_toolTipOptions.exists(target)) {
            return;
        }

        var options = _toolTipOptions.get(target);
        options.renderer = renderer;
    }

    private var _currentComponent:Component = null;
    private var _timer:Timer = null;
    private function onTargetMouseOver(event:MouseEvent) {
        stopCurrent();

        _lastMouseEvent = event;
        _currentComponent = event.target;
        event.target.registerEvent(MouseEvent.MOUSE_OUT, onTargetMouseOut);
        event.target.registerEvent(MouseEvent.MOUSE_MOVE, onTargetMouseMove);
        Screen.instance.registerEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMove);
        startTimer();
    }

    private function onTargetMouseMove(event:MouseEvent) {
        if (_toolTip != null && _toolTip.hidden == false) {
            return;
        }
        stopTimer();
        startTimer();
    }

    private function onTargetMouseOut(event:MouseEvent) {
        stopCurrent();
        hideToolTip();
    }

    private function onDelayTimer() {
        _timer.stop();
        _timer = null;
        showToolTip();
    }

    private function onScreenMouseMove(event:MouseEvent) {
        _lastMouseEvent = event;
    }

    private function onScreenMouseDown(event:MouseEvent) {
        hideToolTip();
    }

    private function startTimer() {
        _timer = new Timer(defaultDelay, onDelayTimer);
    }

    private function stopTimer() {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }

    private function stopCurrent() {
        if (_currentComponent != null) {
            _currentComponent.unregisterEvent(MouseEvent.MOUSE_OUT, onTargetMouseOut);
            _currentComponent = null;
        }
        stopTimer();
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMove);
    }

    private var _toolTip:ToolTip = null;
    private var _toolTipContents:ItemRenderer = null;
    private function createToolTip() {
        if (_toolTip != null) {
            return;
        }

        _toolTip = new ToolTip();
    }

    private function showToolTip() {
        if (_currentComponent == null) {
            return;
        }
        
        createToolTip();

        _toolTip.hide();

        var options = _toolTipOptions.get(_currentComponent);
        var renderer = createToolTipRenderer(options);
        if (_toolTip.childComponents[0] != renderer) {
            if (_toolTip.childComponents.length > 0) {
                _toolTip.removeComponentAt(0, false);
            }
            _toolTip.addComponent(renderer);
        }

        renderer.data = options.tipData;

        Screen.instance.addComponent(_toolTip);
        Screen.instance.setComponentIndex(_toolTip, Screen.instance.rootComponents.length - 1);
        _toolTip.validateNow();

        positionToolTip();
        Toolkit.callLater(function() {
            if (fade == true) {
                _toolTip.fadeIn();
            } else {
                _toolTip.show();
            }
        });

        Screen.instance.registerEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
    }

    private function positionToolTip() {
        var x = _lastMouseEvent.screenX + _toolTip.marginLeft;
        var y = _lastMouseEvent.screenY + _toolTip.marginTop;
        var w = _toolTip.width;
        var h = _toolTip.height;

        var maxX = Screen.instance.width;
        var maxY = Screen.instance.height;

        if (x + w > maxX) {
            x = x - w;
        }
        if (y + h > maxY) {
            y = _lastMouseEvent.screenY - h - (_toolTip.marginTop / 2);
        }

        _toolTip.left = x;
        _toolTip.top = y;
    }

    private function hideToolTip() {
        if (_toolTip != null) {
            if (fade == true) {
                _toolTip.fadeOut();
            } else {
                _toolTip.hide();
            }
        }
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
    }

    private function createToolTipRenderer(options:ToolTipOptions):ItemRenderer {
        if (options.renderer != null) {
            return options.renderer;
        }

        if (defaultRenderer != null) {
            return defaultRenderer;
        }

        if (_toolTipContents != null) {
            return _toolTipContents;
        }

        _toolTipContents = new ItemRenderer();
        var label = new Label();
        label.id = "text";
        _toolTipContents.addComponent(label);
        return _toolTipContents;
    }
}