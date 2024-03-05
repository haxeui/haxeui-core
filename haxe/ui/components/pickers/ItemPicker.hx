package haxe.ui.components.pickers;

import haxe.ui.components.Image;
import haxe.ui.containers.Box;
import haxe.ui.containers.HBox;
import haxe.ui.core.BasicItemRenderer;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.ICompositeInteractiveComponent;
import haxe.ui.core.IDataComponent;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.ItemRenderer;
import haxe.ui.core.Screen;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.data.DataSource;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.geom.Size;
import haxe.ui.layouts.DefaultLayout;

@:composite(ItemPickerBuilder, Layout)
class ItemPicker extends InteractiveComponent implements IDataComponent implements ICompositeInteractiveComponent {
    public var selectionType = "dropPanel";
    public var panelPosition = "auto";
    public var panelOrigin = "auto";
    public var panelWidth:Null<Float> = null;
    public var isPanelOpen:Bool = false;

    private var _dataSource:DataSource<Dynamic> = null;
    public var dataSource(get, set):DataSource<Dynamic>;
    private function get_dataSource():DataSource<Dynamic> {
        if (_dataSource == null) {
            _dataSource = new ArrayDataSource<Dynamic>();
            var builder:ItemPickerBuilder = cast(_compositeBuilder, ItemPickerBuilder);
            builder.handler.applyDataSource(_dataSource);
        }
        return _dataSource;
    }
    private function set_dataSource(value:DataSource<Dynamic>):DataSource<Dynamic> {
        _dataSource = value;
        var builder:ItemPickerBuilder = cast(_compositeBuilder, ItemPickerBuilder);
        builder.handler.applyDataSource(_dataSource);
        return value;
    }

    private var _panelSelectionEvent:String = UIEvent.CHANGE;
    public var panelSelectionEvent(get, set):String;
    private function get_panelSelectionEvent():String {
        return _panelSelectionEvent;
    }
    private function set_panelSelectionEvent(value:String):String {
        _panelSelectionEvent = value;
        var builder:ItemPickerBuilder = cast(_compositeBuilder, ItemPickerBuilder);
        builder.panelSelectionEvent = _panelSelectionEvent;
        return value;
    }

    public function showPanel() {
        var builder:ItemPickerBuilder = cast(_compositeBuilder, ItemPickerBuilder);
        builder.showPanel();
    }

    public function hidePanel() {
        var builder:ItemPickerBuilder = cast(_compositeBuilder, ItemPickerBuilder);
        builder.hidePanel();
    }
}

class ItemPickerHandler {
    public var builder:ItemPickerBuilder;
    public var picker:ItemPicker;
    public var renderer:Component;
    public var panel:Component;

    private function pausePanelEvents() {
        builder.pausePanelEvents();
    }

    private function resumePanelEvents() {
        builder.resumePanelEvents();
    }

    public function applyDataSource(ds:DataSource<Dynamic>) {
    }

    public function onPanelShown() {
    }

    public function onPanelHidden() {
    }

    public function onPanelSelection(event:UIEvent) {
    }
}

private class DefaultItemPickerRenderer extends HBox {
    private var _renderer:ItemRenderer = new BasicItemRenderer();
    private var _triggerIcon:Image = new Image();

    public function new() {
        super();

        addComponent(_renderer);
        _triggerIcon.scriptAccess = false;
        _triggerIcon.id = "itemPickerTriggerIcon";
        _triggerIcon.addClass("item-picker-trigger-icon");
        addComponent(_triggerIcon);
    }
}

class ItemPickerBuilder extends CompositeBuilder {
    private var picker:ItemPicker;

    public var renderer:Component = null;
    public var panel:Component = null;
    public var panelContainer:Box = new Box();
    public var handler:ItemPickerHandler = null;

    public function new(picker:ItemPicker) {
        super(picker);
        this.picker = picker;
        handler = Type.createInstance(handlerClass, []);
        handler.builder = this;
        handler.picker = picker;

        picker.registerEvent(MouseEvent.MOUSE_DOWN, onPickerMouseDown);
    }

    private function onPickerMouseDown(_) {
        picker.focus = true;
    }

    private var _panelSelectionEvent:String = UIEvent.CHANGE;
    public var panelSelectionEvent(get, set):String;
    private function get_panelSelectionEvent():String {
        return _panelSelectionEvent;
    }
    private function set_panelSelectionEvent(value:String):String {
        if (panel != null) {
            panel.unregisterEvent(_panelSelectionEvent, onPanelSelection);
        }
        _panelSelectionEvent = value;
        registerPanelEvents();
        return value;
    }

