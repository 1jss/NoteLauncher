import pixie, sdl2

discard sdl2.init(INIT_EVERYTHING)

const
  scl = 2 # Scale for development on smaller screen
  WindowWidth = 1404 div scl # 702
  WindowHeight = 1872 div scl # 936
  RowWidth = 300
  RowHeight = 350
  IconWidth = 280
  IconHeight = 330

const testData = @[
  ["Activity Monitor","icons/activitymonitor.svg","activitymonitor"],
  ["Application Developer Tools","icons/develop.svg","devtools"],
  ["Calculator","icons/calculator.svg","calculator"],
  ["Clock","icons/clock.svg","clock"],
  ["Cloud Storage","icons/cloud.svg","cloud"],
  ["EBook Reader","icons/reader.svg","ereader"],
  ["Energy","icons/energy.svg","energy"],
  ["Internet","icons/internet.svg","internet"],
  ["Music Composer","icons/composer.svg","composer"],
  ["Music Player","icons/musicplayer.svg","player"],
  ["Paint","icons/paint.svg","paint"],
  ["Search","icons/search.svg","search"],
  ["Settings","icons/settings.svg","settings"],
  ["Sound Recorder","icons/recorder.svg","recorder"],
  ["Terminal Emulator","icons/terminal.svg","terminal"],
  ["Text Chat","icons/chat.svg","chat"]
]

type
  Icon = ref object
    name: string
    image: Image
    executable: string
    x, y: float32
    w, h: float32

  View = ref object
    x, y: float32
    w, h: float32
    iconlist: seq[Icon]
  
  Launcher = ref object
    view: View


# The icon is an item. It contains its data, proportions and position.
proc newIcon(): Icon =
  Icon(
    name: "Empty",
    image: readImage("icons/empty.svg"),
    executable: "",
    x: 0,
    y: 0,
    w: IconWidth div scl,
    h: IconHeight div scl
  )

proc setIconData(i: Icon, name, executable: string) =
  i.name = name
  i.executable = executable

proc setIconImage(i: Icon, image:Image) =
  i.image = image

proc setIconPosition(i: Icon, x, y: float32) =
  i.x = x
  i.y = y

proc updateIconPosition(i: Icon, x, y: float32) =
  i.x += x
  i.y += y

proc draw(context: Context, icon: Icon, font: Font) =
  # For debugging icon touch target
  #[
  context.fillStyle = rgba(100, 100, 100, 255)
  var r = rect(
    vec2(icon.x, icon.y),
    vec2(icon.w, icon.h)
  )
  context.fillRect(r)
  ]#
  var appicon = icon.image
  var iconscale = 100 / float32(appicon.width) 
  pixie.draw(
    context.image,
    appicon,
    translate(vec2(icon.x+20, icon.y+10)) *
    scale(vec2(iconscale, iconscale))    
    )
  
  context.image.fillText(
    font.typeset(
      icon.name,
      vec2(150, 32),
      hAlign = haCenter,
      vAlign = vaTop,
      wrap = true
      ),
    translate(vec2(icon.x-5, icon.y+120))
    )


proc newIconList():seq[Icon] =
  result = newSeq[Icon]()
  var icon: Icon
  var iconImage: Image
  # Parse .Desktop files here
  
  for i in 0..testData.len-1:
    icon = newIcon()
    
    try:
      iconImage = readImage(testData[i][1])
      icon.setIconImage(iconImage)
    except:
      echo "failed to load" & testData[i][1]
    icon.setIconData(testData[i][0],testData[i][2])
    icon.setIconPosition(float32((RowWidth*(i mod 4)+110) div scl), float32((RowHeight*(i div 4)+280) div scl))
    result.add(icon)


# The view is a widget. It contains its position and all its items.
proc newView(): View =
  View(
    x: 0,
    y: 0,
    w: WindowWidth,
    h: WindowHeight,
    iconlist: newIconList()
  )

proc updateViewPosition(v: View, x, y: float32) =
  v.x += x
  v.y += y
  for i in 0..v.iconlist.len-1:
    v.iconlist[i].updateIconPosition(x,y)

