----------------------------------------------IMPORTS----------------------------------------------
--
import XMonad
import System.Exit
import Prelude hiding (log)
import Control.Monad (unless, when)
import Foreign.C (CInt)

import Data.Maybe (fromJust)
import Data.Semigroup
import Data.Bits (testBit)
import Data.Foldable (find)
import Data.List

import Graphics.X11.Xinerama (getScreenInfo)
import Graphics.X11.ExtraTypes.XF86

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.InsertPosition (insertPosition, Focus(Newer), Position (Master, End))
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.WindowSwallowing
import XMonad.Hooks.StatusBar
import XMonad.Hooks.ManageHelpers (isDialog, doCenterFloat, doSink)
import XMonad.Hooks.RefocusLast (isFloat)

import XMonad.Layout.Spacing (Spacing, spacingRaw, Border (Border))
import XMonad.Layout.NoBorders (smartBorders)
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.Decoration (ModifiedLayout)
import XMonad.Layout.DraggingVisualizer (draggingVisualizer)
import XMonad.Layout.MultiToggle.Instances (StdTransformers (NBFULL))
import XMonad.Layout.MultiToggle (EOT (EOT), Toggle (Toggle), mkToggle, (??))
import XMonad.Layout.MouseResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.Spiral
import XMonad.Layout.Grid
import XMonad.Layout.Spacing
import XMonad.Layout.IndependentScreens
import XMonad.Layout.PerWorkspace

import XMonad.Util.Run
import XMonad.Util.NamedScratchpad
import XMonad.Util.SpawnOnce
import XMonad.Util.ClickableWorkspaces
import XMonad.Util.Loggers (logLayoutOnScreen, logTitleOnScreen, shortenL, wrapL, xmobarColorL)
import XMonad.Util.EZConfig (additionalKeysP)

import XMonad.Actions.CycleWS
import XMonad.Actions.TiledWindowDragging
import XMonad.Actions.UpdatePointer (updatePointer)
import XMonad.Actions.OnScreen (onlyOnScreen)
import XMonad.Actions.Warp 

import qualified Data.List as L
import qualified XMonad.StackSet as W
import qualified Data.Map as M
import qualified XMonad.Util.ExtensibleState as XS
import qualified XMonad.Actions.FlexibleResize as Flex
--
---------------------------------------------DEFAULTS----------------------------------------------
--
myTerminal      = "alacritty"
myBorderWidth   = 1
myModMask       = mod4Mask
myColor = mySolarized :: ColorSchemes

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True
myClickJustFocuses :: Bool
myClickJustFocuses = False

myNormalBorderColor  = "#dddddd" 
myFocusedBorderColor = "#9531e0"

actionPrefix, actionButton, actionSuffix :: [Char]
actionPrefix = "<action=`xdotool key super+"
actionButton = "` button="
actionSuffix = "</action>"

addActions :: [(String, Int)] -> String -> String
addActions [] ws = ws
addActions (x:xs) ws = addActions xs (actionPrefix ++ k ++ actionButton ++ show b ++ ">" ++ ws ++ actionSuffix)
    where k = fst x
          b = snd x
--
---------------------------------------------WORKSPACES---------------------------------------------
--
myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
myWorkspaceIndices = M.fromList $ zip myWorkspaces [1 ..]
clickable ws = "<action=xdotool key super+" ++ show i ++ ">" ++ ws ++ "</action>"
  where
    i = fromJust $ M.lookup ws myWorkspaceIndices
--
-----------------------------------------------COLORS-----------------------------------------------
--
data ColorSchemes = ColorSchemes{black ,white ,gray ,yellow ,orange ,red ,purple ,blue ,cyan ,green :: String}

myGruvbox :: ColorSchemes
myGruvbox = ColorSchemes {
                          black   = "#282828",
                          white   = "#ebdbb2",
                          gray    = "#928374",
                          yellow  = "#fabd2f",
                          orange  = "#fe8019",
                          red     = "#fb4934",
                          purple  = "#d3869b",
                          blue    = "#83a598",
                          cyan    = "#8ec07c",
                          green   = "#b8bb26"
                         }

mySolarized :: ColorSchemes
mySolarized = ColorSchemes {
                            black   = "#002b36",
                            white   = "#eee8d5",
                            gray    = "#b8b8b8",
                            yellow  = "#b58900",
                            orange  = "#cb4b16",
                            red     = "#d30102",
                            purple  = "#d33682",
                            blue    = "#268bd2",
                            cyan    = "#2aa198",
                            green   = "#00A86B"
                           }
