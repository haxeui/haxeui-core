package haxe.ui.containers.properties;

import haxe.ui.components.Button;
import haxe.ui.components.CheckBox;
import haxe.ui.components.DropDown;
import haxe.ui.components.Label;
import haxe.ui.components.NumberStepper;
import haxe.ui.components.TextField;
import haxe.ui.components.popups.ColorPickerPopup;
import haxe.ui.data.DataSource;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.util.Color;
import haxe.ui.util.Variant;

//***********************************************************************************************************
// PropertyEditor
//***********************************************************************************************************
class PropertyEditor extends HBox {
    private function applyConfig(config:Dynamic) {
    }

    private function applyDataSource(dataSource:DataSource<Dynamic>) {
    }

    private function applyValue(value:Variant) {
    }

    private function applyProperties(property:Property) {

    }

    private function onValueChanged(value:Variant) {
        var event = new UIEvent(UIEvent.CHANGE);
        var property = findAncestor(Property);
        property.value = value;
        property.dispatch(event);

        var propertyGrid = findAncestor(PropertyGrid);
        var event = new UIEvent(UIEvent.CHANGE);
        event.relatedComponent = property;
        propertyGrid.dispatch(event);
    }
}

//***********************************************************************************************************
// PropertyEditorText
//***********************************************************************************************************
class PropertyEditorText extends PropertyEditor {
    private var textField:TextField;

    public function new() {
        super();
        textField = new TextField();
        textField.percentWidth = 100;
        addComponent(textField);
    }

    @:bind(textField, UIEvent.CHANGE)
    private function onTextFieldChange(_) {
        onValueChanged(textField.text);
    }

    public override function applyValue(value:Variant) {
        textField.text = value;
    }
}

//***********************************************************************************************************
// PropertyEditorOptions
//***********************************************************************************************************
class PropertyEditorOptions extends PropertyEditor {
    private var buttonBar:ButtonBar;

    public function new() {
        super();
        buttonBar = new HorizontalButtonBar();
        buttonBar.percentWidth = 100;
        buttonBar.allowUnselection = true;
        addComponent(buttonBar);
    }

    public override function applyDataSource(dataSource:DataSource<Dynamic>) {
        buttonBar.removeAllComponents();
        for (i in 0...dataSource.size) {
            var item = dataSource.get(i);
            var button = new Button();
            button.id = item.id;
            button.text = item.text;
            button.icon = item.icon;
            button.percentWidth = 100;
            buttonBar.addComponent(button);
        }
    }

    @:bind(buttonBar, UIEvent.CHANGE)
    private function onButtonBarChange(_) {
        onValueChanged(buttonBar.selectedButton.text);
    }

    public override function applyValue(value:Variant) {
        for (button in buttonBar.findComponents(Button)) {
            if (button.text == value.toString() || button.id == value.toString()) {
                button.selected = true;
            }
        }
    }
}

//***********************************************************************************************************
// PropertyEditorList
//***********************************************************************************************************
class PropertyEditorList extends PropertyEditor {
    private var dropDown:DropDown;

    public function new() {
        super();
        dropDown = new DropDown();
        dropDown.handlerStyleNames = "property-editor-dropdown-popup";
        dropDown.percentWidth = 100;
        addComponent(dropDown);
    }

    @:bind(dropDown, UIEvent.CHANGE)
    private function onDropDownChange(_) {
        onValueChanged(Variant.fromDynamic(dropDown.selectedItem.text));
    }

    public override function applyDataSource(dataSource:DataSource<Dynamic>) {
        dropDown.dataSource = dataSource;
    }

    public override function applyValue(value:Variant) {
        dropDown.selectedItem = value.toString();
    }
}

//***********************************************************************************************************
// PropertyEditorNumber
//***********************************************************************************************************
class PropertyEditorNumber extends PropertyEditor {
    private var numberStepper:NumberStepper;

    public function new() {
        super();
        numberStepper = new NumberStepper();
        numberStepper.percentWidth = 100;
        addComponent(numberStepper);
    }

