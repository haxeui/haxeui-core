/*
 * Cocktail, HTML rendering engine
 * http://haxe.org/com/libs/cocktail
 *
 * Copyright (c) Silex Labs
 * Cocktail is available under the MIT license
 * http://www.silexlabs.org/labs/cocktail-licensing/
*/
package haxe.ui.styles.selector;

import haxe.ui.styles.selector.SelectorSerializer;

/**
 * @author Yannick DOMINGUEZ
 */

//////////////////////////////////////////////////////////////////////////////////////////
// SELECTOR STRUCTURES
//////////////////////////////////////////////////////////////////////////////////////////

/**
 * For a given element, when retrieving
 * its styles, stores which pseudo-classes
 * the element currently matches.
 * 
 * Also store some additional data about
 * the node, such as wether it has an ID,
 * used to optimise cascading
 */
class MatchedPseudoClassesVO {
    
    public var hover:Bool;
    public var focus:Bool;
    public var active:Bool;
    public var link:Bool;
    public var enabled:Bool;
    public var disabled:Bool;
    public var checked:Bool;
    public var fullscreen:Bool;
    
    public var hasId:Bool;
    public var nodeId:String;
    public var hasClasses:Bool;
    public var nodeClassList:Array<String>;
    public var nodeType:String;
    
    public function new(hover:Bool, focus:Bool, active:Bool, link:Bool, enabled:Bool,
    disabled:Bool, checked:Bool, fullscreen:Bool,
    hasId:Bool, hasClasses:Bool, nodeId:String, nodeClassList:Array<String>, nodeType:String) 
    {
        this.hover = hover;
        this.focus = focus;
        this.active = active;
        this.link = link;
        this.enabled = enabled;
        this.disabled = disabled;
        this.checked = checked;
        this.fullscreen = fullscreen;
        this.hasId = hasId;
        this.hasClasses = hasClasses;
        this.nodeId = nodeId;
        this.nodeClassList = nodeClassList;
        this.nodeType = nodeType;
    }
}

/**
 * Holds the data used to determine a selector specificity (priority).
 * Selector specificity is used to determine which styles to use when
 * a particular style is defined in more than one CSS rule. The 
 * style with the more specific selector is used.
 * 
 * Specificity is defined by 3 categories whose value are
 * then concatenated into an integer value
 */
class SelectorSpecificityVO {
    
    /**
     * Incremented for each ID simple selector
     * in the selector
     */
    public var idSelectorsNumber:Int;
    
    /**
     * Incremented for each class and pseudo class
     * simple selector in the selector
     */
    public var classAttributesAndPseudoClassesNumber:Int;
    
    /**
     * Incremented for each type and pseudo element
     * simple selector in the selector
     */
    public var typeAndPseudoElementsNumber:Int;
    
    public function new()
    {
        idSelectorsNumber = 0;
        classAttributesAndPseudoClassesNumber = 0;
        typeAndPseudoElementsNumber = 0;
    }
}

/**
 * Contains all the data of one selector
 */
class SelectorVO {
    
    /**
     * an array of any combination of selector
     * components
     */
    public var components:Array<SelectorComponentValue>;
    
    /**
     * a selector can only have one pseudo element,
     * always specified at the end of the selector
     */
    public var pseudoElement:PseudoElementSelectorValue;
    
    /**
     * Store wether the first component (starting from the right)
     * of this selector is a class selector. Used for optimisations
     * during cascade
     */
    public var beginsWithClass:Bool;
    
    /**
     * If the selector begins with a class, it is stored
     * here, else it is null
     */
    public var firstClass:String;
    
    /**
     * same as beginsWithClass for Id selector
     */
    public var beginsWithId:Bool;
    
    /**
     * same as firstClass for Id
     */
    public var firstId:String;
    
    /**
     * same as beginsWithClass for type selector
     */
    public var beginsWithType:Bool;
    
    /**
     * same as firstClass for type selector
     */
    public var firstType:String;
    
    /**
     * Wether this selector only contains a single
     * class selector
     */
    public var isSimpleClassSelector:Bool;
    
    /**
     * same as above for id selector
     */
    public var isSimpleIdSelector:Bool;
    
    /**
     * same as above for type selector
     */
    public var isSimpleTypeSelector:Bool;
    
