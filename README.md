# Train Factory
Factorio mod to automate train production

This is a pre-alpha release! It's functional but only just. Documentation, icons and graphics work are yet to be done.

## How to use
This section will be greatly expanded.
Construct the TrainFactory buildings and place them on tracks. Connect them close enough together so that they link up and form groups.
Select the recipe in each building to choose which rolling stock gets created. Select a train stop name.
For the locomotive buildings, find the fuel box, which is attached to the

### Disassembler
For the disassembler, it's very similar. Create a group of disassemblers in the same way. The front machine will have an integrated train stop
that you can rename through the building GUI. Just send trains there and watch as they are deconstructed.

## Similar Mods
First of all, I'm a huge fan of https://mods.factorio.com/mod/trainConstructionSite. I love that mod, but it was just missing some functionality for me,
and it would have been too big of a change for a PR.
This mod is written from scratch but performs the same essential functionality that TrainConstructionSite does.

Reasons TrainConstructionSite is better

* Provides more content, more research in the tech tree.
* Provides more functionality for sending trains to depots, if you prefer it.
* As of now, much more polished experience.
* The trainfuel system means no fuel box, if you prefer it.
* Really nice tips-and-tricks documentation
* No off-grid nonsense

Reasons TrainFactory is better

* Works with blueprints, for the most part. Updating existing blueprints will likely never be supported.
* Supports half-size wagons, such as provided by Pyanodon's High Tech and Pyanodon's Alternative Energy
* Supports train disassemblers
* Simpler functionality for sending trains to stations, if you prefer it. Works well with train limits.
* The fuel-box has it's advantages, and the same system will be used for equipment grid support.

## Known issues
* Blueprints containing TrainFactories cannot be updated. See https://forums.factorio.com/88100

## Future work
* Better docs
* Graphics/Icons
* Equipment grid support

## Other Mod Credits
* I would never have been able to get blueprints working without reading the code of https://mods.factorio.com/mod/miniloader. Miniloaders is LGPLv3. The license is included here.
* Idea for the fuel/equipment box come from https://mods.factorio.com/mod/equipment-gantry
