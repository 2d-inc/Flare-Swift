# Flare
<img align="right" src="https://cdn.2dimensions.com/flare_macbook.png" height="250">

[Flare](https://www.2dimensions.com/about-flare) is a powerful design and animation tool for app and game designers alike. The primary goal of Flare is to allow designers to work directly with assets that run in their final product, eliminating the need to redo that work in code.

# Flare-Swift

Swift runtime for Flare: export files from Flare and run them on iOS!

__Only Binary__ format is supported right now, but JSON support is in the works.

## Problems

If you encounter any problems [report them in the issue tracker](https://github.com/2d-inc/Flare-Swift/issues) and, if applicable, include your Flare file.

## Contents

The repository contains an XCode Workspace with two Projects:
- [FlareSwift](FlareSwift/FlareSwift.xcodeproj) - Swift Framework for loading and drawing Flare files. <br/> 
The Framework is further subdivided into: 
    - [FlareCore](FlareSwift/FlareCore) is the bottommost layer of the Framework: this is where Flare file contents are read, loaded and built in-memory.
    - [FlareSkia](FlareSwift/FlareSkia) handles the drawing operations in an OpenGL context. It relies on `libskia`, which is built with a custom script (see [Usage](#Usage)).
- [BasicExample](BasicExample/BasicExample) <br/>
An iOS-based example that demonstrates how to use a `ViewController` to load a `FlareSkView` that loads and animates a test Flare file.

## Usage

- Clone the repository:
```
git clone git@github.com:2d-inc/Flare-Swift.git
```
- Open `Flare-Swift.xcworkspace`
- In the XCode window, select the scheme for the device you want to run on:
    - Use **`FlareSwift Device`** to use the Framework on a **physical device**
    - Use **`FlareSwift Simulator`** to use the Framework on a **Simulator**
<img src="https://i.imgur.com/RhmcrmC.png" />

*N.B: first time building the Framework takes a while, as it is initializing and building all the dependencies. Use the Report Navigator to check the ongoing build.*

- Build the Framework (⌘ + B)

The Framework can be found in the `Products` folder. <br/>
Access the `Products` folder from XCode by right clicking on it > `Show in Finder`:

<img src="https://i.imgur.com/jMr5Cv5.png" />

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

The [`Bezier`](FlareSwift/Bezier) folder is a port of [bezier.dart](https://github.com/aab29/bezier.dart), and is complying with their [LICENSE.txt](FlareSwift/FlareCoreGraphics/Bezier/LICENSE.txt) (BSD 2-Clause License).