    public function new(components:Array<SelectorComponentValue>, pseudoElement:PseudoElementSelectorValue,
    beginsWithClass:Bool, firstClass:String, beginsWithId:Bool, firstId:String, beginsWithType:Bool, firstType:String
    , isSimpleClassSelector:Bool, isSimpleIdSelector:Bool, isSimpleTypeSelector:Bool)
    {
        this.components = components;
        this.pseudoElement = pseudoElement;
        this.beginsWithClass = beginsWithClass;
        this.firstClass = firstClass;
        this.beginsWithId = beginsWithId;
        this.firstId = firstId;
        this.beginsWithType = beginsWithType;
        this.firstType = firstType;
        this.isSimpleClassSelector = isSimpleClassSelector;
        this.isSimpleIdSelector = isSimpleIdSelector;
        this.isSimpleTypeSelector = isSimpleTypeSelector;
    }

    public function toString()
        return CSSSelectorSerializer.serialize(this);
}

/**
 * Represent a simple selector sequence.
 * A sequence always begin with a type or 
 * universal selector and only has one of
 * those two in the whole sequence. Then it can
 * have any combination of the remaining simple
 * selectors
 */
class SimpleSelectorSequenceVO {
    
    /**
     * Only one sequence start selector for a selector
     * sequence
     */
    public var startValue:SimpleSelectorSequenceStartValue;
    
    /**
     * any number of the remaining simple selectors
     */
    public var simpleSelectors:Array<SimpleSelectorSequenceItemValue>;
    
    public function new(startValue:SimpleSelectorSequenceStartValue, simpleSelectors:Array<SimpleSelectorSequenceItemValue>)
    {
        this.startValue = startValue;
        this.simpleSelectors = simpleSelectors;
    }
}

//////////////////////////////////////////////////////////////////////////////////////////
// SELECTOR ENUMS
//////////////////////////////////////////////////////////////////////////////////////////

/**
 * A selector contains either simple selector
 * or combinator between 2 simple selector
 */
enum SelectorComponentValue {
    SIMPLE_SELECTOR_SEQUENCE(value:SimpleSelectorSequenceVO);
    COMBINATOR(value:CombinatorValue);
} 

/**
 * Lists all the simple selectors besides the type and
 * universal selector, reserved for the start of a
 * simple selector sequence
 */
enum SimpleSelectorSequenceItemValue {
    ATTRIBUTE(value:AttributeSelectorValue);
    PSEUDO_CLASS(value:PseudoClassSelectorValue);
    CSS_CLASS(value:String);
    ID(value:String);
}

/**
 * Matches an element's type (tag name) or any element (universal, symbolised by "*").
 * A simple selector sequence always begin with
 * one of those 2 values. Universal may be implied.
 * For instance ".myclass" is the same as "*.myClass"
 */
enum SimpleSelectorSequenceStartValue {
    
    /**
     * any element
     */
    UNIVERSAL;
    
    /**
     * an element of type value
     */
    TYPE(value:String);
}

/**
 * Matches an element's attribute
 * presence and value
 */
enum AttributeSelectorValue {
    
    /**
     * an element with a "value" attribute
     */
    ATTRIBUTE(value:String);
    
    /**
     * an element with a "name" attribute
     * whose value is exactly "value"
     */
    ATTRIBUTE_VALUE(name:String, value:String);
    
    /**
     * an element whose "name" attribute
     * value is a list of whitespace-separated values,
     * one of which is exactly equal to "value"
     */
    ATTRIBUTE_LIST(name:String, value:String);
    
    /**
     * an element whose "name" attribute value begins
     * exactly with the string "value"
     */
    ATTRIBUTE_VALUE_BEGINS(name:String, value:String);
    
    /**
     * an element whose "name" attribute
     * value ends exactly with the string "value"
     */
    ATTRIBUTE_VALUE_ENDS(name:String, value:String);
    
    /**
     * an element whose "name" attribute value
     * contains the substring "value"
     */
    ATTRIBUTE_VALUE_CONTAINS(name:String, value:String);
    
    /**
     * an element whose "name" attribute has a hyphen-separated
     * list of values beginning (from the left) with "value"
     */
    ATTRIBUTE_VALUE_BEGINS_HYPHEN_LIST(name:String, value:String);
}

/**
 * List the pseuso class selector types
 */
enum PseudoClassSelectorValue {
    STRUCTURAL(value:StructuralPseudoClassSelectorValue);
    LINK(value:LinkPseudoClassValue);
    TARGET;
    FULLSCREEN;
    LANG(value:Array<String>);
    USER_ACTION(value:UserActionPseudoClassValue);
    UI_ELEMENT_STATES(value:UIElementStatesValue);

    CUSTOM(value:String);
    
    //TODO 2 : should actually be SelectorVO ?
    NOT(value:SimpleSelectorSequenceVO);
}

