package haxe.ui.containers.menus;

import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.layouts.DefaultLayout;

@:composite(Builder, Layout)
class MenuSeparator extends Component {
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Builder extends CompositeBuilder {
    public override function create() {
        super.create();
        var line = new Component();
        line.scriptAccess = false;
        line.addClass("menuseparator-line");
        _component.addComponent(line);
    }
}

private class Layout extends DefaultLayout {
}
