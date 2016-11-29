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

    public var properties:Map<String, String> = new Map<String, String>();
    public var parent:ComponentInfo;
    public var children:Array<ComponentInfo> = new Array<ComponentInfo>();
    public var bindings:Array<ComponentBindingInfo> = new Array<ComponentBindingInfo>();

    public var scriptlets:Array<String> = new Array<String>();
    public var styles:Array<String> = new Array<String>();

    public var data:String;

    public var condition:String;
    
    public function new() {

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

    public function toString():String {
        var s = "";

        s = printInfo(this);

        return s;
    }

    public function validate() {

    }

    private static function printInfo(c:ComponentInfo, indent:Int = 0):String {
        var s:String = "";

        var i = "";
        for (x in 0...indent) {
            i += "  ";
        }

        s += i + '${c.type}:\n';
        if (c.id != null) {
            s += i + '  id: ${c.id}\n';
        }
        if (c.left != null) {
            s += i + '  left: ${c.left}\n';
        }
        if (c.top != null) {
            s += i + '  top: ${c.top}\n';
        }
        if (c.width != null) {
            s += i + '  width: ${c.width}\n';
        }
        if (c.height != null) {
            s += i + '  height: ${c.height}\n';
        }
        if (c.percentWidth != null) {
            s += i + '  percentWidth: ${c.percentWidth}\n';
        }
        if (c.percentHeight != null) {
            s += i + '  percentHeight: ${c.percentHeight}\n';
        }
        if (c.text != null) {
            s += i + '  text: ${c.text}\n';
        }
        if (c.style != null) {
            s += i + '  style: ${c.style}\n';
        }
        if (c.styleNames != null) {
            s += i + '  styleNames: ${c.styleNames}\n';
        }
        for (propName in c.properties.keys()) {
            var propValue = c.properties.get(propName);
            s += i + '  ${propName}: ${propValue}\n';
        }

        if (c.styles.length > 0) {
            s += i + '  styles count: ${c.styles.length}\n';
        }
        if (c.scriptlets.length > 0) {
            s += i + '  scriptlets count: ${c.scriptlets.length}\n';
        }

        if (c.bindings.length > 0) {
            s += i + '  bindings:\n';
            for (b in c.bindings) {
                s += i + '    source: ${b.source}, target: ${b.target}, transform: ${b.transform}\n';
            }
        }

        if (c.children.length > 0) {
            s += i + '  children:\n';
            for (child in c.children) {
                s += printInfo(child, indent + 2);
            }
        }

        return s;
    }
}

class ComponentBindingInfo {
    public function new() {
    }

    public var source:String;
    public var target:String;
    public var transform:String;
}