--
---------------------------------------------KEYBINDS-----------------------------------------------
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    [
    ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    , ((modm,               xK_p     ), spawn "dmenu_run")
    , ((modm,               xK_b     ), spawn "firefox")
    , ((modm,               xK_f     ), spawn "thunar")
    , ((modm .|. shiftMask, xK_c     ), kill)
    , ((modm,               xK_space ), sendMessage NextLayout)
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
    , ((modm,               xK_n     ), refresh)
    , ((modm,               xK_Tab   ), windows W.focusDown)
    , ((modm,               xK_j     ), windows W.focusDown)
    , ((modm,               xK_k     ), windows W.focusUp  )
    , ((modm,               xK_m     ), windows W.focusMaster  )
    , ((0,                  xK_Print ), spawn "scrot ~/Pictures/Screenshots/%b_%d_%H:%M:%S.png")
    , ((0    .|. shiftMask, xK_Print ), spawn "scrot -s ~/Pictures/Screenshots/%b_%d_%H:%M:%S.png")
    , ((0          ,0x1008ff11), spawn "pactl set-sink-volume 0 -2%")
    , ((0          ,0x1008ff13), spawn "pactl set-sink-volume 0 +2%")
    , ((0          ,0x1008ffb2), spawn "pactl set-source-mute 1 toggle")
    , ((0, xF86XK_MonBrightnessUp), spawn "lux -a 10%")
    , ((0, xF86XK_MonBrightnessDown), spawn "lux -s 10%")
    , ((modm,               xK_Return), windows W.swapMaster)
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )
    , ((modm,               xK_h     ), sendMessage Shrink)
    , ((modm,               xK_l     ), sendMessage Expand)
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))
    ]
--
---------------------------------------------LAYOUTS-----------------------------------------
--
myLayout = layoutTall ||| noBorders Full
  where
    layoutTall = spacingWithEdge 2 $ avoidStruts(Tall 1 (3/100) (1/2))
--
---------------------------------------------WINDOW_RULES-----------------------------------------
--
myManageHook = composeAll
    [ className =? "Darktable"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore]
--
---------------------------------------------EVENT_HANDLING-----------------------------------------
--
myEventHook = mempty

newtype MyUpdatePointerActive = MyUpdatePointerActive Bool
instance ExtensionClass MyUpdatePointerActive where
  initialValue = MyUpdatePointerActive True

myUpdatePointer :: (Rational, Rational) -> (Rational, Rational) -> X ()
myUpdatePointer refPos ratio =
  whenX isActive $ do
    dpy <- asks display
    root <- asks theRoot
    (_,_,_,_,_,_,_,m) <- io $ queryPointer dpy root
    unless (testBit m 9 || testBit m 8 || testBit m 10) $ -- unless the mouse is clicking
      updatePointer refPos ratio

  where
    isActive = (\(MyUpdatePointerActive b) -> b) <$> XS.get
--
-----------------------------------------------STATUS_BAR------------------------------------------ 
--
myLogHook = return ()
--
----------------------------------------------STARTUP_HOOKS----------------------------------------
--
myStartupHook = do
    spawnOnce "~/.fehbg &"
    spawnOnce "picom &"
    spawnOnce "gummy start"
    spawnOnce "xrandr -r 60"
--
--------------------------------------------DYNAMIC_LOG_HOOK---------------------------------------
--
windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myXmobarPP h =
  xmobarPP
    {  ppCurrent         = xmobarColor (green myColor) "" . wrap "" "".xmobarBorder "Bottom" "#01796f" 2
    ,  ppVisible         = xmobarColor (white myColor) "" . wrap "" "" 
    ,  ppHidden          = xmobarColor (yellow myColor) "" . wrap "" "" 
    ,  ppHiddenNoWindows = shorten' ""  0
    ,  ppSep             = " | "
    ,  ppTitle           = xmobarColor (white myColor) "" . shorten 60
    ,  ppLayout          = xmobarColor  (white myColor) ""
--  ,  ppOutput          = \x -> hPutStrLn xmproc0 x >> hPutStrLn xmproc1 x
--  ,  ppExtras          = [windowCount]
    ,  ppOrder           = \(ws : l : t : ex) -> [ws, l, t]
    }

grey1, grey2, grey3, grey4 :: String
grey1  = "#2B2E37"
grey2  = "#555E70"
grey3  = "#697180"
grey4  = "#8691A8"
--
----------------------------------------------------MASTER------------------------------------------
--
main = do
    xmproc <- spawnPipe "xmobar /home/aman/.config/xmonad/xmobar/.xmobarrc" 
    xmonad $ docks $ def{
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

        keys               = myKeys,
        mouseBindings      = myMouseBindings,

        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        startupHook        = myStartupHook
        , rootMask = rootMask def .|. pointerMotionMask
        ,logHook = dynamicLogWithPP $ xmobarPP
                                                {   ppCurrent         = xmobarColor (green myColor) "" . wrap "" "".xmobarBorder "Bottom" "#00A86B" 3
                                                ,    ppTitleSanitize   = xmobarStrip
                                            --  ,    ppVisible         = xmobarColor (white myColor) "" . wrap "" ""
                                                ,    ppHidden          = xmobarColor (yellow myColor) "" . wrap "" ""
                                                ,    ppHiddenNoWindows = shorten' "" 0
                                                ,    ppSep             = " " 
                                                ,    ppTitle           = xmobarColor (gray myColor) "" . shorten 50 . wrap "[" "]"
                                                ,    ppLayout          = xmobarColor  (white myColor) ""
                                                ,    ppOutput          = \x -> hPutStrLn xmproc x
                                             -- ,    --ppExtras          = [windowCount]
                                                ,    ppOrder           = \(ws : l : t : ex) -> [ws, t]
                                            }
        }

defaults = def {
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

        keys               = myKeys,
        mouseBindings      = myMouseBindings,

        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }

help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging",
    "pactl set-source-volume 1 <volume> for microphone volume setting."]
