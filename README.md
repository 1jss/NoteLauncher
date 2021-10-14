# NoteLauncher
NoteLauncher is an Application Launcher for Pine64 PineNote

![](/screenshots/Screenshot-2021-10-12.png)

It's in it's very early stages, so most things are hard coded while the underlaying functionality is put together.

## Technical Details
NoteLauncher is built in [Nim](https://nim-lang.org/) and uses the [SDL2](https://www.libsdl.org/) library.

> Hint! The best way to install the SDL2 libraries in macOS is to use [Homebrew](https://brew.sh/) with the following command: `brew install sdl2{,_gfx,_image,_mixer,_net,_ttf}`

### Nim Libraries
The following Nim libraries are needed:
- Pixie (`nimble install pixie@#head`)
- SDL2 (`nimble install sdl2@#head`)

`Pixie` is a graphics library and `SDL2` is Nim bindings for the SDL2 C library.

### Build and Run
Navigate to the project directory and run: `nim c -r launcher.nim`


## To Do

- [ ] Load icon objects from `.desktop` files
- [ ] Make clicking an icon launch the application

### Done

- [x] Create SDL2 window
- [x] Scale window to half for development
- [x] Load SVG into window
- [x] Load font
- [x] Draw app names in correct places
- [x] Detect mouse click and motion
- [x] Update window on mouse event
- [x] Draw tap targets
- [x] Detect target on click
- [x] Make the view scrollable
  - [x] Detect dragging (touch scrolling)
  - [x] Make layout relative to scroll
- [x] Draw icons and names in a grid
  - [x] Make `icon object` with fields for `icon`(url string), `executable`(url string) and `name`(string)
  - [x] Make store for icon objects (list of `icon object`)
  - [x] Make grid view that can draw icons and names in a data store (layout math)
