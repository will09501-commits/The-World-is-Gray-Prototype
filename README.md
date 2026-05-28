# theworldisgray
A game that I am currently working on making a 2d metroidvania that is combat focused and boss focused
An independent technical prototype developed in **Godot 4** using **GDScript**. This project serves as a sandbox to implement modular, decoupled gameplay systems, custom character physics, and scalable event architecture.

*Note: This is an active alpha build focusing strictly on systems engineering. Visual assets are placeholders sourced from open-source community libraries.*

## Key Architectural Features
* **Decoupled Event Architecture:** uses Godot's **Signals** and node hierarchy to make a modular system, reduces tight coupling between scripts (e.g., separating UI logic from player state).
* **Custom Character Controller:** Programmed a kinematic character state machine from scratch handling movement physics, custom velocity curves, and precise collision response.

## Tech Stack & Tools
* **Engine:** Godot Engine
* **Language:** GDScript
* **Version Control:** Git / GitHub (utilizing standard Godot .gitignore practices)

## Gameplay Controls
* **W / A / S / D:** Move Player
* **Spacebar:** Jump

## How to Explore the Code
The core engineering logic is organized into clean directories to pass professional studio review:
* `/scripts` - Contains the modular GDScript logical backends.
* `/scenes` - Houses the structured node and signal hierarchies.
* `/assests` - Contains all assests used in it

## Credits & Licensing
**[Asset Name]** by [Artist Username/Name] ([Link to OpenGameArt Asset Page]), licensed under [License Type with Link].
* **Gameplay Assets:** Sourced from the [Brackeys Platformer Bundle](https://brackeysgames.itch.io/brackeys-platformer-bundle) via itch.io (Licensed under **CC0 / Public Domain**).
* **Original Asset Artistry:** Credit to `analogStudios_` and `RottingPixels` for the underlying sprite architectures and tilesets.
* **Bosses and monsters spritesheets (Ars Notoria)** by [Stephen Challener (Redshrike)] (https://opengameart.org/content/bosses-and-monsters-spritesheets-ars-notoria), licensed under CC-BY 3.0 https://creativecommons.org/licenses/by/3.0/.
* **Cyberpunk Street Environment** by [ansimuz.com] (https://opengameart.org/content/cyberpunk-street-environment), licensed under CC-BY 3.0 https://creativecommons.org/licenses/by/3.0/.
* **Hero spritesheets (Ars Notoria)** by [Balmer] (https://opengameart.org/content/hero-spritesheets-ars-notoria), licensed under CC0 https://creativecommons.org/publicdomain/zero/1.0/.
* **Gothicvania Town** by [Luis Zuno @ansimuz] (https://opengameart.org/content/gothicvania-town), licensed under CC0 https://creativecommons.org/publicdomain/zero/1.0/.
* **Grotto Escape II - Environment** by [ansimuz.com] (https://opengameart.org/content/grotto-escape-ii-environment), licensed under CC-BY 3.0 https://creativecommons.org/licenses/by/3.0/.
* **Free Pixel Effects Pack** by [CodeManu] (https://opengameart.org/content/free-pixel-effects-pack), licensed under CC0 https://creativecommons.org/publicdomain/zero/1.0/.
