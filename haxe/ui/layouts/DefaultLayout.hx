package haxe.ui.layouts;
import haxe.ui.styles.Style;
import haxe.ui.util.Size;

class DefaultLayout extends Layout {
    public function new() {
        super();
    }

    private override function resizeChildren() {
        var usableSize:Size = usableSize;
        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }

            var cx:Null<Float> = null;
            var cy:Null<Float> = null;

            if (child.percentWidth != null) {
                cx = (usableSize.width * child.percentWidth) / 100;
            }
            if (child.percentHeight != null) {
                cy = (usableSize.height * child.percentHeight) / 100;
            }

            child.resizeComponent(cx, cy);
        }
    }

    private override function repositionChildren() {
        var usableSize:Size = component.layout.usableSize;

        for (child in component.childComponents) {
            if (child.includeInLayout == false) {
                continue;
            }

            var xpos:Float = paddingLeft + marginLeft(child) - marginRight(child);
            var ypos:Float = paddingTop + marginTop(child) - marginBottom(child);

            switch (horizontalAlign(child)) {
                case "center":
                    xpos = ((component.componentWidth / 2) - (child.componentWidth / 2)) + marginLeft(child) - marginRight(child);
//                  xpos = ((usableSize.width / 2) - (child.componentWidth / 2)) + marginLeft(child) - marginRight(child);
                case "right":
                    xpos = component.componentWidth - (child.componentWidth + paddingRight + marginLeft(child) - marginRight(child));
//                  xpos = usableSize.width - (child.componentWidth + paddingRight + marginLeft(child) - marginRight(child));
            }

            switch (verticalAlign(child)) {
                case "center":
                    ypos = ((component.componentHeight / 2) - (child.componentHeight / 2)) + marginTop(child) - marginBottom(child);
//                  ypos = ((usableSize.height / 2) - (child.componentHeight / 2)) + marginTop(child) - marginBottom(child);
                case "bottom":
                    ypos = component.componentHeight - (child.componentHeight + paddingBottom + marginTop(child) - marginBottom(child));
//                  ypos = ((usableSize.height / 2) - (child.componentHeight / 2)) + marginTop(child) - marginBottom(child);
            }

            child.moveComponent(xpos, ypos);
        }
    }
}