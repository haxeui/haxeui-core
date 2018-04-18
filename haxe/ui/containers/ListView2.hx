package haxe.ui.containers;

import haxe.ui.components.Button;
import haxe.ui.components.Label;
import haxe.ui.containers.ScrollView2;
import haxe.ui.core.Component;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.ScrollEvent;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.data.DataSource;
import haxe.ui.data.ListDataSource;
import haxe.ui.data.transformation.NativeTypeTransformer;
import haxe.ui.layouts.LayoutFactory;

class ListView2 extends ScrollView2 implements IDataComponent {
    private var _dataSource:DataSource<Dynamic>;
    public var dataSource(get, set):DataSource<Dynamic>;
    private function get_dataSource():DataSource<Dynamic> {
        if (_dataSource == null) {
            //_dataSource = new ArrayDataSource(new NativeTypeTransformer());
            _dataSource = new ListDataSource(new NativeTypeTransformer());
            _dataSource.onChange = onDataSourceChanged;
            //behaviourGet("dataSource");
        }
        return _dataSource;
    }
    private function set_dataSource(value:DataSource<Dynamic>):DataSource<Dynamic> {
        _dataSource = value;
        _dataSource.transformer = new NativeTypeTransformer();
        invalidateData();
        _dataSource.onChange = onDataSourceChanged;
        return value;
    }

    private function onDataSourceChanged() {
        //var contents:Component = findComponent("scrollview-contents", false, "css");
        //contents.height = _dataSource.size * itemHeight + ((_dataSource.size - 1) * 5);
        invalidateData();
    }
    
    public function new() { // TEMP!
        super();
        registerEvent(ScrollEvent.CHANGE, function(e) {
            invalidateData();
        });
    }
    
    private override function validateData() {
        super.validateData();

        if (_dataSource == null) {
            return;
        }
        
        var contents:Component = findComponent("scrollview-contents", false, "css");
        contents.lockLayout();
        
        if (virtual == false) {
            for (n in 0..._dataSource.size) {
                var data:Dynamic = _dataSource.get(n);
                
                if (n < contents.childComponents.length) {
                    var cls = itemClass(n, data);
                    var item = contents.childComponents[n];
                    if (Std.is(item, cls)) {
                        apply(item, data);
                    } else {
                        removeComponent(item);
                        var item = Type.createInstance(cls, []);
                        apply(item, data);
                        addComponentAt(item, n);
                    }
                } else {
                    var cls = itemClass(n, data);
                    var item = Type.createInstance(cls, []);
                    apply(item, data);
                    addComponent(item);
                }
            }
            
            while (_dataSource.size < contents.childComponents.length) {
                contents.removeComponent(contents.childComponents[contents.childComponents.length - 1]); // remove last
            }
        } else {
            if (Std.is(layout, Absolute) == false) {
                contents.layout = LayoutFactory.createFromName("absolute");
            }
            
            var dataSize:Int = _dataSource.size;
            var verticalSpacing = contents.layout.verticalSpacing;
            vscrollMax = (dataSize * itemHeight + ((dataSize - 1) * verticalSpacing)) - layout.usableHeight;

            // TODO: temp
            contents.height = layout.usableHeight;
            contents.width = layout.usableWidth;
            
            var start = Std.int(vscrollPos / (itemHeight + verticalSpacing));
            if (start < 0) {
                start = 0;
            }
            var viewSize = Math.ceil(contents.height / (itemHeight + verticalSpacing));
            var end = start + viewSize + 1;
            if (end > dataSize) {
                end = dataSize;
            }
            
            var i = 0;
            for (n in start...end) {
                var data:Dynamic = _dataSource.get(n);
                
                var item = null;
                if (contents.childComponents.length <= i) {
                    var cls = itemClass(n, data);
                    item = Type.createInstance(cls, []);
                    addComponent(item);
                } else {
                    item = contents.childComponents[i];
                    item.removeClass("even");
                    item.removeClass("odd");
                }
                
                var cls = itemClass(n, data);
                if (Std.is(item, cls)) {
                    apply(item, data);
                } else {
                    removeComponent(item);
                    var item = Type.createInstance(cls, []);
                    apply(item, data);
                    addComponentAt(item, i);
                }
                
                
                item.top = (n * (itemHeight + verticalSpacing)) - vscrollPos;
                item.addClass(n % 2 == 0 ? "even" : "odd");
                
                i++;
            }
            
            while (contents.childComponents.length > i) {
                contents.removeComponent(contents.childComponents[contents.childComponents.length - 1]); // remove last
            }
        }
        
        contents.unlockLayout();
        
    }
    
    public var itemHeight = 30;
    
    private function apply(c:Component, data:Dynamic) { // all temp
        c.findComponent(Label, true).text = data.text;
        c.findComponent(Button, true).text = data.text;
    }
    
    public var special:Bool = false;
    
    private function itemClass(index:Int, data:Dynamic):Class<Component> { // all temp
        return Renderer1;
        if (index == 3) {
            //return Renderer3;
        }
        
        if (index % 2 == 0) {
            return Renderer1;
        } else {
            return Renderer2;
        }
        
        return null;
    }
}

private class Renderer1 extends Component { // TODO: temp
    public function new() {
        super();
        
        componentWidth = 175;
        componentHeight = 30;
        //backgroundColor = 0xecf2f9;
        
        var hbox = new HBox();
        hbox.percentWidth = 100;
        
        var label = new Label();
        label.text = "Renderer1";
        label.percentWidth = 100;
        label.verticalAlign = "center";
        hbox.addComponent(label);
        
        var button = new Button();
        button.text = "Renderer1";
        button.verticalAlign = "center";
        hbox.addComponent(button);
        
        addComponent(hbox);
    }
}

private class Renderer2 extends Component { // TODO: temp
    public function new() {
        super();
        
        componentWidth = 175;
        componentHeight = 30;
        //backgroundColor = 0xCCFFCC;
        backgroundColor = 0xecf2f9;
        
        var hbox = new HBox();
        hbox.percentWidth = 100;

        var button = new Button();
        button.text = "Renderer2";
        button.verticalAlign = "center";
        
        var label = new Label();
        label.text = "Renderer2";
        label.percentWidth = 100;
        label.verticalAlign = "center";
        hbox.addComponent(label);
        hbox.addComponent(button);
        
        addComponent(hbox);
    }
}


private class Renderer3 extends Component { // TODO: temp
    public function new() {
        super();
        
        componentWidth = 180;
        componentHeight = 30;
        //backgroundColor = 0xFF0000;
        
        var hbox = new HBox();

        var button = new Button();
        button.text = "SPECIAL!";
        hbox.addComponent(button);
        
        var label = new Label();
        label.text = "SPECIAL!";
        hbox.addComponent(label);
        
        addComponent(hbox);
    }
}