proc draw(context: Context, view: View, font: Font) =
  # For debugging view position
  #[
  context.fillStyle = rgba(255, 255, 255, 255)
  var r = rect(
    vec2(view.x, view.y),
    vec2(view.w, view.h)
  )
  context.fillRect(r)
  ]#
  for i in 0..view.iconlist.len-1:
    context.draw(view.iconlist[i], font)


# The launcher is the main window. It contains all its widgets.
proc newLauncher(): Launcher =
  Launcher(
    view: newView()
  )

#proc update(l: Launcher, mx, my: float32) =
#  l.view.updateViewPosition(mx, my)

proc draw(l: Launcher, context: Context, font: Font) =
  context.image.fill(rgba(255, 255, 255, 255))
  context.draw(l.view, font)



proc clickedButton(l: Launcher, mx, my: float32) =
  var ic: Icon
  for i in 0..l.view.iconlist.len-1:
    ic = l.view.iconlist[i]
    if(mx<ic.x+ic.w and mx>ic.x and my<ic.y+ic.h and my>ic.y):
      echo "launching " & ic.executable


const
  rmask = uint32 0x000000ff
  gmask = uint32 0x0000ff00
  bmask = uint32 0x00ff0000
  amask = uint32 0xff000000

proc blit(renderer: RendererPtr, context: Context) =
  var surface = createRGBSurfaceFrom(
    context.image.data[0].addr,
    cint context.image.width,
    cint context.image.height,
    cint 32,
    cint 4*WindowWidth,
    rmask, gmask, bmask, amask
    )
  var texture = renderer.createTextureFromSurface(surface)
  destroy(surface)
  #renderer.clear()
  renderer.copy(texture, nil, nil)
  destroy(texture)
  renderer.present()


type SDLException = object of Defect
template sdlFailIf(condition: typed, reason: string) =
  if condition: raise SDLException.newException(
    reason & ", SDL error " & $getError()
  )

proc main =
  let window = createWindow(
      title = "PineNote Launcher",
      x = SDL_WINDOWPOS_CENTERED,
      y = SDL_WINDOWPOS_CENTERED,
      w = WindowWidth,
      h = WindowHeight,
      flags = SDL_WINDOW_SHOWN
    )
  sdlFailIf window.isNil: "window could not be created"
  defer: window.destroy()

  let renderer = createRenderer(window,-1,0)
  sdlFailIf renderer.isNil: "renderer could not be created"
  defer: renderer.destroy()

  var
    runLauncher = true
    launcher = newLauncher()

  while runLauncher:
    # Mouse variables
    var
      cmx = 0 # Current mouse x
      cmy = 0 # Current mouse y
      omx = 0 # Old mouse x
      omy = 0 # Old mouse y
      mxc = 0 # Mouse x on click
      myc = 0 # Mouse y on click
      leftMouseButtonDown = false
      event = sdl2.defaultEvent

    var font = readFont("data/Ubuntu-Regular_1.ttf")
    font.size = 32 div scl
    font.paint.color = pixie.color(0, 0, 0, 1)

    var image = newImage(int(WindowWidth), int(WindowHeight))
    var context = newContext(image)
    launcher.draw(context, font)
    renderer.blit(context)
    
    while waitEvent(event):
      case event.kind
      of QuitEvent:
        runLauncher = false
        break
      of MouseButtonUp:
        # Left mouse button is released
        if (event.button.button == 1):
          leftMouseButtonDown = false
          cmx = event.button.x
          cmy = event.button.y
          # Make sure the user isn't just releasing a scroll
          if ((mxc-cmx < 20) and (mxc-cmx > -20) and (myc-cmy < 20) and (myc-cmy > -20)):
            launcher.clickedButton(float32(cmx),float32(cmy))
      of MouseButtonDown:
        # Left mouse button is pressed
        if (event.button.button == 1):
          leftMouseButtonDown = true
          omx = event.button.x
          omy = event.button.y
          mxc = event.button.x
          myc = event.button.y
      of MouseMotion:
        # Mouse is dragged
        if(leftMouseButtonDown):
          cmx = event.motion.x
          cmy = event.motion.y
          # Make sure the user isn't just clicking unsteadily
          if (myc-cmy > 20 or myc-cmy < -20):
            launcher.view.updateViewPosition(float32(0), float32(cmy-omy))
          omx = cmx
          omy = cmy
          launcher.draw(context, font)
          renderer.blit(context)
      else:
        discard

main()