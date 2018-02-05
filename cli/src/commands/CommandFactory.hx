package commands;
import commands.UpdateCommand;

class CommandFactory {
    public static function get(id:String):Command {
        var c:Command = null;
        
        switch (id) {
            case "setup":
                c = new SetupCommand();
            case "create":
                c = new CreateCommand();
            case "custom-component":
                c = new CustomComponentCommand();
            case "build":
                c = new BuildCommand();
            case "install":
                c = new InstallCommand();
            case "update":
                c = new UpdateCommand();
            case "run":
                c = new RunCommand();
            case "test":
                c = new TestCommand();
            case "help":
                c = new HelpCommand();
            case _:
        }

        return c;
    }
    
    public static function has(id:String):Bool {
        return (get(id) != null);
    }
}