package haxe.ui.parsers.ui;

class ComponentInfo {
    public var type:Null<String>;
    public var id:Null<String>;
    public var left:Null<Float>;
    public var top:Null<Float>;
    public var width:Null<Float>;
    public var height:Null<Float>;
    public var percentWidth:Null<Float>;
    public var percentHeight:Null<Float>;
    public var contentWidth:Null<Float>;
    public var contentHeight:Null<Float>;
    public var percentContentWidth:Null<Float>;
    public var percentContentHeight:Null<Float>;
    public var text:Null<String>;
    public var style:Null<String>;
    public var styleNames:Null<String>;
    public var composite:Null<Bool>;
    public var layoutName:Null<String>;

    public var properties:Map<String, String>;
    public var parent:ComponentInfo;
    public var children:Array<ComponentInfo>;
    public var bindings:Array<ComponentBindingInfo>;

    public var scriptlets:Array<String>;
    public var styles:Array<String>;

    public var data:String;

    public var condition:String;

    public function new() {
        properties = new Map<String, String>();
        children = [];
        bindings = [];
        scriptlets = [];
        styles = [];
    }

    public var styleString(get, never):String;
    private function get_styleString():String {
        if (style == null) {
            return null;
        }
        return StringTools.replace(style, "\"", "'");
    }

    public var dataString(get, never):String;
    private function get_dataString():String {
        if (data == null) {
            return null;
        }
        return StringTools.replace(data, "\"", "'");
    }

    public function findRootComponent():ComponentInfo {
        var r = this;
        while (r.parent != null) {
            r = r.parent;
        }
        return r;
    }

    public function validate() {

    }
}

class ComponentBindingInfo {
    public function new() {
    }

    public var source:String;
    public var target:String;
    public var transform:String;
}