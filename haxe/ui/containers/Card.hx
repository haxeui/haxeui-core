package haxe.ui.containers;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.components.Label;
import haxe.ui.containers.HBox;
import haxe.ui.containers.Box;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;

@:composite(Builder)
class Card extends Box {
    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************
    @:clonable @:behaviour(TextBehaviour)       public var text:String;
    @:clonable @:value(text)                    public var value:Dynamic;
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class TextBehaviour extends DataBehaviour {
    public override function validateData() {
        var builder:Builder = cast(_component._compositeBuilder, Builder);
        builder.getTitleLabel().text = _value;
        
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:allow(haxe.ui.components.TabBar)
@:access(haxe.ui.core.Component)
private class Builder extends CompositeBuilder {
    private var _card:Card;
    public function new(card:Card) {
        super(card);
        _card = card;
    }
    
    public function getTitleLabel():Label {
        var titleContainer = getTitleContainer();
        var titleLabel = titleContainer.findComponent("card-title-label", Label);
        if (titleLabel == null) {
            _card.layoutName = "vertical";
            var hbox = titleContainer.findComponent("card-title-box", HBox);
            if (hbox == null) {
                hbox = new HBox();
                hbox.addClass("card-title-box");
                hbox.id = "card-title-box";
                hbox.scriptAccess = false;
                titleContainer.addComponent(hbox);
            }
            
            titleLabel = new Label();
            titleLabel.addClass("card-title-label");
            titleLabel.id = "card-title-label";
            titleLabel.scriptAccess = false;
            hbox.addComponentAt(titleLabel, 0);
            
            var line = titleContainer.findComponent("card-title-line", Component);
            if (line == null) {
                line = new Component();
                line.id = "card-title-line";
                line.addClass("card-title-line");
                line.scriptAccess = false;
                titleContainer.addComponent(line);
            }
        }
        
        return titleLabel;
    }
    
    public function getTitleContainer():VBox {
        var titleContainer = _component.findComponent("card-title-container", VBox);
        if (titleContainer == null) {
            titleContainer = new VBox();
            titleContainer.addClass("card-title-container");
            titleContainer.id = "card-title-container";
            titleContainer.scriptAccess = false;
            _card.addComponentAt(titleContainer, 0);
        }
        
        return titleContainer;
    }
}