package haxe.ui.core;

class LayoutBehaviour extends DataBehaviour { // TODO: this should replace InvalidatingBehaviour
    public override function validateData() {
        super.validateData();
        _component.invalidateLayout();
    }
}