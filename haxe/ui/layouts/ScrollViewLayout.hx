package haxe.ui.layouts;

import haxe.ui.components.HorizontalScroll;
import haxe.ui.components.VerticalScroll;
import haxe.ui.containers.ScrollView;
import haxe.ui.core.Component;
import haxe.ui.core.Platform;
import haxe.ui.geom.Size;

class ScrollViewLayout extends DefaultLayout {
    private override function repositionChildren() {
        var contents:Component = component.findComponent("scrollview-contents", false, "css");
        if (contents == null) {
            return;
        }

        var hscroll = component.findComponent(HorizontalScroll, false);
        var vscroll = component.findComponent(VerticalScroll, false);
        var borderSize = this.borderSize;
        
        if (hscroll != null && hidden(hscroll) == false) {
            hscroll.moveComponent(paddingLeft + borderSize, Math.fround(component.componentHeight - hscroll.componentHeight - paddingBottom + marginTop(hscroll) - borderSize));
        }

        if (vscroll != null && hidden(vscroll) == false) {
            vscroll.moveComponent(Math.fround(component.componentWidth - vscroll.componentWidth - paddingRight + marginLeft(vscroll)) - borderSize, paddingTop + borderSize);
        }

        var contents:Component = component.findComponent("scrollview-contents", false, "css");
        if (contents != null) {
            contents.moveComponent(paddingLeft + borderSize, paddingTop + borderSize);
        }
    }

    private override function resizeChildren() {
        super.resizeChildren();

        var hscroll = component.findComponent(HorizontalScroll, false);
        var vscroll = component.findComponent(VerticalScroll, false);

        var usableSize:Size = usableSize;
        var percentWidth:Float = 100;
        var percentHeight:Float = 100;
        for (child in component.childComponents) {
            if (child != hscroll && child != vscroll) {
                continue;
            }

            var cx:Null<Float> = null;
            var cy:Null<Float> = null;

            if (child.percentWidth != null) {
                cx = (usableSize.width * child.percentWidth) / percentWidth - marginLeft(child) - marginRight(child);
            }
            if (child.percentHeight != null) {
                cy = (usableSize.height * child.percentHeight) / percentHeight - marginTop(child) - marginBottom(child);
            }

            if (fixedMinWidth(child) && child.percentWidth != null) {
                percentWidth -= child.percentWidth;
            }
            if (fixedMinHeight(child) && child.percentHeight != null) {
                percentHeight -= child.percentHeight;
            }

            child.resizeComponent(cx, cy);
        }
    }

    @:access(haxe.ui.backend.ComponentBase)
    private override function get_usableSize():Size {
        var size:Size = super.get_usableSize();
        var hscroll = component.findComponent(HorizontalScroll, false);
        var vscroll = component.findComponent(VerticalScroll, false);
        if (hscroll != null && hscroll.includeInLayout == true && hidden(hscroll) == false) {
            size.height -= hscroll.componentHeight - marginTop(hscroll);
        }
        if (vscroll != null && vscroll.includeInLayout == true && hidden(vscroll) == false) {
            size.width -= vscroll.componentWidth - marginLeft(vscroll);
        }

        if (cast(component, ScrollView).native == true || _component.isNativeScroller == true) {
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

        size.width += 1;
        
        var borderSize = this.borderSize;
        size.width -= borderSize * 2;
        size.height -= borderSize * 2;
        
        return size;
    }

    @:access(haxe.ui.backend.ComponentBase)
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

        if (cast(component, ScrollView).native == true || _component.isNativeScroller == true) {
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