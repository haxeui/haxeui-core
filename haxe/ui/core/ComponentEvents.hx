package haxe.ui.core;

import haxe.ui.events.Events;
import haxe.ui.events.KeyboardEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.util.EventMap;
import haxe.ui.util.FunctionArray;

class ComponentEvents extends ComponentContainer {
    public function new() {
        super();
    }
    
    private var _internalEvents:Events = null;
    private var _internalEventsClass:Class<Events> = null;
    private function registerInternalEvents(eventsClass:Class<Events> = null, reregister:Bool = false) {
        if (_internalEvents == null && eventsClass != null) {
            _internalEvents = Type.createInstance(eventsClass, [this]);
            _internalEvents.register();
        } if (reregister == true && _internalEvents != null) {
            _internalEvents.register();
        }
    }
    private function unregisterInternalEvents() {
        if (_internalEvents == null) {
            return;
        }
        _internalEvents.unregister();
        _internalEvents = null;
    }
    
    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    private var __events:EventMap;

    /**
     Register a listener for a certain `UIEvent`
    **/
    @:dox(group = "Event related properties and methods")
    public function registerEvent(type:String, listener:Dynamic->Void, priority:Int = 0) {
        if (cast(this, Component).hasClass(":mobile") && (type == MouseEvent.MOUSE_OVER || type == MouseEvent.MOUSE_OUT)) {
            return;
        }
        
        if (disabled == true && isInteractiveEvent(type) == true) {
            if (_disabledEvents == null) {
                _disabledEvents = new EventMap();
            }
            _disabledEvents.add(type, listener, priority);
            return;
        }
        
        if (__events == null) {
            __events = new EventMap();
        }
        if (__events.add(type, listener, priority) == true) {
            mapEvent(type, _onMappedEvent);
        }
    }

    /**
     Returns if this component has a certain event and listener
    **/
    @:dox(group = "Event related properties and methods")
    public function hasEvent(type:String, listener:Dynamic->Void = null):Bool {
        if (__events == null) {
            return false;
        }
        return __events.contains(type, listener);
    }

    /**
     Unregister a listener for a certain `UIEvent`
    **/
    @:dox(group = "Event related properties and methods")
    public function unregisterEvent(type:String, listener:Dynamic->Void) {
        if (_disabledEvents != null && !_interactivityDisabled) {
            _disabledEvents.remove(type, listener);
        }
        
        if (__events != null) {
            if (__events.remove(type, listener) == true) {
                unmapEvent(type, _onMappedEvent);
            }
        }
    }

    /**
     Dispatch a certain `UIEvent`
    **/
    @:dox(group = "Event related properties and methods")
    public function dispatch(event:UIEvent) {
		if (event != null) {
			if (__events != null) {
				__events.invoke(event.type, event, cast(this, Component));  // TODO: avoid cast
			}
			
			if (event.bubble == true && event.canceled == false && parentComponent != null) {
				parentComponent.dispatch(event);
			}
		}
    }
    
    private function dispatchRecursively(event:UIEvent) {
        dispatch(event);
        for (child in childComponents) {
            child.dispatchRecursively(event);
        }
    }

    private function _onMappedEvent(event:UIEvent) {
        dispatch(event);
    }

    private var _disabledEvents:EventMap;
    private static var INTERACTIVE_EVENTS:Array<String> = [
        MouseEvent.MOUSE_MOVE, MouseEvent.MOUSE_OVER, MouseEvent.MOUSE_OUT, MouseEvent.MOUSE_DOWN,
        MouseEvent.MOUSE_UP, MouseEvent.MOUSE_WHEEL, MouseEvent.CLICK, MouseEvent.DBL_CLICK, KeyboardEvent.KEY_DOWN,
        KeyboardEvent.KEY_UP
    ];
    
    private function isInteractiveEvent(type:String):Bool {
        return INTERACTIVE_EVENTS.indexOf(type) != -1;
    }
    
    private var _interactivityDisabled:Bool = false;
    private var _interactivityDisabledCounter:Int = 0;
    private function disableInteractivity(disable:Bool, recursive:Bool = true, updateStyle:Bool = false) { // You might want to disable interactivity but NOT actually disable visually
        if (disable == true) {
            _interactivityDisabledCounter++;
        } else {
            _interactivityDisabledCounter--;
        }
        
        if (_interactivityDisabledCounter > 0 && _interactivityDisabled == false) {
            _interactivityDisabled = true;
            if (updateStyle == true) {
                cast(this, Component).swapClass(":disabled", ":hover");
            }
            if (__events != null) {
                for (eventType in __events.keys()) {
                    if (!isInteractiveEvent(eventType)) {
                        continue;
                    }
                    var listeners:FunctionArray<UIEvent->Void> = __events.listeners(eventType);
                    if (listeners != null) {
                        for (listener in listeners.copy()) {
                            if (_disabledEvents == null) {
                                _disabledEvents = new EventMap();
                            }
                            _disabledEvents.add(eventType, listener);
                            unregisterEvent(eventType, listener);
                        }
                    }
                }
            }
        } else if (_interactivityDisabledCounter < 1 && _interactivityDisabled == true) {
            _interactivityDisabled = false;
            if (updateStyle == true) {
                cast(this, Component).removeClass(":disabled");
            }
            if (_disabledEvents != null) {
                for (eventType in _disabledEvents.keys()) {
                    var listeners:FunctionArray<UIEvent->Void> = _disabledEvents.listeners(eventType);
                    if (listeners != null) {
                        for (listener in listeners.copy()) {
                            registerEvent(eventType, listener);
                        }
                    }
                }
                _disabledEvents = null;
            }
        }
        
        if (recursive == true) {
            for (child in childComponents) {
                child.disableInteractivity(disable, recursive, updateStyle);
            }
        }
    }
    
    private function unregisterEvents() {
        if (__events != null) {
            var copy:Array<String> = [];
            for (eventType in __events.keys()) {
                copy.push(eventType);
            }
            for (eventType in copy) {
                var listeners = __events.listeners(eventType);
                if (listeners != null) {
                    for (listener in listeners) {
                        if (listener != null) {
                            if (__events.remove(eventType, listener) == true) {
                                unmapEvent(eventType, _onMappedEvent);
                            }
                        }
                    }
                }
            }
        }
    }
    
    private function mapEvent(type:String, listener:UIEvent->Void) {
    }
    
    private function unmapEvent(type:String, listener:UIEvent->Void) {
        
    }
}