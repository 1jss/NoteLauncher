# NoteLauncher
NoteLauncher is an Application Launcher for Pine64 PineNote

![](/screenshots/Screenshot-2021-10-12.png)

It's in it's very early stages, so most things are hard coded while the underlaying functionality is put together.

## Technical details
NoteLauncher is built in [Nim](https://nim-lang.org/) and uses the [SDL2](https://www.libsdl.org/) library.

> Hint! The best way to install the SDL2 libraries in macOS is to use [Homebrew](https://brew.sh/) with the following command: `brew install sdl2{,_gfx,_image,_mixer,_net,_ttf}`

### Nim Libraries
The following Nim libraries are needed:
- Pixie (`nimble install pixie@#head`)
- SDL2 (`nimble install sdl2@#head`)

`Pixie` is a graphics library and `SDL2` is Nim bindings for the SDL2 C library.

### Build and run
Navigate to the project directory and run: `nim c -r launcher.nim`
