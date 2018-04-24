package haxe.ui.containers;

import haxe.ui.core.ItemRenderer;
import haxe.ui.components.Button;
import haxe.ui.components.Label;
import haxe.ui.containers.ScrollView2;
import haxe.ui.core.Component;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.ScrollEvent;
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
        _rendererPool = [];

        registerEvent(ScrollEvent.CHANGE, function(e) {
            invalidateData();
        });
    }

    private var _rendererPool:Array<ItemRenderer>;
    private var _firstIndex:Int = -1;
    private var _lastIndex:Int = -1;

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
                    var item:ItemRenderer = cast contents.childComponents[n];
                    if (Std.is(item, cls)) {
                    } else {
                        removeComponent(item);
                        var item = Type.createInstance(cls, []);
                        addComponentAt(item, n);
                    }

                    item.data = data;
                } else {
                    var cls = itemClass(n, data);
                    var item:ItemRenderer = cast Type.createInstance(cls, []);
                    item.data = data;
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

            checkVisibleRenderers();

            //TODO - variable itemHeight?
            var dataSize:Int = _dataSource.size;
            var verticalSpacing = contents.layout.verticalSpacing;
            var viewSize = Math.ceil(contents.height / (itemHeight + verticalSpacing));
            var usableSize = layout.usableSize;
            var scrollMax = (dataSize * itemHeight + ((dataSize - 1) * verticalSpacing)) - usableSize.height;
            if (scrollMax < 0) {
                scrollMax = 0;
            }
            vscrollMax = scrollMax;
            vscrollPageSize = (usableSize.height / (scrollMax + usableSize.height)) * scrollMax;

            // TODO: temp
            contents.height = usableSize.height;
            contents.width = usableSize.width;

            var start = Std.int(vscrollPos / (itemHeight + verticalSpacing));
            if (start < 0) {
                start = 0;
            }
            var end = start + viewSize + 1;
            if (end > dataSize) {
                end = dataSize;
            }

            _firstIndex = start;
            _lastIndex = end;

            var i = 0;
            for (n in start...end) {
                var data:Dynamic = _dataSource.get(n);

                var item:ItemRenderer = null;
                var cls = itemClass(n, data);
                if (contents.childComponents.length <= i) {
                    item = getRenderer(cls);
                    addComponent(item);
                } else {
                    item = cast contents.childComponents[i];
                    item.removeClass("even");
                    item.removeClass("odd");

                    //Renderers are always ordered
                    if (!Std.is(item, cls)) {
                        item = getRenderer(cls);
                        addComponentAt(item, i);
                    } else if (item.itemIndex != n) {
                        setComponentIndex(item, i);
                    }
                }

                item.data = data;
                item.itemIndex = n;
                item.top = (n * (itemHeight + verticalSpacing)) - vscrollPos;
                item.addClass(n % 2 == 0 ? "even" : "odd");

                i++;
            }

            while (contents.childComponents.length > i) {
                removeRenderer(cast contents.childComponents[contents.childComponents.length - 1]);    // remove last
            }
        }

        contents.unlockLayout();

    }

    public var itemHeight = 30;


    public var special:Bool = false;

    private function itemClass(index:Int, data:Dynamic):Class<Component> { // all temp
//        return Renderer1;
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

    private function checkVisibleRenderers() {
        var contents:Component = findComponent("scrollview-contents", false, "css");
        if (_firstIndex >= 0) {
            while (contents.childComponents.length > 0 && !isRendererVisible(contents.childComponents[0])) {
                removeRenderer(cast contents.childComponents[0]);
                ++_firstIndex;
            }
        }

        if (_lastIndex >= 0) {
            while (contents.childComponents.length > 0 && !isRendererVisible(contents.childComponents[contents.childComponents.length - 1])) {
                removeRenderer(cast contents.childComponents[contents.childComponents.length - 1]);
                --_lastIndex;
            }
        }
    }

    private function isRendererVisible(renderer:Component):Bool {
        return renderer.top < componentHeight &&
        renderer.top + renderer.componentHeight >= 0 &&
        renderer.left < componentWidth &&
        renderer.left + renderer.componentWidth >= 0;
    }

    private function getRenderer(cls:Class<Component>):ItemRenderer {
        for (i in 0..._rendererPool.length) {
            var renderer = _rendererPool[i];
            if (Std.is(renderer, cls)) {
                _rendererPool.splice(i, 1);
                return renderer;
            }
        }

        var instance = Type.createInstance(cls, []);
        if(!Std.is(instance, ItemRenderer))
            throw 'Renderer isn\'t a ItemRenderer class';

        return cast(instance, ItemRenderer);
    }

    private function removeRenderer(renderer:ItemRenderer) {
        removeComponent(renderer);
        renderer.itemIndex = -1;
        _rendererPool.push(cast(renderer, ItemRenderer));
    }
}

private class RendererTest extends ItemRenderer {   // TODO: temp

    public function new() {
        super();

        percentWidth = 100;
        componentHeight = 30;
    }

    override private function validateData() {
        super.validateData();

        if (data != null) {
            findComponent(Label, true).text = data.text;
            findComponent(Button, true).text = data.text;
        }
    }

    override private function validateLayout():Bool {
        return super.validateLayout();
    }

}

private class Renderer1 extends RendererTest { // TODO: temp
    public function new() {
        super();

        percentWidth = 100;
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

private class Renderer2 extends RendererTest { // TODO: temp
    public function new() {
        super();

        percentWidth = 100;
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


private class Renderer3 extends RendererTest { // TODO: temp
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