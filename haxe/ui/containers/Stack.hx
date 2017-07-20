package haxe.ui.containers;

import haxe.ui.animation.transition.Transition;
import haxe.ui.animation.transition.TransitionManager;
import haxe.ui.constants.TransitionMode;
import haxe.ui.core.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.core.UIEvent;
import haxe.ui.util.Rectangle;
import haxe.ui.util.Variant;

/**
 A `Box` component where only one child is visible at a time
**/
@:dox(icon = "/icons/ui-layered-pane.png")
class Stack extends Box {
    public function new() {
        super();
    }

    private override function createDefaults() {
        super.createDefaults();
        defaultBehaviours([
            "transitionMode" => new StackDefaultTransitionModeBehaviour(this),
            "selectedIndex" => new StackDefaultSelectedIndexBehaviour(this)
        ]);
    }

    //******************************************************************************************
    // Overrides
    //******************************************************************************************
    public override function addComponent(child:Component):Component {
        super.addComponent(child);
        if (_selectedIndex == -1 && childComponents.length == 1) {
           selectedIndex = 0;
        }
        child.hidden = (childComponents.length - 1 != _selectedIndex);
        child.includeInLayout = child.hidden == false;
        return child;
    }

    //TODO --> https://github.com/haxeui/haxeui-core/pull/93
    /*public override function addComponentAt(child:Component, index:Int):Component {
        super.addComponentAt(child, index);
        if (_selectedIndex == -1 && childComponents.length == 1) {
           selectedIndex = 0;
        }
        child.hidden = (index != _selectedIndex);
        return child;
    }*/

