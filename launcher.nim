## This example show how to have real time pixie using sdl2 API.

import math, pixie, sdl2

 # Synthetic sugar: Iterator shortcut: a...b
iterator `...`*[T](a: T, b: T): T =
  var res: T = T(a)
  while res <= b:
    yield res
    inc res
    
const
  rmask = uint32 0x000000ff
  gmask = uint32 0x0000ff00
  bmask = uint32 0x00ff0000
  amask = uint32 0xff000000
  scale = 0.5


proc dpi(real:float):float =
  result = real * scale

 # Real resolution: 1404×1872
 # Devided by two for development
let
  w = dpi(1404) #702
  h = dpi(1872) #936

var
  screen = newImage(int(w), int(h))
  ctx = newContext(screen)
  window: WindowPtr
  render: RendererPtr
  mainSurface: SurfacePtr
  mainTexture: TexturePtr
  evt = sdl2.defaultEvent
  font = readFont("data/Ubuntu-Regular_1.ttf")

 # Mouse variables
var
  mx = 0 # Mouse x
  my = 0 # Mouse y
  omx = 0 # Old mouse x
  omy = 0 # Old mouse y
  mxc = 0 # Mouse x on click
  myc = 0 # Mouse y on click
  leftMouseButtonDown = false

proc blit() =
  var dataPtr = ctx.image.data[0].addr
  mainSurface = createRGBSurfaceFrom(dataPtr, cint w, cint h, cint 32, cint 4*w, rmask, gmask, bmask, amask)
  mainTexture = render.createTextureFromSurface(mainSurface)
  destroy(mainSurface)
  render.clear()
  render.copy(mainTexture, nil, nil)
  destroy(mainTexture)
  render.present()

proc initDisplay() =
  screen.fill(rgba(255, 255, 255, 255))
  blit()

proc initFont() =
  font.size = dpi(32)
  font.paint.color = pixie.color(0, 0, 0, 1)

proc drawIconText(text: string, column, row: float) =
  var tx = dpi((300*column)-200)
  var ty = dpi((350*row)+170)
  screen.fillText(font.typeset(text, vec2(dpi(300), dpi(32)), hAlign = haCenter, vAlign = vaTop, wrap = true), translate(vec2(tx, ty)))

let wh = vec2(100, 100)

proc checkMouseCollition(bx, by:float, wh: Vec2):bool =
  let fmx = float(mx)
  let fmy = float(my)
  if(fmx<bx+wh.x and fmx>bx and fmy<by+wh.y and fmy>by ):
    result = true
  else:
    result = false

proc clickedButton() =
  let wh = vec2(dpi(280), dpi(330))
  var tx, ty:float = 0
  for ix in 1...4:
    for iy in 1...4:
      tx = dpi((300*float(ix))-190)
      ty = dpi((350*float(iy))-70)
      if (checkMouseCollition(tx,ty,wh)):
        echo "Clicked " & $ix & ":" & $iy

proc drawTapTargets() =
  ctx.fillStyle = rgba(255, 0, 0, 50)
  let wh = vec2(dpi(280), dpi(330))
  var tx, ty:float = 0
  for ix in 1...4:
    for iy in 1...4:
      tx = (300*float(ix))-190
      ty = (350*float(iy))-70
      ctx.fillRect(rect(vec2(dpi(tx), dpi(ty)), wh))

proc inhabitDisplay() =
  let icons = readImage("icons/home.svg")

  screen.draw(
    icons,
    scale(vec2(scale,scale))
    )

  initFont()
  drawIconText("Terminal Emulator", 1, 1)
  drawIconText("Calculator", 2, 1)
  drawIconText("Cloud Storage", 3, 1)
  drawIconText("Paint", 4, 1)
  drawIconText("Internet", 1, 2)
  drawIconText("Music Player", 2, 2)
  drawIconText("Energy", 3, 2)
  drawIconText("Search", 4, 2)
  drawIconText("Clocks", 1, 3)
  drawIconText("Application Developer Tools", 2, 3)
  drawIconText("EBook Reader", 3, 3)
  drawIconText("Music Composer", 4, 3)
  drawIconText("Settings", 1, 4)
  drawIconText("Sound Recorder", 2, 4)
  drawIconText("Activity Monitor", 3, 4)
  drawIconText("Text Chat", 4, 4)

  #drawTapTargets() # For debugging tap targets

  blit()

proc updateDisplay() =
  ctx.strokeStyle = "#44BBFF"
  ctx.lineWidth = 10
  ctx.lineCap = lcRound

  let
    start = vec2(float32(omx), float32(omy))
    stop = vec2(float32(mx), float32(my))

  ctx.strokeSegment(segment(start, stop))
  blit()

 # Application MAIN

discard sdl2.init(INIT_EVERYTHING)

window = createWindow(
  title = "PineNote Launcher",
  x = SDL_WINDOWPOS_CENTERED,
  y = SDL_WINDOWPOS_CENTERED,
  w = cint w,
  h = cint h,
  flags = SDL_WINDOW_SHOWN
)
render = createRenderer(window, -1, 0)
initDisplay()
inhabitDisplay()
  

 # Mouse and Window event logic 

while true:
  while waitEvent(evt):
    case evt.kind:
      of QuitEvent:
        quit(0)
      of MouseButtonUp:
        # Left mouse button is released
        if (evt.button.button == 1):
          leftMouseButtonDown = false
          mx = evt.button.x
          my = evt.button.y
          if ((mxc-mx < 20) and (mxc-mx > -20) and (myc-my < 20) and (myc-my > -20)):
            clickedButton()
      of MouseButtonDown:
        # Left mouse button is pressed
        if (evt.button.button == 1):
          leftMouseButtonDown = true
          omx = evt.button.x
          omy = evt.button.y
          mxc = evt.button.x
          myc = evt.button.y
      of MouseMotion:
        # Mouse is dragged
        if(leftMouseButtonDown):
          mx = evt.motion.x
          my = evt.motion.y
          if (mxc-mx > 20):
            echo "go right"
          elif (mxc-mx < -20):
            echo "go left"
          if (myc-my > 20):
            echo "go down"
          elif (myc-my < -20):
            echo "go up"
          updateDisplay()
          omx = mx
          omy = my
      else:
        discard