    private override function applyProperties(property:Property) {
        if (property.min != null) {
            numberStepper.min = property.min;
        }
        if (property.max != null) {
            numberStepper.max = property.max;
        }
        if (property.step != null) {
            numberStepper.step = property.step;
        }
        if (property.precision != null) {
            numberStepper.precision = property.precision;
        }
    }

    @:bind(numberStepper, UIEvent.CHANGE)
    private function onNumberStepperChange(_) {
        onValueChanged(numberStepper.pos);
    }

    public override function applyValue(value:Variant) {
        numberStepper.value = value.toFloat();
    }
}

//***********************************************************************************************************
// PropertyEditorColor
//***********************************************************************************************************
class PropertyEditorColor extends PropertyEditor {
    private var colorPicker:ColorPickerPopup;

    public function new() {
        super();
        colorPicker = new ColorPickerPopup();
        colorPicker.handlerStyleNames = "property-editor-dropdown-popup";
        colorPicker.percentWidth = 100;
        addComponent(colorPicker);
    }

    @:bind(colorPicker, UIEvent.CHANGE)
    private function onColorPickerChange(_) {
        onValueChanged(Variant.fromDynamic(colorPicker.selectedItem));
    }

    public override function applyValue(value:Variant) {
        if (value == null) {
            return;
        }
        colorPicker.selectedItem = Color.fromString(value.toString());
    }
}

//***********************************************************************************************************
// PropertyEditorBoolean
//***********************************************************************************************************
class PropertyEditorBoolean extends PropertyEditor {
    private var checkbox:CheckBox;

    public function new() {
        super();
        checkbox = new CheckBox();
        addComponent(checkbox);
    }

    @:bind(checkbox, UIEvent.CHANGE)
    private function onCheckboxChange(_) {
        onValueChanged(checkbox.selected);
    }

    public override function applyValue(value:Variant) {
        checkbox.selected = value.toBool();
    }
}

//***********************************************************************************************************
// PropertyEditorBoolean
//***********************************************************************************************************
class PropertyEditorDate extends PropertyEditor {
    private var dropdown:DropDown;

    public function new() {
        super();
        dropdown = new DropDown();
        dropdown.handlerStyleNames = "property-editor-dropdown-popup";
        dropdown.type = "date";
        dropdown.percentWidth = 100;
        addComponent(dropdown);
    }

    @:bind(dropdown, UIEvent.CHANGE)
    private function onCheckboxChange(_) {
        onValueChanged(dropdown.selectedItem);
    }

    public override function applyValue(value:Variant) {
        dropdown.selectedItem = value.toDate();
    }
}

//***********************************************************************************************************
// PropertyEditorFile
//***********************************************************************************************************
class PropertyEditorFile extends PropertyEditor {
    public function new() {
        super();
        var hbox = new HBox();
        hbox.percentWidth = 100;

        var label = new Label();
        label.text = "Select file";
        label.percentWidth = 100;
        hbox.addComponent(label);
        var button = new Button();
        button.text = "...";
        hbox.addComponent(button);

        addComponent(hbox);
    }
}


//***********************************************************************************************************
// PropertyEditorAction
//***********************************************************************************************************
class PropertyEditorAction extends PropertyEditor {
    private var button:Button;

    public function new() {
        super();
        button = new Button();
        button.percentWidth = 100;
        addComponent(button);
    }

    private override function applyProperties(property:Property) {
        if (property.text != null) {
            button.text = property.text;
        }
    }

    public override function applyValue(value:Variant) {
        button.value = value.toString();
    }

    @:bind(button, MouseEvent.CLICK)
    private function onButtonChange(_) {
        onValueChanged(button.text);
    }
}


//***********************************************************************************************************
// PropertyEditorToggle
//***********************************************************************************************************
class PropertyEditorToggle extends PropertyEditor {
    private var button:Button;

    public function new() {
        super();
        button = new Button();
        button.percentWidth = 100;
        button.toggle = true;
        addComponent(button);
    }

    private override function applyProperties(property:Property) {
        if (property.text != null) {
            button.text = property.text;
        }
    }

    public override function applyValue(value:Variant) {
        button.selected = value.toBool();
    }

    @:bind(button, UIEvent.CHANGE)
    private function onButtonChange(_) {
        onValueChanged(button.selected);
    }
}