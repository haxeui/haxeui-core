package haxe.ui.containers;

import haxe.ui.containers.HBox;
import haxe.ui.containers.Header;
import haxe.ui.containers.VBox;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.util.Variant;

@:composite(Builder)
@:xml('
<vbox>
    <box id="headerContainer" width="100%" hidden="true" />
    <box id="contentContainer" styleName="panel-content" width="100%" />
    <box id="footerContainer" width="100%" hidden="true" />
</vbox>
')
class Panel extends VBox {
    public override function get_text():String {
        var builder:Builder = cast(_compositeBuilder, Builder);
        return builder.header.text;
    }

    public override function set_text(value:String):String {
        var builder:Builder = cast(_compositeBuilder, Builder);
        builder.header.text = value;
        return value;
    }

    public override function get_icon():Variant {
        var builder:Builder = cast(_compositeBuilder, Builder);
        return builder.header.icon;
    }

    public override function set_icon(value:Variant):Variant {
        var builder:Builder = cast(_compositeBuilder, Builder);
        builder.header.icon = value;
        return value;
    }

    public override function set_percentHeight(value:Null<Float>):Null<Float> {
        contentContainer.percentHeight = 100;
        return super.set_percentHeight(value);
    }

    public function showFooter() {
        findComponent(PanelFooter, true).show();
    }

    public function hideFooter() {
        findComponent(PanelFooter, true).hide();
    }
}

@:xml('
<hbox width="100%">
    <image id="titleIcon" hidden="true" verticalAlign="center" />
    <label id="titleLabel" width="100%" hidden="true" verticalAlign="center" />
</hbox>
')
private class PanelHeader extends HBox {
    public override function get_text():String {
        return titleLabel.text;
    }

    public override function set_text(value:String):String {
        titleLabel.text = value;
        titleLabel.show();
        return value;
    }

    public override function get_icon():Variant {
        return titleIcon.resource;
    }

    public override function set_icon(value:Variant):Variant {
        titleIcon.resource = value;
        titleIcon.show();
        return value;
    }
}

@:xml('
<hbox width="100%">
</hbox>
')
private class PanelFooter extends HBox {
}

private class Builder extends CompositeBuilder {
    private var panel:Panel;
    
    public function new(panel:Panel) {
        super(panel);
        this.panel = panel;
    }

    public override function addComponent(child:Component):Component {
        if (child.id == "headerContainer" || child.id == "contentContainer" || child.id == "footerContainer") {
            return null;
        }

        if ((child is Header)) {
            for (c in child.childComponents) {
                header.addComponent(c);
            }
            return child;
        } else if  ((child is Footer)) {
            if (child.hidden) {
                footer.hide();
            }
            footer.styleString = child.styleString;
            for (c in child.childComponents) {
                footer.addComponent(c);
            }
            return child;
        }

        if (child.percentHeight != null) {
            panel.contentContainer.percentHeight = 100;
        }

        return panel.contentContainer.addComponent(child);
    }

    private var _header:PanelHeader = null;
    public var header(get, null):PanelHeader;
    private function get_header():PanelHeader {
        if (_header == null) {
            _header = new PanelHeader();
            panel.headerContainer.addComponent(_header);
            panel.headerContainer.show();
        }
        return _header;
    }

    private var _footer:PanelFooter = null;
    public var footer(get, null):PanelFooter;
    private function get_footer():PanelFooter {
        if (_footer == null) {
            _footer = new PanelFooter();
            panel.footerContainer.addComponent(_footer);
            panel.footerContainer.show();
        }
        return _footer;
    }
}

