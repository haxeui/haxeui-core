package haxe.ui.backend;

import haxe.ui.core.Component;
import haxe.ui.core.ComponentBounds;
import haxe.ui.core.ImageDisplay;
import haxe.ui.core.TextDisplay;
import haxe.ui.core.TextInput;
import haxe.ui.events.UIEvent;
import haxe.ui.geom.Point;
import haxe.ui.geom.Rectangle;
import haxe.ui.styles.Style;

@:dox(hide) @:noCompletion
class ComponentBase extends ComponentBounds {
    //***********************************************************************************************************
    // Default impl
    //***********************************************************************************************************
    private function handleCreate(native:Bool) {

    }

    private function handlePosition(left:Null<Float>, top:Null<Float>, style:Style) {

    }

    private function handleSize(width:Null<Float>, height:Null<Float>, style:Style) {

    }

    private function handleReady() {

    }

    private function handleClipRect(value:Rectangle) {

    }

    private function handleVisibility(show:Bool) {

    }

    private function getComponentOffset():Point {
        return new Point(0, 0);
    }

    private var isNativeScroller(get, null):Bool;
    private function get_isNativeScroller():Bool {
        return false;
    }

    private var isScroller(get, null):Bool;
    private function get_isScroller():Bool {
        return false;
    }

    private function handleFrameworkProperty(id:String, value:Any) {

    }

    //***********************************************************************************************************
    // Display tree
    //***********************************************************************************************************

    private function handleSetComponentIndex(child:Component, index:Int) {

    }

    private function handleAddComponent(child:Component):Component {
        return child;
    }

    private function handleAddComponentAt(child:Component, index:Int):Component {
        return child;
    }

    private function handleRemoveComponent(child:Component, dispose:Bool = true):Component {
        return child;
    }

    private function handleRemoveComponentAt(index:Int, dispose:Bool = true):Component {
        return null;
    }

    private function applyStyle(style:Style) {
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    private override function mapEvent(type:String, listener:UIEvent->Void) {
    }

    private override function unmapEvent(type:String, listener:UIEvent->Void) {

    }

    //***********************************************************************************************************
    // Text related
    //***********************************************************************************************************
    @:noCompletion private var _textDisplay:TextDisplay;
    @:dox(group = "Backend")
    public function createTextDisplay(text:String = null):TextDisplay {
        if (_textDisplay == null) {
            _textDisplay = new TextDisplay();
            _textDisplay.parentComponent = cast(this, Component);
        }
        if (text != null) {
            _textDisplay.text = text;
        }
        return _textDisplay;
    }

    @:dox(group = "Backend")
    public override function getTextDisplay():TextDisplay {
        return createTextDisplay();
    }

    @:dox(group = "Backend")
    public override function hasTextDisplay():Bool {
        return (_textDisplay != null);
    }

    @:noCompletion private var _textInput:TextInput;
    @:dox(group = "Backend")
    public function createTextInput(text:String = null):TextInput {
        if (_textInput == null) {
            _textInput = new TextInput();
            _textInput.parentComponent = cast(this, Component);
        }
        if (text != null) {
            _textInput.text = text;
        }
        return _textInput;
    }

    @:dox(group = "Backend")
    public override function getTextInput():TextInput {
        return createTextInput();
    }

    @:dox(group = "Backend")
    public override function hasTextInput():Bool {
        return (_textInput != null);
    }

    //***********************************************************************************************************
    // Image related
    //***********************************************************************************************************
    @:noCompletion private var _imageDisplay:ImageDisplay;
    @:dox(group = "Backend")
    public function createImageDisplay():ImageDisplay {
        if (_imageDisplay == null) {
            _imageDisplay = new ImageDisplay();
            _imageDisplay.parentComponent = cast(this, Component);
        }
        return _imageDisplay;
    }

    @:dox(group = "Backend")
    public override function getImageDisplay():ImageDisplay {
        return createImageDisplay();
    }

    @:dox(group = "Backend")
    public override function hasImageDisplay():Bool {
        return (_imageDisplay != null);
    }

    @:dox(group = "Backend")
    public function removeImageDisplay() {
        if (_imageDisplay != null) {
            _imageDisplay.dispose();
            _imageDisplay = null;
        }
    }

    //***********************************************************************************************************
    // Misc
    //***********************************************************************************************************

    @:dox(group = "Backend")
    public function handlePreReposition() {
    }

    @:dox(group = "Backend")
    public function handlePostReposition() {
    }

    //***********************************************************************************************************
    // Properties
    //***********************************************************************************************************
    /**
     Gets a property that is associated with all classes of this type
    **/
    @:dox(group = "Internal")
    public function getClassProperty(name:String):String {
        var v = null;
        if (_classProperties != null) {
            v = _classProperties.get(name);
        }
        if (v == null) {
            var c = Type.getClassName(Type.getClass(this)).toLowerCase() + "." + name;
            v = Toolkit.properties.get(c);
        }
        return v;
    }

    @:noCompletion private var _classProperties:Map<String, String>;
    /**
     Sets a property that is associated with all classes of this type
    **/
    @:dox(group = "Internal")
    public function setClassProperty(name:String, value:String) {
        if (_classProperties == null) {
            _classProperties = new Map<String, String>();
        }
        _classProperties.set(name, value);
    }

    @:noCompletion private var _hasNativeEntry:Null<Bool>;
    private var hasNativeEntry(get, null):Bool;
    private function get_hasNativeEntry():Bool {
        if (_hasNativeEntry == null) {
            _hasNativeEntry = (getNativeConfigProperty(".@id") != null);
        }
        return _hasNativeEntry;
    }

    private function getNativeConfigProperty(query:String, defaultValue:String = null):String {
        query = 'component[id=${nativeClassName}]${query}';
        return Toolkit.nativeConfig.query(query, defaultValue, this);
    }

    private function getNativeConfigPropertyBool(query:String, defaultValue:Bool = false):Bool {
        query = 'component[id=${nativeClassName}]${query}';
        return Toolkit.nativeConfig.queryBool(query, defaultValue, this);
    }

    private function getNativeConfigProperties(query:String = ""):Map<String, String> {
        query = 'component[id=${nativeClassName}]${query}';
        return Toolkit.nativeConfig.queryValues(query, this);
    }

    @:noCompletion private var _className:String = null;
    public var className(get, null):String;
    private function get_className():String {
        if (_className != null) {
            return _className;
        }
        _className = Type.getClassName(Type.getClass(this));
        return _className;
    }

    @:noCompletion private var _nodeName:String = null;
    @:noCompletion private var nodeName(get, null):String;
    @:noCompletion private function get_nodeName():String {
        if (_nodeName != null) {
            return _nodeName;
        }
        _nodeName = className.split(".").pop().toLowerCase();
        return _nodeName;
    }
    
    @:noCompletion private var _nativeClassName:String = null;
    private var nativeClassName(get, null):String;
    private function get_nativeClassName():String {
        if (_nativeClassName != null) {
            return _nativeClassName;
        }

        var r:Class<Dynamic> = Type.getClass(this);
        while (r != null) {
            var c = Type.getClassName(r);
            var t = Toolkit.nativeConfig.query('component[id=${c}].@class', null, this);
            if (t != null) {
                _nativeClassName = c;
                break;
            }
            r = Type.getSuperClass(r);
            if (r == Component) {
                break;
            }
        }

        if (_nativeClassName == null) {
            _nativeClassName = className;
        }

        return _nativeClassName;
    }
}