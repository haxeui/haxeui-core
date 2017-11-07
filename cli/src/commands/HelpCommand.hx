package commands;

class HelpCommand extends Command {
    public function new() {
        super();
    }
    
    public override function execute(params:Params) {
        if (params.additional.length == 0) {
            displayHelp();
        } else {
            var command = CommandFactory.get(params.additional[0]);
            if (command == null) {
                Util.log('command "${params.additional[0]}" not found');
                return;
            }
            command.displayHelp();
        }
    }
    
    public override function displayHelp() {
        Util.log('Usage : haxeui <create | build> <${Util.backendString(" | ")}> [name] [options]\n');
        Util.log('Options :');
        Util.log('  create : creates project files for given backend');
        Util.log('  build : build project for given backend');
        Util.log('  name : name of main class (eg: foo.Bar), defaults to "Main"');
        Util.log('  options : depends on command / backend\n');
        Util.log('use "haxeui help <command>" for information about command');
    }
}