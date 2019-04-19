# Flare
<img align="right" src="https://cdn.2dimensions.com/flare_macbook.png" height="250">

[Flare](https://www.2dimensions.com/about-flare) is a powerful design and animation tool for app and game designers alike. The primary goal of Flare is to allow designers to work directly with assets that run in their final product, eliminating the need to redo that work in code.

# Flare-Swift

Swift runtime for Flare: export files from Flare and run them on iOS!

__Only Binary__ format is supported right now, but JSON support is in the works.

## Beta Release Notes


This is a __beta__ release.

The runtime is now using Skia as its rendering engine, so users will need to build the library with the instructions provided in the [Usage](#Usage) section.

If you encounter any problems [report them in the issue tracker](https://github.com/2d-inc/Flare-Swift/issues) and, if applicable, include your Flare file.

## Contents

The repository contains an XCode Workspace with two Projects:
- [FlareSwift](FlareSwift/FlareSwift.xcodeproj) - Swift Framework for loading and drawing Flare files. <br/>
The Framework is further subdivided into: 
    - [FlareCore](FlareSwift/FlareCore) is the bottommost layer of the Framework: this is where Flare file contents are read, loaded and built in-memory.
    - [FlareSkia](FlareSwift/FlareSkia) handles the drawing operations in an OpenGL context. It relies on `libskia`, which is built with a custom script (see [Usage](#Usage)).
    - [FlareCoreGraphics](FlareSwift/FlareCoreGraphics) handles the drawing operations in a Core Graphics context.<br/> Currently it doesn't support raster images. For raster image support, use [FlareSkia](FlareSwift/FlareSkia).
- [BasicExample](BasicExample/BasicExample) <br/>
An iOS-based example that demonstrates how to use a `ViewController` to load a `FlareSkView` that loads and animates a test Flare file.


## Usage

Here's a step-by-step guide on how to use the Framework in your XCode Project:

- Install `depot_tools` as described [here](https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up)
- Clone the repository, initialize its submodules, and build the library:
```
git clone git@github.com:2d-inc/Flare-Swift.git
cd Flare-Swift
git submodule update --init --recursive
./make_dependency.sh
```
N.B: the `make_dependency.sh` script can take a while to build.
- Open `Flare-Swift.xcworkspace`
- In the XCode window, make sure that the `FlareSwift` scheme is selected
- Build the Framework (⌘ + B)

The Framework is built into the `Products` folder. <br/>
(N.B. The folder can be accessed from XCode by right clicking on it > `Show in Finder`.)

Lastly, to use the Framework in your Project:
- Drag-and-drop it into the XCode window.
    - In the import dialog, select __"Copy items if needed"__ and the target in __"Add to Targets"__
- Add the Framework to the Build Phases: 
    - Select the Project in the Project Navigator 
    - Select your Target
    - __Build Phases__ 
    - Add the Framework to the __Embed Frameworks__ phase.

## License
See the [LICENSE](LICENSE) file for license rights and limitations (MIT).

FlareCoreGraphics contains a `Bezier` folder, that is a port of [bezier.dart](https://github.com/aab29/bezier.dart), and is complying with their [LICENSE.txt](FlareSwift/FlareCoreGraphics/Bezier/LICENSE.txt) (BSD 2-Clause License).