/**
 * List the structural pseudo class, which
 * are based on the DOM structure
 */
enum StructuralPseudoClassSelectorValue {
    
    /**
     * The :root pseudo-class represents an element 
     * that is the root of the document. In HTML 4, this 
     * is always the HTML element. 
     */
    ROOT;
    
    /**
     * The :first-child pseudo-class represents an element
     * that is the first child of some other element. 
     */
    FIRST_CHILD;
    
    /**
     * The :last-child pseudo-class represents 
     * an element that is the last child of
     * some other element. 
     */
    LAST_CHILD;
    
    /**
     * The :first-of-type pseudo-class represents
     * an element that is the first sibling of its
     * type in the list of children of its parent element. 
     */
    FIRST_OF_TYPE;
    
    /**
     * he :last-of-type pseudo-class represents an element
     * that is the last sibling of its type in the list
     * of children of its parent element. 
     */
    LAST_OF_TYPE;
    
    /**
     * Represents an element that has a parent element and whose
     * parent element has no other element children. 
     * Same as :first-child:last-child
     */
    ONLY_CHILD;
    
    /**
     * Represents an element that has a parent element and 
     * whose parent element has no other element children
     * with the same expanded element name
     */
    ONLY_OF_TYPE;
    
    /**
     * The :empty pseudo-class represents an element 
     * that has no children at all. 
     */
    EMPTY;
    
    //TODO 2 : doc + implementation
    NTH_CHILD(value:StructuralPseudoClassArgumentValue);
    NTH_LAST_CHILD(value:StructuralPseudoClassArgumentValue);
    NTH_LAST_OF_TYPE(value:StructuralPseudoClassArgumentValue);
    NTH_OF_TYPE(value:StructuralPseudoClassArgumentValue);
}

//TODO 2 : missing values
enum StructuralPseudoClassArgumentValue {
    INDEX(idx:Int);
    ODD;
    EVEN;
}

/**
 * pseudo class applying to anchor
 */
enum LinkPseudoClassValue {
    
    /**
     * The :link pseudo-class applies 
     * to links that have not yet been visited. 
     */
    LINK;
    
    /**
     * The :visited pseudo-class applies once
     * the link has been visited by the user. 
     */
    VISITED;
}

/**
 * Pseudo classes caused by user actions
 */
enum UserActionPseudoClassValue {
    
    /**
     * The :active pseudo-class applies while an element is being
     * activated by the user. For example, between
     * the times the user presses the mouse
     * button and releases it.
     */
    ACTIVE;
    
    /**
     * The :hover pseudo-class applies while the user
     * designates an element with a pointing device,
     * but does not necessarily activate it.
     */
    HOVER;
    
    /**
     * The :focus pseudo-class applies while an element
     * has the focus (accepts keyboard or mouse events,
     * or other forms of input). 
     */
    FOCUS;
}

enum UIElementStatesValue {
    ENABLED;
    DISABLED;
    CHECKED;
}

enum PseudoElementSelectorValue {
    NONE;
    FIRST_LINE;
    FIRST_LETTER;
    BEFORE;
    AFTER;
}

enum CombinatorValue {
    DESCENDANT;
    CHILD;
    ADJACENT_SIBLING;
    GENERAL_SIBLING;
}

/**
 * states enums for state parsers
 * 
 * @author Yannick DOMINGUEZ
 */

enum SelectorParserState {
    IGNORE_SPACES;
    BEGIN_SIMPLE_SELECTOR;
    END_SIMPLE_SELECTOR;
    SIMPLE_SELECTOR;
    END_TYPE_SELECTOR;
    END_CLASS_SELECTOR;
    END_ID_SELECTOR;
    BEGIN_COMBINATOR;
    COMBINATOR;
    BEGIN_PSEUDO_SELECTOR;
    END_UNIVERSAL_SELECTOR;
    PSEUDO_ELEMENT_SELECTOR;
    BEGIN_ATTRIBUTE_SELECTOR;
    INVALID_SELECTOR;
}

enum SelectorsParserState {
    IGNORE_SPACES;
    BEGIN_SELECTOR;
    END_SELECTOR;
    SELECTOR;
}

enum AttributeSelectorParserState {
    IGNORE_SPACES;
    END_OPERATOR;
    ATTRIBUTE;
    BEGIN_OPERATOR;
    OPERATOR;
    IDENTIFIER_VALUE;
    STRING_VALUE;
    END_SELECTOR;
    INVALID_SELECTOR;
}
