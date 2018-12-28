package haxe.ui.layouts;

import haxe.ui.components.HorizontalScroll;
import haxe.ui.components.VerticalScroll;
import haxe.ui.containers.ScrollView;
import haxe.ui.core.Component;
import haxe.ui.core.Platform;
import haxe.ui.util.Size;

class ScrollViewLayout extends DefaultLayout {
    private override function repositionChildren() {
        var contents:Component = component.findComponent("scrollview-contents", false, "css");
        if (contents == null) {
            return;
        }

        var hscroll = component.findComponent(HorizontalScroll, false);
        var vscroll = component.findComponent(VerticalScroll, false);

        var ucx = innerWidth;
        var ucy = innerHeight;

        if (hscroll != null && hidden(hscroll) == false) {
            var ucy = innerHeight;
            hscroll.moveComponent(paddingLeft, ucy - hscroll.componentHeight + paddingBottom);
        }

        if (vscroll != null && hidden(vscroll) == false) {
            var ucx = innerWidth;
            vscroll.moveComponent(ucx - vscroll.componentWidth + paddingRight, paddingTop);
        }

        var contents:Component = component.findComponent("scrollview-contents", false, "css");
        if (contents != null) {
            contents.moveComponent(paddingLeft, paddingTop);
        }
    }

    private override function get_usableSize():Size {
        var size:Size = super.get_usableSize();
        var hscroll = component.findComponent(HorizontalScroll, false);
        var vscroll = component.findComponent(VerticalScroll, false);
        if (hscroll != null && hidden(hscroll) == false) {
            size.height -= hscroll.componentHeight;
        }
        if (vscroll != null && hidden(vscroll) == false) {
            size.width -= vscroll.componentWidth;
        }

        if (cast(component, ScrollView).native == true) {
            var contents:Component = component.findComponent("scrollview-contents", false, "css");
            if (contents != null) {
                if (contents.componentWidth > size.width) {
                    size.height -= Platform.hscrollHeight;
                }
                if (contents.componentHeight > size.height) {
                    size.width -= Platform.vscrollWidth;
                }
            }
        }

        return size;
    }

    public override function calcAutoSize(exclusions:Array<Component> = null):Size {
        var hscroll = component.findComponent(HorizontalScroll, false);
        var vscroll = component.findComponent(VerticalScroll, false);
        var size:Size = super.calcAutoSize([hscroll, vscroll]);
        if (hscroll != null && hscroll.hidden == false) {
            size.height += hscroll.componentHeight;
        }
        if (vscroll != null && vscroll.hidden == false) {
            size.width += vscroll.componentWidth;
        }

        if (cast(component, ScrollView).native == true) {
            var contents:Component = component.findComponent("scrollview-contents", false, "css");
            if (contents != null) {
                if (contents.width > component.width) {
                    size.height += Platform.hscrollHeight;
                }
                if (contents.height > component.height) {
                    size.width += Platform.vscrollWidth;
                }
            }
        }

        return size;
    }
}