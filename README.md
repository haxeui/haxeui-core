<p align="center">
  <img src="https://dl.dropboxusercontent.com/u/26678671/haxeui2-warning.png"/>
</p>

<h2>haxeui-core</h2>

`haxeui-core` is a users universal entry point into the haxeui framework and allows for the same user interface code (either with markup or via `haxe` source code) to be used to to build a user interface on various platforms using various haxeui `backends`. Below is a general overview of how `haxeui-core` and the various haxeui `backends` fit together. You can watch a presentation about haxeui to get more of an understanding (given at WWX2016) <a href="https://www.youtube.com/watch?v=L8J8qrR2VSg&feature=youtu.be">here</a>.

<p align="center">
  <img src="https://dl.dropboxusercontent.com/u/26678671/haxeui-overview.png"/>
</p>

<h2>Installation</h2>
Eventually all these libs will become haxelibs, however, currently in their alpha form they dont even contain a `haxelib.json` file (for dependencies, etc) and therefore can only be used by downloading the source and using the `haxelib dev` command or by directly using the git versions using the `haxelib git` command (recommended). Eg:

```
haxelib git haxeui-core https://github.com/haxeui/haxeui-core
haxelib dev haxeui-openfl path/to/expanded/source/archive
```


<h2>Backends</h2>
In general, using a haxeui `backend` is a simple as just including `haxeui-core` and the `backend` library into your application, for example:

```
-lib haxeui-core
-lib haxeui-openfl
```

Currently haxeui supports the following `backends` (some of which have not yet had an alpha release - indicated by their check-box). Please refer to each `backend` for specific instructions on how to set-up and initialise the host framework (if required).


| Alpha             | Backend Library                   | Dependencies        | Platforms | Native Components |
| ---------------| -----------------------| ----------------- | ----- | ----- |
| <img src="https://dl.dropboxusercontent.com/u/26678671/tick.png"> | <a href="https://github.com/haxeui/haxeui-openfl">haxeui-openfl</a> | `OpenFL` / `Lime` | `Mobile`, `Desktop`, `Browser` | <p align="center"><img src="https://dl.dropboxusercontent.com/u/26678671/cross.png"></p> |
| <p align="center"><img src="https://dl.dropboxusercontent.com/u/26678671/cross.png"></p> | <a href="https://github.com/haxeui/haxeui-flambe">haxeui-flambe</a> | `Flambe` | `Mobile`, `Browser` | <p align="center"><img src="https://dl.dropboxusercontent.com/u/26678671/cross.png"></p> |
| <p align="center"><img src="https://dl.dropboxusercontent.com/u/26678671/cross.png"></p> | <a href="https://github.com/haxeui/haxeui-kha">haxeui-kha</a> | `Kha` | `Mobile`, `Desktop`, `Browser` | <p align="center"><img src="https://dl.dropboxusercontent.com/u/26678671/cross.png"></p> |
| <p align="center"><img src="https://dl.dropboxusercontent.com/u/26678671/cross.png"></p> | <a href="https://github.com/haxeui/haxeui-html5">haxeui-html5</a> | n/a | `Browser` | <p align="center"><img src="https://dl.dropboxusercontent.com/u/26678671/tick.png"></p> |
| <p align="center"><img src="https://dl.dropboxusercontent.com/u/26678671/cross.png"></p> | <a href="https://github.com/haxeui/haxeui-pixijs">haxeui-pixijs</a> | `PixiJS` | `Browser` | <p align="center"><img src="https://dl.dropboxusercontent.com/u/26678671/cross.png"></p> |
| <p align="center"><img src="https://dl.dropboxusercontent.com/u/26678671/cross.png"></p> | <a href="https://github.com/haxeui/haxeui-nme">haxeui-nme</a> | `NME` | `Mobile`, `Desktop`, `Browser` | <p align="center"><img src="https://dl.dropboxusercontent.com/u/26678671/cross.png"></p> |
| <p align="center"><img src="https://dl.dropboxusercontent.com/u/26678671/cross.png"></p> | <a href="https://github.com/haxeui/haxeui-luxe">haxeui-luxe</a> | `luxe` | `Mobile`, `Desktop`, `Browser` | <p align="center"><img src="https://dl.dropboxusercontent.com/u/26678671/cross.png"></p> |
| <p align="center"><img src="https://dl.dropboxusercontent.com/u/26678671/cross.png"></p> | <a href="https://github.com/haxeui/haxeui-hxwidgets">haxeui-hxwidgets</a> | `hxWidgets` / `wxWidgets` | `Desktop` | <p align="center"><img src="https://dl.dropboxusercontent.com/u/26678671/tick.png"></p> |

<h2>Usage</h2>
Assuming that `haxeui-core` and the `backend` library have been included in your application, initialising the toolkit and using it should be relatively straight forward:

```haxe
Toolkit.init();
```

The `init` function can take an optional `Dynamic` argument that allows certain options to be passed to the host framework. Please refer to each specific backend on how to use these. 

Once the toolkit has been initialised components can be added in one of two ways:

<h3>Adding components using Haxe code</h3>
Using haxeui components in haxe code is simple and easy:

```haxe
var main:VBox = new VBox();

var button:Button = new Button();
button.text = "Button 1";
main.addComponent(button1);

var button:Button = new Button();
button.text = "Button 2";
main.addComponent(button1);

Screen.instance.addComponent(main);
```

_Note: `Screen` was used here as a universal way to add items to the application, this isnt required however, if you are using a single framework and arent interested in the cross-framework abilities of haxeui then you can use something more specific to the target framework (eg: `Lib.current.stage.addChild(main)`)._

<h3>Adding components from markup</h3>
It is also possible for haxeui to take a user interface definition from a mark up language (like xml) and use that to build code similar to above:

```haxe
var main = ComponentMacros.buildComponent("assets/ui/demo/main.xml");
Screen.instance.addComponent(main);
```

_Note: in the alpha release of haxeui-core there is currently no support for building a user interface from markup at runtime, however, this is **certainly** something that will be implemented._

<h2>Addtional resources</h2>
* <a href="http://haxeui.github.io/haxeui-api/">haxeui-api</a> - The haxeui api docs.
* <a href="https://github.com/haxeui/haxeui-guides">haxeui-guides</a> - Set of guides to working with haxeui and backends.
* <a href="https://github.com/haxeui/haxeui-demo">haxeui-demo</a> - Demo application written using haxeui.
* <a href="https://github.com/haxeui/haxeui-templates">haxeui-templates</a> - Set of templates for IDE's to allow quick project creation.
* <a href="https://github.com/haxeui/haxeui-bdd">haxeui-bdd</a> - A behaviour driven development engine written specifically for haxeui (uses <a href="https://github.com/haxeui/haxe-bdd">haxe-bdd</a> which is a gherkin/cucumber inspired project).
* <a href="https://www.youtube.com/watch?v=L8J8qrR2VSg&feature=youtu.be">WWX2016 presentation</a> - A presentation given at WWX2016 regarding haxeui.

