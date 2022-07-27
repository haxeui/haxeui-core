package haxe.ui.backend;

import haxe.ui.assets.FontInfo;
import haxe.ui.core.Component;
import haxe.ui.core.TextDisplay;
import haxe.ui.core.TextDisplay.TextDisplayData;
import haxe.ui.core.TextInput.TextInputData;
import haxe.ui.data.DataSource;
import haxe.ui.styles.Style;

@:dox(hide) @:noCompletion
class TextBase {
    public var parentComponent:Component;

    private var _displayData:TextDisplayData = new TextDisplayData();
    private var _inputData:TextInputData = new TextInputData();

    private var _text:String;
    private var _htmlText:String = null;
    private var _left:Float = 0;
    private var _top:Float = 0;
    private var _width:Float = 0;
    private var _height:Float = 0;
    private var _textWidth:Float = 0;
    private var _textHeight:Float = 0;
    private var _textStyle:Style;
    private var _fontInfo:FontInfo;

    public function new() {
    }

    public function focus() {
    }

    public function blur() {
    }

    public function dispose() {
        if (parentComponent != null) {
            parentComponent = null;
        }
    }
    
    private var _dataSource:DataSource<String>;
    public var dataSource(get, set):DataSource<String>;
    private function get_dataSource():DataSource<String> {
        return _dataSource;
    }
    private function set_dataSource(value:DataSource<String>):DataSource<String> {
        _dataSource = value;
        return value;
    }

    public var supportsHtml(get, null):Bool;
    private function get_supportsHtml():Bool {
        return false;
    }

    public var caretIndex(get, set):Int;
    private function get_caretIndex():Int {
        return 0;
    }
    private function set_caretIndex(value:Int):Int {
        return value;
    }
    
    public var selectionStartIndex(get, set):Int;
    private function get_selectionStartIndex():Int {
        return 0;
    }
    private function set_selectionStartIndex(value:Int):Int {
        return value;
    }
    
    public var selectionEndIndex(get, set):Int;
    private function get_selectionEndIndex():Int {
        return 0;
    }
    private function set_selectionEndIndex(value:Int):Int {
        return value;
    }
    
    //***********************************************************************************************************
    // Validation functions
    //***********************************************************************************************************

    private function validateData() {
    }

    private function validateStyle():Bool {
        return false;
    }

    private function validatePosition() {
    }

    private function validateDisplay() {
    }

    private function measureText() {
    }
    
    // this default implementation is probably quite expensive, it would make sense for 
    // backends to override this method and us something more effecient (if possible)
    // but as a fall back its OK - plus it will usually never be called anyway (only
    // for Label::isComponentClipped)
    public function measureTextWidth():Float {
        var textDisplay = new TextDisplay();
        
        textDisplay._textStyle = this._textStyle;
        textDisplay._fontInfo = this._fontInfo;
        textDisplay.validateStyle();
        
        textDisplay._text = this._text;
        textDisplay.validateData();
        
        textDisplay.measureText();
        return textDisplay._textWidth;
    }
}