    public override function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true):Component {
        var index:Int = getComponentIndex(child);
        if (index == _selectedIndex) {
            selectedIndex = -1;
        }

        return super.removeComponent(child);
    }

    public override function removeAllComponents(dispose:Bool = true) {
        selectedIndex = -1;

        super.removeAllComponents(dispose);
    }

    private override function onResized() {
        updateClip();
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************

    private var _selectedIndex:Int = -1;
    @:clonable public var selectedIndex(get, set):Int;
    private function get_selectedIndex():Int {
        return _selectedIndex;
    }
    private function set_selectedIndex(value:Int):Int {
        if (_selectedIndex == value) {
            return value;
        }

        if(_selectedIndex != -1) {
            _history.push(_selectedIndex);
        }

        behaviourSet("selectedIndex", value);
        _selectedIndex = value;

        dispatch(new UIEvent(UIEvent.CHANGE));

        return value;
    }

    private var _transitionMode:TransitionMode = TransitionMode.NONE;
    @:clonable public var transitionMode(get, set):TransitionMode;
    private function get_transitionMode():TransitionMode {
        return _transitionMode;
    }
    private function set_transitionMode(value:TransitionMode):TransitionMode {
        if (_transitionMode == value) {
            return value;
        }

        _transitionMode = value;
        behaviourSet("transitionMode", value);

        return value;
    }

    private var _history : List<Int> = new List();

    /**
        Go back to the last selected index
    **/
    public function back() {
        var last = _history.pop();
        if (last == null) {
            return;
        }

        selectedIndex = last;
    }

    public function canGoBack():Bool {
        return _history.length > 0;
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************

    private var _currentTransition:Transition;
    private function animateTo(fromIndex:Int, toIndex:Int) {
        var inComponent:Component = (toIndex != -1) ? getComponentAt(toIndex) : null;
        var outComponent:Component = (fromIndex != -1) ? getComponentAt(fromIndex) : null;

        var transitionId:String = null;
        var mode:TransitionMode = transitionMode;
        if (inComponent == null || outComponent == null || animatable == false) {
            mode = TransitionMode.NONE;
        } else {
            switch (mode) {
                case TransitionMode.HORIZONTAL_SLIDE, TransitionMode.VERTICAL_SLIDE,
                    TransitionMode.HORIZONTAL_SLIDE_FROM_LEFT, TransitionMode.HORIZONTAL_SLIDE_FROM_RIGHT,
                    TransitionMode.VERTICAL_SLIDE_FROM_TOP, TransitionMode.VERTICAL_SLIDE_FROM_BOTTOM:
                    transitionId = getClassProperty("transition.slide");

                case TransitionMode.FADE:
                    transitionId = getClassProperty("transition.fade");

                case _:

            }

            if (transitionId == null) {
                mode = TransitionMode.NONE;
            }
        }

        if (inComponent != null) {
            inComponent.includeInLayout = true;
            inComponent.hidden = false;
        }

        if (_currentTransition != null) {
            _currentTransition.stop();
            _currentTransition = null;
        }

        if (mode != TransitionMode.NONE) {
            var inVars:Map<String, Float> = null;
            var outVars:Map<String, Float> = null;

            switch (mode) {
                case TransitionMode.HORIZONTAL_SLIDE:
                    inVars = [
                        "startLeft" => ((fromIndex < toIndex) ?
                                        outComponent.left + outComponent.width + layout.paddingLeft
                                        : outComponent.left - layout.paddingRight - inComponent.width),
                        "startTop" => layout.paddingTop,
                        "endLeft" => layout.paddingLeft
                    ];

                    outVars = [
                        "startLeft" => outComponent.left,
                        "endLeft" => ((fromIndex < toIndex) ?
                                      -width + layout.paddingLeft + layout.paddingRight
                                      : width)
                    ];

                case TransitionMode.HORIZONTAL_SLIDE_FROM_LEFT:
                    inVars = [
                        "startLeft" => outComponent.left - layout.paddingRight - inComponent.width,
                        "startTop" => layout.paddingTop,
                        "endLeft" => layout.paddingLeft
                    ];

                    outVars = [
                        "startLeft" => outComponent.left,
                        "endLeft" => width
                    ];

                case TransitionMode.HORIZONTAL_SLIDE_FROM_RIGHT:
                    inVars = [
                        "startLeft" => outComponent.left + outComponent.width + layout.paddingLeft,
                        "startTop" => layout.paddingTop,
                        "endLeft" => layout.paddingLeft
                    ];

                    outVars = [
                        "startLeft" => outComponent.left,
                        "endLeft" => -width + layout.paddingLeft + layout.paddingRight
                    ];

                case TransitionMode.VERTICAL_SLIDE:
                    inVars = [
                        "startLeft" => layout.paddingLeft,
                        "startTop" => ((fromIndex < toIndex) ?
                                       outComponent.top + outComponent.height + layout.paddingTop
                                       : outComponent.top - layout.paddingBottom - inComponent.height),
                        "endTop" => layout.paddingTop
                    ];

                    outVars = [
                        "startTop" => outComponent.top,
                        "endTop" => ((fromIndex < toIndex) ?
                                     -height + layout.paddingTop + layout.paddingBottom
                                     : height)
                    ];

                case TransitionMode.VERTICAL_SLIDE_FROM_TOP:
                    inVars = [
                        "startLeft" => layout.paddingLeft,
                        "startTop" => outComponent.top - layout.paddingBottom - inComponent.height,
                        "endTop" => layout.paddingTop
                    ];

                    outVars = [
                        "startTop" => outComponent.top,
                        "endTop" => height
                    ];

                case TransitionMode.VERTICAL_SLIDE_FROM_BOTTOM:
                    inVars = [
                        "startLeft" => layout.paddingLeft,
                        "startTop" => outComponent.top + outComponent.height + layout.paddingTop,
                        "endTop" => layout.paddingTop
                    ];

                    outVars = [
                        "startTop" => outComponent.top,
                        "endTop" => -height + layout.paddingTop + layout.paddingBottom
                    ];

                case TransitionMode.FADE:

                case _:
                //TODO - support for custom transition by user
            }

            _currentTransition = TransitionManager.instance.run(transitionId,
                ["target" => inComponent], inVars,
                ["target" => outComponent], outVars,
                function() {
                    _currentTransition = null;
                    outComponent.includeInLayout = false;
                    outComponent.hidden = true;
                });

        } else {
            if (inComponent != null) {
                inComponent.left = layout.paddingLeft;
                inComponent.top = layout.paddingTop;
            }

            if (outComponent != null) {
                outComponent.includeInLayout = false;
                outComponent.hidden = true;
            }
        }
    }

    private function updateClip() {
        if(componentClipRect == null || componentClipRect.width != componentWidth || componentClipRect.height != componentHeight) {
            componentClipRect = new Rectangle(0, 0, componentWidth, componentHeight);
        }
    }
}

//***********************************************************************************************************
// Default behaviours
//***********************************************************************************************************
@:dox(hide)
@:access(haxe.ui.containers.Stack)
class StackDefaultTransitionModeBehaviour extends Behaviour {
    public override function set(value:Variant) {

    }
}

@:dox(hide)
@:access(haxe.ui.containers.Stack)
class StackDefaultSelectedIndexBehaviour extends Behaviour {
    public override function set(value:Variant) {
        var stack:Stack = cast _component;
        stack.animateTo(stack._selectedIndex, value);
    }
}