package commands;

class CommandFactory {
    public static function get(id:String):Command {
        var c:Command = null;
        
        switch (id) {
            case "setup":
                c = new SetupCommand();
            case "create":
                c = new CreateCommand();
            case "build":
                c = new BuildCommand();
            case _:
        }

        return c;
    }
    
    public static function has(id:String):Bool {
        return (get(id) != null);
    }
}