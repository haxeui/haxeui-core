package haxe.ui.containers.windows;

import haxe.ui.core.Component;

@:xml('
    <hbox width="100%">
        <label id="windowTitleLabel" text="Window" />
        <hbox id="controlsContainer" hidden="true" verticalAlign="center" style="cursor: default" />
    </hbox>
')
class WindowTitle extends HBox {
    public override function addComponent(child:Component):Component {
        if (controlsContainer != null && child != windowTitleLabel && child != controlsContainer) {
            controlsContainer.show();
            return controlsContainer.addComponent(child);
        }
        return super.addComponent(child);
    }
}