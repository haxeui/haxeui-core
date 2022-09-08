package haxe.ui.layouts;

import haxe.ui.geom.Size;

class HorizontalLayout extends DefaultLayout {
    public function new() {
        super();
        _calcFullWidths = true;
        _roundFullWidths = true;
    }

    private override function repositionChildren() {
        var xpos = paddingLeft;

        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }

            var ypos:Float = 0;

            switch (verticalAlign(child)) {
                case "center":
                    ypos = ((component.componentHeight - child.componentHeight) / 2) + marginTop(child) - marginBottom(child);
                case "bottom":
                    if (child.componentHeight < component.componentHeight) {
                        ypos = component.componentHeight - (child.componentHeight + paddingBottom + marginTop(child));
                    }
                default:
                    ypos = paddingTop + marginTop(child);
            }

            child.moveComponent(xpos + marginLeft(child), ypos);
            xpos += child.componentWidth + horizontalSpacing;
        }
    }

    private override function get_usableSize():Size {
        var size:Size = super.get_usableSize();

        var visibleChildren = component.childComponents.length;
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                visibleChildren--;
                continue;
            }

            if (child.componentWidth > 0 && (child.percentWidth == null || fixedMinWidth(child) == true)) { // means its a fixed width, ie, not a % sized control
                size.width -= child.componentWidth + marginLeft(child) + marginRight(child);
            }
        }

        if (visibleChildren > 1) {
            size.width -= horizontalSpacing * (visibleChildren - 1);
        }

        if (size.width < 0) {
            size.width = 0;
        }

        return size;
    }
}