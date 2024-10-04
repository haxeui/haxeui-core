package haxe.ui.validators;

class EmailValidator extends PatternValidator {
    public function new() {
        super();
        invalidMessage = "Invalid email address";
        pattern = ~/^[^\-@\s:&!\/\\]+([\.-]?[^@\s:&!\/\\]+)*@[^\-@\s:&!\/\\\.]+([\.-]?[^@\s:&!\/\\\.]+)*(\.[^\-@\s:&!\/\\\.]{2,})+$/gm;
        //pattern = new EReg("^\\w+([\\.-]?\\w+)*@\\w+([\\.-]?\\w+)*(\\.\\w{2,3})+$", "gm");
   }
}