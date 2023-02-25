package haxe.ui.containers.windows;

import haxe.ui.events.UIEvent;
import haxe.ui.layouts.AbsoluteLayout;
import haxe.ui.geom.Point;
import haxe.ui.geom.Rectangle;
import haxe.ui.core.Screen;
import haxe.ui.core.Component;
import haxe.ui.util.EventDispatcher;
import haxe.ui.components.Image;

class WindowManager extends EventDispatcher<WindowEvent> {
    private static var _instance:WindowManager;
    public static var instance(get, null):WindowManager;
    private static function get_instance():WindowManager {
        if (_instance == null) {
            _instance = new WindowManager();
        }
        return _instance;
    }

    //****************************************************************************************************
    // Instance
    //****************************************************************************************************
    public var topMostWindow:Window = null;
    public var openMaximized:Bool = false;

    public function new() {
        super();
    }

    public var windows(get, null):Array<Window>;
    private function get_windows():Array<Window> {
        if (_container == null) {
            var array:Array<Window> = [];
            for (c in Screen.instance.rootComponents) {
                if ((c is Window)) {
                    array.push(cast c);
                }
            }
            return array;
        }
        
        return _container.findComponents(Window, 1);
    }

    private var _container:Component = null;
    public var container(get, set):Component;
    private function get_container():Component {
        return _container;
    }
    private function set_container(value:Component):Component {
        _container = value;
        _container.layout = new AbsoluteLayout();
        _container.registerEvent(UIEvent.RESIZE, onContainerResized);
        return value;
    }

    private function onContainerResized(event:UIEvent) {
        for (window in windows) {
            if (window.maximized) {
                var cx:Float = 0;
                var cy:Float = 0;
                if (_container == null) {
                    cx = Screen.instance.width;
                    cy = Screen.instance.height;
                } else {
                    cx = _container.width;
                    cy = _container.height;
                }
        
                window.left = 0;
                window.top = 0;
                window.width = cx;
                window.height = cy;
            }
        }
    }

    private var _nextWindowPos = new Point(0, 0);
    public function addWindow(window:Window) {
        if (window.left == 0) {
            window.left = _nextWindowPos.x;
            _nextWindowPos.x += 30;
        }
        if (window.top == 0) {
            window.top = _nextWindowPos.y;
            _nextWindowPos.y += 30;
        }

        window.windowManager = this;
        window.opacity = 0;
        if (_container == null) {
            Screen.instance.addComponent(window);
        } else {
            _container.addComponent(window);
        }

        var e = new WindowEvent(WindowEvent.WINDOW_ADDED);
        dispatch(e, window);

        bringToFront(window);

        if (openMaximized) {
            maximizeWindow(window);
        }

        window.fadeIn();
    }

    public function bringToFront(window:Window) {
        if (topMostWindow == window) {
            if (!window.maximized) {
                topMostWindow.addClass("window-active", true, true);
            }
            return;
        }

        if (topMostWindow != null) {
            var e = new WindowEvent(WindowEvent.WINDOW_DEACTIVATED);
            topMostWindow.removeClass("window-active", true, true);
            dispatch(e, topMostWindow);
        }

        if (_container == null) {
            Screen.instance.setComponentIndex(window, Screen.instance.rootComponents.length - 1);
        } else {
            _container.setComponentIndex(window, _container.numComponents - 1);
        }

        topMostWindow = window;
        if (!window.maximized) {
            topMostWindow.addClass("window-active", true, true);
        }
        var e = new WindowEvent(WindowEvent.WINDOW_ACTIVATED);
        dispatch(e, topMostWindow);
    }

    private function activatePrevWindow(window:Window) {
        if (window == null) {
            return;
        }

        var e = new WindowEvent(WindowEvent.WINDOW_DEACTIVATED);
        dispatch(e, window);

        var prevWindow:Window = findPrevActivableWindow(window);
        if (prevWindow != null) {
            bringToFront(prevWindow);
        }
    }

    private function findPrevActivableWindow(window:Window):Window {
        var windowList = windows;
        var index = windowList.indexOf(window);
        var prevWindow:Window = null;
        if (index != -1) {
            index--;
            while (index >= 0) {
                if (windowList[index].minimized == false) {
                    prevWindow = windowList[index];
                    break;
                }
                index--;
            }
            if (prevWindow != null) {
                bringToFront(prevWindow);
            }
        }
        return prevWindow;
    }