    public var triggerEvent(get, null):String;
    private function get_triggerEvent():String {
        return MouseEvent.MOUSE_DOWN;
    }

    public var triggerTarget(get, null):Component;
    private function get_triggerTarget():Component {
        var target = renderer.findComponent("itemPickerTrigger", Component);
        if (target != null) {
            picker.unregisterEvent(triggerEvent, onTrigger);
            picker.removeClass("item-picker-trigger");
            return target;
        }
        return picker;
    }

    public var handlerClass(get, null):Class<ItemPickerHandler>;
    private function get_handlerClass():Class<ItemPickerHandler> {
        return ItemPickerHandler;
    }

    public override function create() {
        super.create();
        var defaultRenderer = new DefaultItemPickerRenderer();
        defaultRenderer.id = "itemPickerRenderer";
        picker.addComponent(defaultRenderer);

        panelContainer.addClass("item-picker-container");
    }

    public override function onReady() {
        super.onReady();
    }

    public override function addComponent(child:Component):Component {
        if (child.id == "itemPickerRenderer" || child.id == "item-picker-renderer" || child.hasClass("item-picker-renderer")) {
            if (renderer != null) {
                picker.removeComponent(renderer);
            }

            child.id = "itemPickerRenderer";
            renderer = child;
            handler.renderer = renderer;
            registerTriggerEvents();
        } else {
            child.addClass("item-picker-data");
            panel = child;
            handler.panel = panel;
            panelContainer.addComponent(panel);
            registerPanelEvents();
            return child;
        }
        return null;
    }

    private function registerTriggerEvents() {
        triggerTarget.addClass("item-picker-trigger");
        if (!triggerTarget.hasEvent(triggerEvent, onTrigger)) {
            triggerTarget.registerEvent(triggerEvent, onTrigger);
        }
    }

    private function registerPanelEvents() {
        if (panel != null) {
            panel.registerEvent(panelSelectionEvent, onPanelSelection);
        }
    }

    public function pausePanelEvents() {
        if (panel != null) {
            panel.pauseEvent(panelSelectionEvent);
        }
    }

    public function resumePanelEvents() {
        if (panel != null) {
            panel.resumeEvent(panelSelectionEvent, true);
        }
    }

    private function onPanelSelection(event:UIEvent) {
        handler.onPanelSelection(event);
        if (!event.canceled) {
            var changeEvent = new UIEvent(UIEvent.CHANGE);
            changeEvent.relatedComponent = event.relatedComponent;
            changeEvent.relatedEvent = event;
            picker.dispatch(changeEvent);
        }
        hidePanel();
    }

    private function onTrigger(event:UIEvent) {
        //event.cancel();
        if (!_panelVisible) {
            picker.focus = true;
            showPanel();
        } else {
            hidePanel();
        }
    }

    private var _panelVisible:Bool = false;
    private var _panelFiller:Component = null;
    public function showPanel() {
        if (panel == null || panelContainer == null) {
            return;
        }

        picker.isPanelOpen = true;

        pausePanelEvents();
        picker.addClass("selected", true, true);
        if (picker.hasClass("rounded")) {
            panelContainer.addClass("rounded");
        }
        panelContainer.styleNames = picker.styleNames;
        handler.onPanelShown();
        panelContainer.addClass(picker.cssName + "-panel", true, true);
        panelContainer.opacity = 0;
        Screen.instance.addComponent(panelContainer);
        panelContainer.syncComponentValidation();
        panel.validateNow();
        panelContainer.validateNow();

        Toolkit.callLater(function() {
            positionPanel();
        });

        positionPanel();

        if (picker.animatable) {
            panelContainer.fadeIn();
        } else {
            panelContainer.opacity = 1;
        }
        Screen.instance.registerEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
        _panelVisible = true;

        resumePanelEvents();
    }

