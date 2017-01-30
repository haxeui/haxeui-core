package haxe.ui.components.complex;

import haxe.ui.constants.TransitionMode;
import haxe.ui.containers.Stack;
import haxe.ui.core.Component;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.Screen;
import haxe.ui.layouts.AbsoluteLayout;
import haxe.ui.util.MathUtil;

class ImageGallery extends Stack {
    public function new() {
        super();

        layout = new AbsoluteLayout();

        transitionMode = TransitionMode.HORIZONTAL_SLIDE;
    }

    //******************************************************************************************
    // Overrides
    //******************************************************************************************

    private override function set_transitionMode(value:TransitionMode):TransitionMode {
        if (_transitionMode == value) {
            return value;
        }

        switch (value) {
            case TransitionMode.HORIZONTAL_SLIDE_FROM_LEFT, TransitionMode.HORIZONTAL_SLIDE_FROM_RIGHT:
                value = TransitionMode.HORIZONTAL_SLIDE;

            case TransitionMode.VERTICAL_SLIDE_FROM_TOP, TransitionMode.VERTICAL_SLIDE_FROM_BOTTOM:
                value = TransitionMode.VERTICAL_SLIDE;

            case TransitionMode.NONE, TransitionMode.HORIZONTAL_SLIDE, TransitionMode.VERTICAL_SLIDE:   //nothing to change

            case _: //Not supported
                return _transitionMode;
        }

        super.transitionMode = value;

        return value;
    }

    public override function addComponent(child:Component):Component {
        if (Std.is(child, Image)) {
            return super.addComponent(child);
        } else {
            throw "You can only add Image components in the ImageGallery";
        }
    }

    //TODO --> https://github.com/haxeui/haxeui-core/pull/93
    /*public override function addComponentAt(child:Component, index:Int):Component {
        if (Std.is(child, Image)) {
            return super.addComponentAt(child, index);
        } else {
            throw "You can only add Image components in the ImageGallery";
        }
    }*/

    private override function createChildren() {
        super.createChildren();

        registerEvent(MouseEvent.MOUSE_DOWN, _onMouseDown);
    }

    //******************************************************************************************
    // Public API
    //******************************************************************************************

    /**
        Minimum percent size to change from the current image to another.
    **/
    @:clonable public var percentToChange:Int = 20;

    //******************************************************************************************
    // Events
    //******************************************************************************************

    private var _startPosX:Float;
    private var _startPosY:Float;
    private var _currentPosX:Float;
    private var _currentPosY:Float;
    private var _drag:Bool;     //TODO - it isn't necessary, but something is wrong with _onMouseUp. It can be called twice (race condition?) and still _drag is ignored

    private function _onMouseDown(e:MouseEvent):Void {
        Screen.instance.registerEvent(MouseEvent.MOUSE_MOVE, _onMouseMove);
        Screen.instance.registerEvent(MouseEvent.MOUSE_UP, _onMouseUp);

        _startPosX = _currentPosX = e.screenX;
        _startPosY = _currentPosY = e.screenY;

        if (_currentTransition != null) {
            _currentTransition.stop();
            _currentTransition = null;
        }

        _drag = true;
    }

    private function _onMouseMove(e:MouseEvent):Void {
        var newX:Float = e.screenX;
        var newY:Float = e.screenY;

        _applyOffsetPosition(e.screenX, e.screenY);

        _currentPosX = newX;
        _currentPosY = newY;
    }

    private function _onMouseUp(e:MouseEvent):Void {
        if (_drag == false) {
            return;
        }

        _drag = false;

        Screen.instance.unregisterEvent(MouseEvent.MOUSE_MOVE, _onMouseMove);
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_UP, _onMouseUp);

        var currentComponent:Component = getComponentAt(_selectedIndex);

