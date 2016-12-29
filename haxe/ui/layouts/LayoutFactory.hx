package haxe.ui.layouts;

class LayoutFactory {
    public static function createFromName(name:String):Layout {
        switch (name) { // TODO: change this to a map, and make populate from module.xml (like components) - would also allow other modules to add layouts (as well as manually "registering" layouts)
            case "vertical":
                return new VerticalLayout();
            case "horizontal":
                return new HorizontalLayout();
            case "continuous horizontal" | "continuousHorizontal":
                return new HorizontalContinuousLayout();
            case "absolute":
                return new AbsoluteLayout();
            case "vertical grid" | "verticalgrid":
                return new VerticalGridLayout();
            case "horizontal grid" | "horizontalgrid":
                return new HorizontalGridLayout();
        }

        return new DefaultLayout();
    }
}