    private var _originalWindowBounds:Map<Window, Rectangle> = new Map<Window, Rectangle>();
    public function maximizeWindow(window:Window, activate:Bool = true) {
        if (window.maximized == true) {
            return;
        }

        openMaximized = true;

        _originalWindowBounds.set(window, new Rectangle(window.left, window.top, window.width, window.height));

        var cx:Float = 0;
        var cy:Float = 0;
        if (_container == null) {
            cx = Screen.instance.width;
            cy = Screen.instance.height;
        } else {
            cx = _container.width;
            cy = _container.height;
        }

        window.left = 0;
        window.top = 0;
        window.width = cx;
        window.height = cy;
        window.maximized = true;
        window.addClass("window-maximized");
        window.removeClass("window-active", true, true);
        window.findComponent("windowWrapper", Component).addClass("window-maximized");

        var e = new WindowEvent(WindowEvent.WINDOW_MAXIMIZED);
        dispatch(e, window);

        if (activate) {
            bringToFront(window);
        }

        maximizeAllWindows();
    }

    public function minimizeWindow(window:Window) {
        if (window.minimized == true) {
            return;
        }

        window.hide();
        window.minimized = true;
        var e = new WindowEvent(WindowEvent.WINDOW_MINIMIZED);
        dispatch(e, window);


        if (topMostWindow == window) {
            activatePrevWindow(window);
        }
    }

    public function restoreWindow(window:Window) {
        if (window.minimized) {
            window.minimized = false;
            window.show();
        } else if (window.maximized) {
            openMaximized = false;

            if (!_originalWindowBounds.exists(window)) {
                return;
            }

            var bounds = _originalWindowBounds.get(window);
            window.left = bounds.left;
            window.top = bounds.top;
            window.width = bounds.width;
            window.height = bounds.height;
            window.maximized = false;
            window.removeClass("window-maximized");
            window.findComponent("windowWrapper", Component).removeClass("window-maximized");
            if (window == topMostWindow) {
                window.addClass("window-active", true, true);
            }

            _originalWindowBounds.remove(window);

            restoreAllWindows();
        }

        var e = new WindowEvent(WindowEvent.WINDOW_RESTORED);
        dispatch(e, window);

    }

    private function restoreAllWindows() {
        for (w in windows) {
            if (w.maximized && !w.minimized) {
                restoreWindow(w);
            }
        }
    }

    private function maximizeAllWindows() {
        for (w in windows) {
            if (!w.maximized) {
                maximizeWindow(w, false);
            }
        }
    }

    // returns if window was closed or not
    @:access(haxe.ui.containers.windows.Window)
    public function closeWindow(window:Window):Bool {
        var e = new WindowEvent(WindowEvent.WINDOW_BEFORE_CLOSED);
        dispatch(e, window);
        if (e.canceled) {
            return false;
        }
        var e = new WindowEvent(WindowEvent.WINDOW_BEFORE_CLOSED);
        window.dispatch(e);
        if (e.canceled) {
            return false;
        }

        window.validateWindow(function(validated) {
            if (validated) {
                var existing = window.findComponent("windowCloseButton", Image);
                if (existing != null) {
                    existing.removeClass(":hover");
                }
                window.fadeOut(function() {
                    // lets find the prev window _before_ we've removed the window, since, once removed
                    // it we'll no longer be able to find its index, therefore cant find one previous 
                    // to it
                    var prevWindow = findPrevActivableWindow(window);

                    var e = new WindowEvent(WindowEvent.WINDOW_CLOSED);
                    window.dispatch(e);

                    if (_container == null) {
                        Screen.instance.removeComponent(window);
                    } else {
                        _container.removeComponent(window);
                    }

                    var e = new WindowEvent(WindowEvent.WINDOW_CLOSED);
                    dispatch(e, window);

                    if (topMostWindow == window) {
                        if (prevWindow != null) {
                            bringToFront(prevWindow);
                        }
                    }
                });
            }
        });

        return true;
    }

    public function reset() {
        for (window in windows) {
            if (_container == null) {
                Screen.instance.removeComponent(window);
            } else {
                _container.removeComponent(window);
            }
        }
        _container = null;
        topMostWindow = null;
        openMaximized = false;
        removeAllListeners();
    }
}