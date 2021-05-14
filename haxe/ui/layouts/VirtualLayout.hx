package haxe.ui.layouts;

import haxe.ui.containers.IVirtualContainer;
import haxe.ui.core.BasicItemRenderer;
import haxe.ui.core.Component;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.ItemRenderer;
import haxe.ui.events.UIEvent;
import haxe.ui.data.DataSource;

#if (haxe_ver >= 4.2)
import Std.isOfType;
#else
import Std.is as isOfType;
#end

class VirtualLayout extends ScrollViewLayout {
    private var _firstIndex:Int = -1;
    private var _lastIndex:Int = -1;
    private var _rendererPool:Array<ItemRenderer> = [];
    private var _sizeCache:Array<Float> = [];

    private var contents(get, null):Component;
    private function get_contents():Component {
        if (contents == null) {
            contents = findComponent("scrollview-contents", false, "css");
        }

        return contents;
    }

    private var dataSource(get, never):DataSource<Dynamic>;
    private function get_dataSource():DataSource<Dynamic> {
        return cast(_component, IDataComponent).dataSource;
    }

    private var itemWidth(get, null):Float;
    private function get_itemWidth():Float {
        var comp:IVirtualContainer = cast(_component, IVirtualContainer);
        if (comp.itemWidth > 0) {
            return comp.itemWidth;
        }

        var childComponents = contents.childComponents;
        var result:Float = 0;
        if (childComponents.length > 0) {
            result = childComponents[0].width;
            if (result <= 0) {
                childComponents[0].syncComponentValidation();
                result = childComponents[0].width;
            }
        }

        if (result > 0) {
            comp.itemWidth = result;
        } else {
            result = 1; //Min value to render items
        }

        return result;
    }

    private var itemHeight(get, null):Float;
    private function get_itemHeight():Float {
        var comp:IVirtualContainer = cast(_component, IVirtualContainer);
        if (comp.itemHeight > 0) {
            return comp.itemHeight;
        }

        var childComponents = contents.childComponents;
        var result:Float = 0;
        if (childComponents.length > 0) {
            result = childComponents[0].height;
            if (result <= 0) {
                childComponents[0].syncComponentValidation();
                result = childComponents[0].height;
            }
        }

        if (result <= 0) {
            result = 25; // more sensible default? Other wise you can get 100's of item renderers for 0 length datasource which will then be removed on 2nd pass
                         // may be ill-concieved
        }

        return result;
    }

    private var itemCount(get, null):Int;
    private function get_itemCount():Int {
        var comp:IVirtualContainer = cast(_component, IVirtualContainer);
        return (comp.itemCount >= 0) ? comp.itemCount : 0;
    }

    public override function refresh() {
        refreshData();

        super.refresh();
    }

    private function refreshData() {
        if (dataSource == null) {
            return;
        }

        var comp:IVirtualContainer = cast(_component, IVirtualContainer);
        if (comp.virtual == false) {
            refreshNonVirtualData();
        } else {
            refreshVirtualData();
        }
    }

    private var _lastItemRenderer:ItemRenderer = null;
    private function refreshNonVirtualData() {

        var comp:IVirtualContainer = cast(_component, IVirtualContainer);
        if (comp.itemRenderer != _lastItemRenderer) {
            _lastItemRenderer = comp.itemRenderer;
            contents.removeAllComponents();
        }

        var dataSource:DataSource<Dynamic> = dataSource;
        var contents:Component = this.contents;
        for (n in 0...dataSource.size) {
            var data:Dynamic = dataSource.get(n);
            var item:ItemRenderer = null;
            if (n < contents.childComponents.length) {
                item = cast(contents.childComponents[n], ItemRenderer);
                if (item.data == data) {
                    item.invalidateComponentData();
                    continue;
                }

                var cls = itemClass(n, data);
                if (isOfType(item, cls)) {
                } else {
                    removeRenderer(item);
                    item = getRenderer(cls, n);
                    contents.addComponentAt(item, n);
                }
            } else {
                var cls = itemClass(n, data);
                item = getRenderer(cls, n);
                contents.addComponent(item);
            }

            var className:String = n % 2 == 0 ? "even" : "odd";
            if (!item.hasClass(className)) {
                var inverseClassName = n % 2 == 0 ? "odd" : "even";
                item.removeClass(inverseClassName);
                item.addClass(className);
            }

            item.itemIndex = n;
            item.data = data;
        }

        while (dataSource.size < contents.childComponents.length) {
            var item:ItemRenderer = cast(contents.childComponents[contents.childComponents.length - 1], ItemRenderer);
            removeRenderer(item);    // remove last
        }
    }

