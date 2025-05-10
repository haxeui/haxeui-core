package haxe.ui.tooltips;

import haxe.ui.Toolkit;
import haxe.ui.components.Label;
import haxe.ui.constants.Priority;
import haxe.ui.core.Component;
import haxe.ui.core.ItemRenderer;
import haxe.ui.core.Screen;
import haxe.ui.events.MouseEvent;
import haxe.ui.geom.Rectangle;
import haxe.ui.util.Timer;

class ToolTipManager {
    public static var defaultDelay:Int = 500;
    public static var defaultRenderer:ItemRenderer = null;
    public static var fade:Bool = true;
    public static var followMouse:Bool = false;

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
    private var _toolTipRegions:Array<ToolTipRegionOptions> = [];

    private function new() {
        _toolTipOptions = new Map<Component, ToolTipOptions>();
    }

    public function registerTooltipRegion(options:ToolTipRegionOptions):ToolTipRegionOptions {
        if (_toolTipRegions.indexOf(options) == -1) {
            _toolTipRegions.insert(0, options); // we'll add it to the start so we dont need to reverse the array
                                                // were going to work on the principle that if regions overlap
                                                // the "topmost" one will trigger, which will be the last added
        }

        if (_toolTipRegions.length > 0 && !Screen.instance.hasEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMoveRegion)) {
            Screen.instance.registerEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMoveRegion, Priority.LOWEST);
        }

        return options;
    }

    public function unregisterTooltipRegion(options:ToolTipRegionOptions) {
        _toolTipRegions.remove(options);
        if (_toolTipRegions.length == 0) {
            Screen.instance.unregisterEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMoveRegion);
        }
    }

    public function registerTooltip(target:Component, options:ToolTipOptions = null) {
        if (_toolTipOptions.exists(target)) {
            return;
        }

        if (options == null) options = {};
        if (options.tipData == null) options.tipData = { text: target.tooltip };
        _toolTipOptions.set(target, options);
        target.registerEvent(MouseEvent.MOUSE_OVER, onTargetMouseOver, Priority.LOW);
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

    private static var calcRect:Rectangle = new Rectangle();
    private var _currentRegion:ToolTipRegionOptions = null;
    private function onScreenMouseMoveRegion(event:MouseEvent) {
        _lastMouseEvent = event;

        var found = false;
        for (region in _toolTipRegions) {
            calcRect.set(region.left, region.top, region.width, region.height);
            if (calcRect.containsPoint(event.screenX, event.screenY)) {
                found = true;
                if (_currentRegion != region) {
                    if (_currentRegion != null) {
                        hideCurrentToolTip();
                    }
                    _currentRegion = region;
                    stopTimer();
                    startTimer();
                } else {
                    if (_toolTip != null && followMouse) {
                        positionToolTip(_lastMouseEvent.screenX, _lastMouseEvent.screenY);
                    }
                }
                break;
            }
        }
        if (!found) {
            if (_currentRegion != null) {
                stopTimer();
                hideCurrentToolTip();
            }
            _currentRegion = null;
        }
    }

    private var _currentComponent:Component = null;
    private var _timer:Timer = null;
    private function onTargetMouseOver(event:MouseEvent) {
        if (_currentComponent != null && _currentComponent.style != null && _currentComponent.style.pointerEvents != null && _currentComponent.style.pointerEvents != "none") {
            if (_currentComponent == event.target || _currentComponent.containsChildComponent(event.target, true)) {
                return;
            }
        }

        if (_toolTip != null) {
            _toolTip.hide();
        }

        event.cancel();
        stopCurrent();

        _lastMouseEvent = event;
        _currentComponent = event.target;
        event.target.registerEvent(MouseEvent.MOUSE_OUT, onTargetMouseOut, Priority.LOW);
        event.target.registerEvent(MouseEvent.MOUSE_MOVE, onTargetMouseMove, Priority.LOW);
        Screen.instance.registerEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMove, Priority.LOW);
        startTimer();
    }

    private function onTargetMouseMove(event:MouseEvent) {
        if (_toolTip != null && _toolTip.hidden == false) {
            if (followMouse) {
                positionToolTip();
            }
            return;
        }
        stopTimer();
        startTimer();
    }

    private function onTargetMouseOut(event:MouseEvent) {
        if (_currentComponent != null && _currentComponent.style != null && _currentComponent.style.pointerEvents != null && _currentComponent.style.pointerEvents != "none") {
            if (event.target.hitTest(event.screenX, event.screenY)) {
                return;
            }
        }
        stopCurrent();
        hideCurrentToolTip();
    }

    private function onDelayTimer() {
        _timer.stop();
        _timer = null;
        if (_currentRegion != null) {
            showToolTipForRegion(_currentRegion);
        } else if (_currentComponent != null) {
            showToolTipForComponent(_currentComponent);
        }
    }

    private function onScreenMouseMove(event:MouseEvent) {
        _lastMouseEvent = event;
    }

    private function onScreenMouseDown(event:MouseEvent) {
        hideCurrentToolTip();
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

    public function reset() {
        if (_toolTip != null) {
            Screen.instance.removeComponent(_toolTip);
        }
        _toolTip = null;
        _toolTipContents = null;
    }

    public function showToolTipAt(left:Float, top:Float, options:ToolTipOptions) {
        createToolTip();
        _toolTip.hide();

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

        positionToolTip(left, top);
        Toolkit.callLater(function() {
            if (fade == true) {
                _toolTip.fadeIn();
            } else {
                _toolTip.show();
            }
        });

        Screen.instance.registerEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
    }

    private function showToolTipForComponent(component:Component) {
        if (component == null) {
            return;
        }
        
        if (component.disabled == true || component.hidden == true) {
            stopCurrent();
            return;
        }
        
        createToolTip();

        _toolTip.hide();

        var options = _toolTipOptions.get(component);
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
            if (_toolTip != null) { // _tooltip could have destroyed by other means in the window for callLater
                if (fade == true) {
                    _toolTip.fadeIn();
                } else {
                    _toolTip.show();
                }
            }
        });

        Screen.instance.registerEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
    }

    private function showToolTipForRegion(region:ToolTipRegionOptions) {
        createToolTip();

        _toolTip.hide();

        var options = region;
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

        positionToolTip(_lastMouseEvent.screenX, _lastMouseEvent.screenY);
        Toolkit.callLater(function() {
            if (fade == true) {
                _toolTip.fadeIn();
            } else {
                _toolTip.show();
            }
        });

        Screen.instance.registerEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
    }

    private function positionToolTip(left:Null<Float> = null, top:Null<Float> = null) {
        var x = _toolTip.marginLeft;
        var y = _toolTip.marginTop;
        if (left == null) {
            x += _lastMouseEvent.screenX;
        } else {
            x += left;
        }
        if (top == null) {
            y += _lastMouseEvent.screenY;
        } else {
            y += top;
        }
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

        _toolTip.left = x * Toolkit.scale;
        _toolTip.top = y * Toolkit.scale;
    }

    public function hideCurrentToolTip() {
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
        if (options != null && options.renderer != null) {
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