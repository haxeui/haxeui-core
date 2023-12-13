package haxe.ui.core;

// Lets haxeui know that this interactive components is built out of other
// sub interactive components. This is useful to know for things like 
// findComponents(InteractiveComponent) where you DO NOT want to find
// all of the sub interactive components, you just want the top level
// interactive component
interface ICompositeInteractiveComponent {
    
}