    private function refreshVirtualData() {
        var comp:IVirtualContainer = cast(_component, IVirtualContainer);
        if (comp.itemRenderer != _lastItemRenderer) {
            _lastItemRenderer = comp.itemRenderer;
            contents.removeAllComponents();
            _rendererPool = [];
        }

        removeInvisibleRenderers();
        calculateRangeVisible();
        updateScroll();

        var dataSource:DataSource<Dynamic> = dataSource;
        var i = 0;
        for (n in _firstIndex..._lastIndex) {
            var data:Dynamic = dataSource.get(n);

            var item:ItemRenderer = null;
            var cls = itemClass(n, data);
            if (contents.childComponents.length <= i) {
                item = getRenderer(cls, n);
                contents.addComponent(item);
            } else {
                item = cast(contents.childComponents[i], ItemRenderer);

                //Renderers are always ordered
                if (!isOfType(item, cls)) {
                    item = getRenderer(cls, n);
                    contents.addComponentAt(item, i);
                } else if (item.itemIndex != n) {
                    if (_component.hasEvent(UIEvent.RENDERER_DESTROYED)) {
                        _component.dispatch(new UIEvent(UIEvent.RENDERER_DESTROYED, item));
                    }

                    _component.setComponentIndex(item, i);
                    item.itemIndex = n;

                    if (_component.hasEvent(UIEvent.RENDERER_CREATED)) {
                        _component.dispatch(new UIEvent(UIEvent.RENDERER_CREATED, item));
                    }
                }
            }

            var className:String = n % 2 == 0 ? "even" : "odd";
            if (!item.hasClass(className)) {
                var inverseClassName = n % 2 == 0 ? "odd" : "even";
                item.removeClass(inverseClassName);
                item.addClass(className);
            }

            item.data = data;

            i++;
        }

        while (contents.childComponents.length > i) {
            removeRenderer(cast(contents.childComponents[contents.childComponents.length - 1], ItemRenderer), false);    // remove last
        }
    }

    private function calculateRangeVisible() {

    }

    private function updateScroll() {

    }

    private function itemClass(index:Int, data:Dynamic):Class<ItemRenderer> {
        var comp:IVirtualContainer = cast(_component, IVirtualContainer);
        if (comp.itemRendererClass != null) {
            return comp.itemRendererClass;
        } else if (comp.itemRenderer != null) {
            return Type.getClass(comp.itemRenderer);
        } else {
            return BasicItemRenderer;
        }
    }

    @:access(haxe.ui.backend.ComponentImpl)
    private function getRenderer(cls:Class<ItemRenderer>, index:Int):ItemRenderer {
        var instance:ItemRenderer = null;
        var comp:IVirtualContainer = cast(_component, IVirtualContainer);
        if (comp.virtual == true) {
            for (i in 0..._rendererPool.length) {
                var renderer = _rendererPool[i];
                if (isOfType(renderer, cls)) {
                    _rendererPool.splice(i, 1);
                    instance = renderer;
                    break;
                }
            }
        }

        if (instance == null) {
            if (comp.itemRenderer != null && Type.getClass(comp.itemRenderer) == cls) {
                instance = comp.itemRenderer.cloneComponent();
            } else {
                instance = Type.createInstance(cls, []);
            }
        }

        instance.itemIndex = index;
        if (_component.hasEvent(UIEvent.RENDERER_CREATED)) {
            _component.dispatch(new UIEvent(UIEvent.RENDERER_CREATED, instance));
        }

        if (_component.hidden == false) {
            instance.handleVisibility(true);
        }
        return cast(instance, ItemRenderer);
    }

    private function removeRenderer(renderer:ItemRenderer, dispose:Bool = true) {
        _component.removeComponent(renderer, dispose);

        var comp:IVirtualContainer = cast(_component, IVirtualContainer);
        if (comp.virtual == true) {
            _rendererPool.push(cast(renderer, ItemRenderer));
        }

        if (_component.hasEvent(UIEvent.RENDERER_DESTROYED)) {
            _component.dispatch(new UIEvent(UIEvent.RENDERER_DESTROYED, renderer));
        }

        renderer.itemIndex = -1;
    }

    private function removeInvisibleRenderers() {
        var contents:Component = this.contents;
        if (_firstIndex >= 0) {
            while (contents.childComponents.length > 0 && !isRendererVisible(contents.childComponents[0])) {
                removeRenderer(cast(contents.childComponents[0], ItemRenderer), false);
                ++_firstIndex;
            }
        }

        if (_lastIndex >= 0) {
            while (contents.childComponents.length > 0 && !isRendererVisible(contents.childComponents[contents.childComponents.length - 1])) {
                removeRenderer(cast(contents.childComponents[contents.childComponents.length - 1], ItemRenderer), false);
                --_lastIndex;
            }
        }
    }

    private function isRendererVisible(renderer:Component):Bool {
        if (renderer == null) {
            return false;
        }
        return renderer.top < _component.componentHeight &&
        renderer.top + renderer.componentHeight >= 0 &&
        renderer.left < _component.componentWidth &&
        renderer.left + renderer.componentWidth >= 0;
    }

    private inline function isIndexVisible(index:Int):Bool {
        return index >= _firstIndex && index <= _lastIndex;
    }
}