        switch (_transitionMode) {
            case TransitionMode.VERTICAL_SLIDE:
                if (currentComponent.top > height * percentToChange / 100) {
                    selectedIndex -= 1;
                } else if (currentComponent.top < -height * percentToChange / 100) {
                    selectedIndex += 1;
                } else if (currentComponent.top != paddingTop) {
                        var currentIndex:Int = _selectedIndex;
                        _selectedIndex = currentComponent.top > paddingTop ? _selectedIndex - 1 : _selectedIndex + 1;
                        selectedIndex = currentIndex;
                }

            case _:

                if (currentComponent.left > width * percentToChange / 100) {
                    selectedIndex -= 1;
                } else if (currentComponent.left < -width * percentToChange / 100) {
                    selectedIndex += 1;
                } else if (currentComponent.left != paddingLeft) {
                        var currentIndex:Int = _selectedIndex;
                        _selectedIndex = currentComponent.left > paddingLeft ? _selectedIndex - 1 : _selectedIndex + 1;
                        selectedIndex = currentIndex;
                }
        }

        if (MathUtil.distance(_startPosX, _startPosY, _currentPosX, _currentPosY) < 1 * Toolkit.pixelsPerRem * Toolkit.scale) {
            dispatch(new MouseEvent(MouseEvent.CLICK));
        }
    }

    //******************************************************************************************
    // Internals
    //******************************************************************************************

    private function _applyOffsetPosition(screenX:Float, screenY:Float):Void {
        var childrenCount:Int = childComponents.length;
        var currentComponent = getComponentAt(_selectedIndex);

        switch (_transitionMode) {
            case TransitionMode.VERTICAL_SLIDE:
                var offset:Float = screenY - _currentPosY;
                var newTop:Float = currentComponent.top + offset;
                if (((newTop >= paddingTop) && (offset > 0 && selectedIndex == 0))
                    || ((newTop <= paddingTop) && (offset < 0 && selectedIndex == childrenCount - 1))) {
                    newTop = paddingTop;
                }

                currentComponent.top = newTop;

                if (selectedIndex > 0) {
                    var previousComponent = getComponentAt(selectedIndex - 1);
                    var top:Float = currentComponent.top - previousComponent.height - paddingBottom;
                    var hidden:Bool = (top + previousComponent.height <= 0 || top + previousComponent.height >= height);
                    if (previousComponent.hidden != hidden) {
                        previousComponent.includeInLayout = !hidden;
                        previousComponent.hidden = hidden;
                    }

                    previousComponent.left = paddingTop;
                    previousComponent.top = top;
                }

                if (selectedIndex < childrenCount - 1) {
                    var nextComponent = getComponentAt(selectedIndex + 1);
                    var top:Float  = currentComponent.top + currentComponent.height + paddingTop;
                    var hidden:Bool = (top <= 0 || top >= width);
                    if (nextComponent.hidden != hidden) {
                        nextComponent.includeInLayout = !hidden;
                        nextComponent.hidden = hidden;
                    }

                    nextComponent.left = paddingTop;
                    nextComponent.top = top;
                }
            case _:
                var offset:Float = screenX - _currentPosX;
                var newLeft:Float = currentComponent.left + offset;
                if (((newLeft >= paddingLeft) && (offset > 0 && selectedIndex == 0))
                    || ((newLeft <= paddingLeft) && (offset < 0 && selectedIndex == childrenCount - 1))) {
                    newLeft = paddingLeft;
                }

                currentComponent.left = newLeft;

                if (selectedIndex > 0) {
                    var previousComponent = getComponentAt(selectedIndex - 1);
                    var left:Float = currentComponent.left - previousComponent.width - paddingRight;
                    var hidden:Bool = (left + previousComponent.width <= 0 || left + previousComponent.width >= width);
                    if (previousComponent.hidden != hidden) {
                        previousComponent.includeInLayout = !hidden;
                        previousComponent.hidden = hidden;
                    }

                    previousComponent.left = left;
                    previousComponent.top = paddingTop;
                }

                if (selectedIndex < childrenCount - 1) {
                    var nextComponent = getComponentAt(selectedIndex + 1);
                    var left:Float  = currentComponent.left + currentComponent.width + paddingLeft;
                    var hidden:Bool = (left <= 0 || left >= width);
                    if (nextComponent.hidden != hidden) {
                        nextComponent.includeInLayout = !hidden;
                        nextComponent.hidden = hidden;
                    }

                    nextComponent.left = left;
                    nextComponent.top = paddingTop;
                }
        }
    }
}