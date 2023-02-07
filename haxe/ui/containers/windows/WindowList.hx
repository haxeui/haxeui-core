package haxe.ui.containers.windows;

import haxe.ui.events.MouseEvent;
import haxe.ui.geom.Size;
import haxe.ui.core.Component;
import haxe.ui.components.Image;
import haxe.ui.components.Button;
import haxe.ui.behaviours.DataBehaviour;

@:xml('
    <hbox width="100%">
        <!--
        <label text="Windows:" verticalAlign="center" />
        -->
        <hbox id="openWindows" width="100%" height="100%" style="spacing:0" />
    </hbox>
')
class WindowList extends HBox {
    public var windowManager:WindowManager = null;
    private var _windowToItemMap:Map<Window, WindowListItem> = new Map<Window, WindowListItem>();

    private override function onReady() {
        super.onReady();
        if (windowManager == null) {
            windowManager = WindowManager.instance;
        }

        windowManager.registerEvent(WindowEvent.WINDOW_ADDED, onWindowAdded);
        windowManager.registerEvent(WindowEvent.WINDOW_CLOSED, onWindowClosed);
        windowManager.registerEvent(WindowEvent.WINDOW_ACTIVATED, onWindowActivated);
    }

    private function onWindowAdded(event:WindowEvent) {
        var item = new WindowListItem();
        var window = cast(event.target, Window);
        window.registerEvent(WindowEvent.WINDOW_TITLE_CHANGED, onWindowTitleChanged);
        item.text = window.title;
        item.icon = window.icon;
        item.relatedWindow = window;
        openWindows.addComponent(item);

        _windowToItemMap.set(window, item);
    }

    private function onWindowClosed(event:WindowEvent) {
        var window = cast(event.target, Window);
        window.unregisterEvent(WindowEvent.WINDOW_TITLE_CHANGED, onWindowTitleChanged);
        var item = _windowToItemMap.get(window);
        openWindows.removeComponent(item);
        _windowToItemMap.remove(window);
    }

    private function onWindowActivated(event:WindowEvent) {
        var window = cast(event.target, Window);
        var item = _windowToItemMap.get(window);
        if (item != null) {
            item.selected = true;
        }
    }

    private function onWindowTitleChanged(event:WindowEvent) {
        var window = cast(event.target, Window);
        var item = _windowToItemMap.get(window);
        if (item != null) {
            item.text = window.title;
        }
    }
}

@:composite(WindowListItemLayout)
private class WindowListItem extends Button {
    public var relatedWindow:Window;

    public function new() {
        super();
        toggle = true;
        componentGroup = "windowlist";
        selected = true;

        iconPosition = "far-left";
        var image = new Image();
        image.id = "window-list-close-button";
        image.addClass("window-list-close-button");
        image.includeInLayout = false;
        image.scriptAccess = false;
        image.onClick = onCloseClicked;
        image.registerEvent(MouseEvent.MOUSE_DOWN, function(event:MouseEvent) {
            event.cancel();
        });
        addComponent(image);

        this.onChange = function(_) {
            if (this.selected == true) {
                var windowList = findAncestor(WindowList);
                if (relatedWindow.minimized) {
                    windowList.windowManager.restoreWindow(relatedWindow);
                }
                windowList.windowManager.bringToFront(relatedWindow);
            }
        }

        var events = cast(this._internalEvents, ButtonEvents);
        events.recursiveStyling = false;
    }

    private function onCloseClicked(event:MouseEvent) {
        event.cancel();
        var windowList = findAncestor(WindowList);
        windowList.windowManager.closeWindow(relatedWindow);
    }
}

private class WindowListItemLayout extends ButtonLayout {
    private override function repositionChildren() {
        super.repositionChildren();

        var image = _component.findComponent("window-list-close-button", Image, false);
        if (image != null && image.hidden == false && component.componentWidth > 0) {
            image.top = Std.int((component.componentHeight / 2) - (image.componentHeight / 2)) + marginTop(image) - marginBottom(image);
            image.left = component.componentWidth - image.componentWidth - paddingRight + marginLeft(image) - marginRight(image);
        }
    }

    public override function calcAutoSize(exclusions:Array<Component> = null):Size {
        var size = super.calcAutoSize(exclusions);

        var image = _component.findComponent("window-list-close-button", Image, false);
        if (image != null && image.hidden == false) {
            size.width += image.width + horizontalSpacing;
        }

        return size;
    }
}
