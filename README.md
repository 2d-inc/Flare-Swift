# Flare
<img align="right" src="https://cdn.2dimensions.com/flare_macbook.png" height="250">

[Flare](https://www.2dimensions.com/about-flare) is a powerful design and animation tool for app and game designers alike. The primary goal of Flare is to allow designers to work directly with assets that run in their final product, eliminating the need to redo that work in code.

# Flare-Swift

Swift runtime for Flare.

Export Flare files with the _Export to Engine_ picking _Binary_ format. (JSON support is in the works)

## _Alpha Release Notes_

This repo contains an alpha release of the Flare runtime. It handles everything Flare-related __except__:
- JSON format for exports 
- The [recently added raster image support](https://www.youtube.com/watch?v=XtG4Wa3gIf8). 

If you encounter any problems, be sure to [report them in the issue tracker](https://github.com/2d-inc/Flare-Swift/issues) and, if possible, include your Flare file.

## Contents

The repository contains an XCode Workspace with two XCode Projects:
- [**FlareSwift**](FlareSwift/FlareSwift.xcodeproj) - Swift Framework for loading and drawing Flare files. 
The Frameworks is further subdivided into two main Groups: 
    - [FlareSwift](FlareSwift/FlareSwift) is the bottommost layer of the Framework: this is where Flare file contents are read, loaded and built in-memory.    
    - [FlareCoreGraphics](FlareSwift/FlareCoreGraphics) handles the drawing operations on top of the FlareSwift abstractions. It draws into a Core Graphics context. 
- [BasicExample](BasicExample/BasicExample) <br/>
An iOS-based example that loads and animates a Flare file in a UIView.


## Usage

Here's a step-by-step overview on how to use the Framework in your XCode Project.

- Download the repo
- Open `Flare-Swift.xcworkspace`
- In the XCode window, make sure `FlareSwift` scheme is selected
- Build the Framework (⌘ + B)

The Framework is built into the `Products` folder. <br/>
N.B. The folder can be accessed from XCode by right clicking on it > `Show in Finder`.

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
