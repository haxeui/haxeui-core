package haxe.ui.containers;

import haxe.ui.animation.transition.Transition;
import haxe.ui.animation.transition.TransitionManager;
import haxe.ui.constants.TransitionMode;
import haxe.ui.core.Behaviour;
import haxe.ui.core.Component;
import haxe.ui.core.UIEvent;
import haxe.ui.util.Variant;
import haxe.ui.validation.InvalidationFlags;
import haxe.ui.validation.ValidationManager;

/**
 A `Box` component where only one child is visible at a time
**/
@:dox(icon = "/icons/ui-layered-pane.png")
class Stack extends Box {
    private static inline var NO_SELECTION:Int = -1;

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
        if (_selectedIndex == NO_SELECTION && childComponents.length == 1) {
           selectedIndex = 0;
        }
        child.hidden = (childComponents.length - 1 != _selectedIndex);
        child.includeInLayout = child.hidden == false;
        return child;
    }

    public override function addComponentAt(child:Component, index:Int):Component {
        super.addComponentAt(child, index);
        if (_selectedIndex == NO_SELECTION && childComponents.length == 1) {
           selectedIndex = 0;
        }
        child.hidden = (index != _selectedIndex);
        child.includeInLayout = child.hidden == false;
        return child;
    }

    public override function removeComponent(child:Component, dispose:Bool = true, invalidate:Bool = true):Component {
        var index:Int = getComponentIndex(child);
        if (index == _selectedIndex) {
            selectedIndex = NO_SELECTION;
        }

        return super.removeComponent(child);
    }

    public override function removeComponentAt(index:Int, dispose:Bool = true, invalidate:Bool = true):Component {
        if (index == _selectedIndex) {
            selectedIndex = NO_SELECTION;
        }

        return super.removeComponentAt(index, dispose, invalidate);
    }

    public override function removeAllComponents(dispose:Bool = true) {
        selectedIndex = NO_SELECTION;

        super.removeAllComponents(dispose);
    }

    private override function onResized() {
        updateClip();
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************

    private var _selectedIndex:Int = NO_SELECTION;
    @:clonable public var selectedIndex(get, set):Int;
    private function get_selectedIndex():Int {
        return behaviourGet("selectedIndex");
    }
    private function set_selectedIndex(value:Int):Int {
        behaviourSet("selectedIndex", value);
        return value;
    }

    public var selectedItem(get, set):Component;
    private function get_selectedItem():Component {
        if (_selectedIndex == NO_SELECTION) {
            return null;
        }

        return getComponentAt(_selectedIndex);
    }
    private function set_selectedItem(value:Component):Component {
        selectedIndex = getComponentIndex(value);
        return value;
    }

    private var _transitionMode:TransitionMode = TransitionMode.NONE;
    @:clonable public var transitionMode(get, set):TransitionMode;
    private function get_transitionMode():TransitionMode {
        return behaviourGet("transitionMode");
    }
    private function set_transitionMode(value:TransitionMode):TransitionMode {
        behaviourSet("transitionMode", value);
        return value;
    }

    private var _currentSelection:Component;

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
    // Validation
    //***********************************************************************************************************

    /**
     Invalidate the index of this component
    **/
    @:dox(group = "Invalidation related properties and methods")
    public inline function invalidateIndex() {
        invalidate(InvalidationFlags.INDEX);
    }

    private override function validateInternal() {
        var dataInvalid = isInvalid(InvalidationFlags.DATA);
        var indexInvalid = isInvalid(InvalidationFlags.INDEX);
        var styleInvalid = isInvalid(InvalidationFlags.STYLE);
        var positionInvalid = isInvalid(InvalidationFlags.POSITION);
        var displayInvalid = isInvalid(InvalidationFlags.DISPLAY);
        var layoutInvalid = isInvalid(InvalidationFlags.LAYOUT) && _layoutLocked == false;

        if (dataInvalid) {
            validateData();
        }

        if (dataInvalid || indexInvalid) {
            validateIndex();
        }

        if (styleInvalid) {
            validateStyle();
        }

        if (positionInvalid) {
            validatePosition();
        }

        if (layoutInvalid) {
            displayInvalid = validateLayout() || displayInvalid;
        }

        if (displayInvalid || styleInvalid) {
            ValidationManager.instance.addDisplay(this);    //Update the display from all objects at the same time. Avoids UI flashes.
        }
    }

    private function validateIndex() {
        var newSelectedItem:Component = selectedItem;
        if(_currentSelection != newSelectedItem)
        {
            var oldIndex:Int = getComponentIndex(_currentSelection);
            animateTo(oldIndex, _selectedIndex);

            _currentSelection = newSelectedItem;
            if(_selectedIndex != NO_SELECTION) {
                _history.push(_selectedIndex);
            }

            dispatch(new UIEvent(UIEvent.CHANGE));
        }
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************

    private var _currentTransition:Transition;
    private function animateTo(fromIndex:Int, toIndex:Int) {
        var inComponent:Component = (toIndex != NO_SELECTION) ? getComponentAt(toIndex) : null;
        var outComponent:Component = (fromIndex != NO_SELECTION) ? getComponentAt(fromIndex) : null;

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
    public override function get():Variant {
        var stack:Stack = cast(_component, Stack);
        return stack._transitionMode;
    }

    public override function set(value:Variant) {
        var stack:Stack = cast(_component, Stack);
        if (stack._transitionMode != value) {
            stack._transitionMode = value;
        }
    }
}

@:dox(hide)
@:access(haxe.ui.containers.Stack)
class StackDefaultSelectedIndexBehaviour extends Behaviour {
    public override function get():Variant {
        var stack:Stack = cast(_component, Stack);
        return stack._selectedIndex;
    }

    public override function set(value:Variant) {
        var stack:Stack = cast(_component, Stack);
        if (stack._selectedIndex != value) {
            stack._selectedIndex = value;
            stack.invalidateIndex();
        }
    }
}