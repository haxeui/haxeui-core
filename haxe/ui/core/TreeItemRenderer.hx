package haxe.ui.core;

import haxe.ui.components.Label;
import haxe.ui.containers.ListView;
import haxe.ui.containers.VBox;
import haxe.ui.data.DataSource;

class TreeItemRenderer extends ItemRenderer {
    public var button:Label = new Label();
    public var list:ListView = new ListView();
    public function new() {
        super();
        addClass("itemrenderer"); // TODO: shouldnt have to do this
        this.percentWidth = 100;

        var vbox:VBox = new VBox();
        vbox.percentWidth = 100;
        button.percentWidth = 100;
        button.onClick = function (e:UIEvent) {
            if (list.hidden) {
                list.show();
            }
            else {
                list.hide();
            }
        }

        list.id = "value";
        list.percentWidth = 90;
        vbox.addComponent(button);
        vbox.addComponent(list);

        addComponent(vbox);
    }

    private override function get_data():Dynamic {
        return _data;
    }
    private override function set_data(value:Dynamic):Dynamic {
        _data = value;
        button.text = value.label;
        list.dataSource = value.data;
        return value;
    }
}
