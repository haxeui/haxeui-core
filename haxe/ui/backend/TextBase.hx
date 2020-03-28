package haxe.ui.backend;

import haxe.ui.assets.FontInfo;
import haxe.ui.core.Component;
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
    
    private var _dataSource:DataSource<String>;
    public var dataSource(get, set):DataSource<String>;
    private function get_dataSource():DataSource<String> {
        return _dataSource;
    }
    private function set_dataSource(value:DataSource<String>):DataSource<String> {
        _dataSource = value;
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
}