    private function positionPanel() {
        var panelPosition = "down";
        var panelOrigin = "left";
        var panelPosition = picker.panelPosition;
        var panelOrigin = picker.panelOrigin;
        var panelWidth:Null<Float> = picker.width;
        var panelHeight:Null<Float> = panel.height;

        if (picker.panelWidth != null) {
            panelWidth = picker.panelWidth;
        }

        if (panelPosition == "auto") {
            if (picker.screenTop + picker.height + panelHeight > Screen.instance.height) {
                panelPosition = "up";
            } else {
                panelPosition = "down";
            }
        }

        if (panelOrigin == "auto") {
            if (picker.screenLeft + panelWidth > Screen.instance.width) {
                panelOrigin = "right";
            } else {
                panelOrigin = "left";
            }
        }

        if (panelPosition == "down") {
            panelContainer.addClass("position-down");
        } else if (panelPosition == "up") {
            panelContainer.addClass("position-up");
        }

        panelContainer.syncComponentValidation();
        panel.validateNow();
        panelContainer.validateNow();

        var marginTop:Float = 0;
        var marginLeft:Float = 0;
        var marginBottom:Float = 0;
        var marginRight:Float = 0;
        var horizontalPadding:Float = 0;
        var verticalPadding:Float = 0;
        var borderSize:Float = 0;
        if (panelContainer.style != null) {
            marginTop = panelContainer.style.marginTop;
            marginLeft = panelContainer.style.marginLeft;
            marginBottom = panelContainer.style.marginBottom;
            marginRight = panelContainer.style.marginRight;
            horizontalPadding = panelContainer.style.paddingLeft + panelContainer.style.paddingRight;
            verticalPadding = panelContainer.style.paddingTop + panelContainer.style.paddingBottom;
            borderSize = panelContainer.style.borderTopSize;
        }

        if (_panelFiller == null) {
            _panelFiller = new Component();
            _panelFiller.addClass("item-picker-panel-filler");
            _panelFiller.includeInLayout = false;
            _panelFiller.height = borderSize;
            panelContainer.addComponent(_panelFiller);
        }

        var offset:Float = 0;
        if (panelContainer.style != null && panelContainer.style.borderRadiusTopRight != null) {
            offset = panelContainer.style.borderRadiusTopRight;
        }
        _panelFiller.width = panelWidth - picker.width - offset + 1;
        if (_panelFiller.width > 0) {
            _panelFiller.show();
        } else {
            _panelFiller.hide();
        }
        panel.width = panelWidth - horizontalPadding;

        if (panelOrigin == "left") {
            panelContainer.left = picker.screenLeft;
            _panelFiller.left = picker.width - borderSize;
        } else if (panelOrigin == "right") {
            panelContainer.left = picker.screenLeft + picker.width - panelWidth;
            _panelFiller.left = borderSize;
        }

        if (panelPosition == "down") {
            panelContainer.top = picker.screenTop + picker.height + marginTop;
            _panelFiller.top = 0;
        } else if (panelPosition == "up") {
            panelContainer.top = picker.screenTop - panelContainer.height - marginTop;
            _panelFiller.top = panelHeight + (verticalPadding - borderSize);
        }
    }

    public function hidePanel() {
        picker.isPanelOpen = false;

        if (picker.animatable) {
            /*
            panelContainer.fadeOut(function() {
                handler.onPanelHidden();
                picker.removeClass("selected", true, true);
                Screen.instance.removeComponent(panelContainer, false);
                Screen.instance.unregisterEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
            }, false);
            */
            handler.onPanelHidden();
            picker.removeClass("selected", true, true);
            Screen.instance.removeComponent(panelContainer, false);
            Screen.instance.unregisterEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
        } else {
            handler.onPanelHidden();
            picker.removeClass("selected", true, true);
            Screen.instance.removeComponent(panelContainer, false);
            Screen.instance.unregisterEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
        }
        _panelVisible = false;
    }

    private function onScreenMouseDown(event:MouseEvent) {
        if (triggerTarget.hitTest(event.screenX, event.screenY)) {
            return;
        }
        if (panelContainer.hitTest(event.screenX, event.screenY)) {
            return;
        }
        hidePanel();
    }
}

private class Layout extends DefaultLayout {
    public override function resizeChildren() {
        super.resizeChildren();

        var usableSize = this.usableSize;
        var renderer = findComponent("itemPickerRenderer", Component);
        if (renderer == null) {
            return;
        }
        if (!component.autoWidth) {
            renderer.width = usableSize.width;
            var itemText = findComponent("itemText", Component);
            if (itemText != null) {
                itemText.percentWidth = 100;
            }
        } else {

        }

        if (!component.autoHeight) {
            renderer.height = usableSize.height;
        } else {
        }
    }

    public override function repositionChildren() {
        super.repositionChildren();
    }

    /*
    public override function calcAutoSize(exclusions:Array<Component> = null):Size {
        var size = new Size();
        size.height = 50;
        size.width = 100;
        return size;
    }
    */
}

