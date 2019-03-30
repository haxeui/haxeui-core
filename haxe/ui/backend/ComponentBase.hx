package haxe.ui.backend;

import haxe.ui.containers.dialogs.Dialog2;
import haxe.ui.core.Component;
import haxe.ui.core.ComponentBounds;
import haxe.ui.core.ComponentLayout;
import haxe.ui.core.ComponentValidation;
import haxe.ui.core.ImageDisplay;
import haxe.ui.core.TextDisplay;
import haxe.ui.core.TextInput;
import haxe.ui.events.UIEvent;
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
    private var _textDisplay:TextDisplay;
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

    public override function getTextDisplay():TextDisplay {
        return createTextDisplay();
    }

    public override function hasTextDisplay():Bool {
        return (_textDisplay != null);
    }
    
    private var _textInput:TextInput;
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
    
    public override function getTextInput():TextInput {
        return createTextInput();
    }

    public override function hasTextInput():Bool {
        return (_textInput != null);
    }

    //***********************************************************************************************************
    // Image related
    //***********************************************************************************************************
    private var _imageDisplay:ImageDisplay;
    public function createImageDisplay():ImageDisplay {
        if (_imageDisplay == null) {
            _imageDisplay = new ImageDisplay();
            _imageDisplay.parentComponent = cast(this, Component);
        }
        return _imageDisplay;
    }

    public override function getImageDisplay():ImageDisplay {
        return createImageDisplay();
    }

    public override function hasImageDisplay():Bool {
        return (_imageDisplay != null);
    }

    public function removeImageDisplay() {
        if (_imageDisplay != null) {
            _imageDisplay.dispose();
            _imageDisplay = null;
        }
    }
    
    //***********************************************************************************************************
    // Misc
    //***********************************************************************************************************
    
    public function handlePreReposition() {
    }

    public function handlePostReposition() {
    }
    
    //***********************************************************************************************************
    // Properties
    //***********************************************************************************************************
    /**
     Gets a property that is associated with all classes of this type
    **/
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

    private var _classProperties:Map<String, String>;
    /**
     Sets a property that is associated with all classes of this type
    **/
    public function setClassProperty(name:String, value:String) {
        if (_classProperties == null) {
            _classProperties = new Map<String, String>();
        }
        _classProperties.set(name, value);
    }

    private var _hasNativeEntry:Null<Bool>;
    private var hasNativeEntry(get, null):Bool;
    private function get_hasNativeEntry():Bool {
        if (_hasNativeEntry == null) {
            _hasNativeEntry = (getNativeConfigProperty(".@id") != null);
        }
        return _hasNativeEntry;
    }
    
    private function getNativeConfigProperty(query:String, defaultValue:String = null):String {
        query = 'component[id=${className}]${query}';
        return Toolkit.nativeConfig.query(query, defaultValue, this);
    }

    private function getNativeConfigPropertyBool(query:String, defaultValue:Bool = false):Bool {
        query = 'component[id=${className}]${query}';
        return Toolkit.nativeConfig.queryBool(query, defaultValue, this);
    }

    private function getNativeConfigProperties(query:String = ""):Map<String, String> {
        query = 'component[id=${className}]${query}';
        return Toolkit.nativeConfig.queryValues(query, this);
    }

    public var className(get, null):String;
    private function get_className():String {
        if (Std.is(this, Dialog2)) {
            return Type.getClassName(Dialog2);
        }
        return Type.getClassName(Type.getClass(this));
    }
}