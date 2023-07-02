--IMPORTS--

import XMonad
import System.Exit
import Prelude hiding (log)
import qualified XMonad.StackSet as W
import qualified Data.Map as M

import Data.Maybe (fromJust)
import Data.Semigroup
import Data.Bits (testBit)

import Control.Monad (unless, when)
import Foreign.C (CInt)
import Data.Foldable (find)

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
-- import XMonad.Layout.HintedGrid
import XMonad.Layout.PerWorkspace

import XMonad.Util.Run
import XMonad.Util.NamedScratchpad
-- import XMonad.Util.NamedActions
import XMonad.Util.SpawnOnce
import XMonad.Util.ClickableWorkspaces
import XMonad.Util.Loggers (logLayoutOnScreen, logTitleOnScreen, shortenL, wrapL, xmobarColorL)
import XMonad.Util.EZConfig (additionalKeysP)
import qualified XMonad.Util.ExtensibleState as XS

import XMonad.Actions.CycleWS
import XMonad.Actions.TiledWindowDragging
import qualified XMonad.Actions.FlexibleResize as Flex
import XMonad.Actions.UpdatePointer (updatePointer)
import XMonad.Actions.OnScreen (onlyOnScreen)
import XMonad.Actions.Warp 
import Data.List
import qualified Data.List as L

myTerminal      = "alacritty"

myColor = mySolarized :: ColorSchemes
-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
myBorderWidth   = 1

--ModKey
myModMask       = mod4Mask

-- Border colors for unfocused and focused windows, respectively.

actionPrefix, actionButton, actionSuffix :: [Char]
actionPrefix = "<action=`xdotool key super+"
actionButton = "` button="
actionSuffix = "</action>"

addActions :: [(String, Int)] -> String -> String
addActions [] ws = ws
addActions (x:xs) ws = addActions xs (actionPrefix ++ k ++ actionButton ++ show b ++ ">" ++ ws ++ actionSuffix)
    where k = fst x
          b = snd x



myNormalBorderColor  = "#dddddd" 
myFocusedBorderColor = "#9531e0"

------------------------------------------------------------------------
myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
myWorkspaceIndices = M.fromList $ zip myWorkspaces [1 ..]
clickable ws = "<action=xdotool key super+" ++ show i ++ ">" ++ ws ++ "</action>"
  where
    i = fromJust $ M.lookup ws myWorkspaceIndices
------------------------------------------------------------------------
--colors
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
                            gray    = "#073642",
                            yellow  = "#b58900",
                            orange  = "#cb4b16",
                            red     = "#d30102",
                            purple  = "#d33682",
                            blue    = "#268bd2",
                            cyan    = "#2aa198",
                            green   = "#859900"
                           }
--
-------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modm,               xK_p     ), spawn "dmenu_run")
    , ((modm,               xK_b     ), spawn "firefox")

    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )
  , ((0          ,0x1008ff11), spawn "pactl set-sink-volume 0 -2%")
  , ((0          ,0x1008ff13), spawn "pactl set-sink-volume 0 +2%")
   , ((0, xF86XK_MonBrightnessUp), spawn "lux -a 10%")
  , ((0, xF86XK_MonBrightnessDown), spawn "lux -s 10%")
    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--

-- mySpacing :: Integer -> Integer -> l a -> ModifiedLayout Spacing l a
-- mySpacing i j = spacingRaw False (Border i i i i) True (Border j j j j) True



myLayout = spacing 5 $ avoidStruts(layoutTall ||| layoutGrid ||| layoutSpiral)
  where
    layoutTall = Tall 1 (3/100) (1/2) 
    layoutSpiral = spiral(6/7) 
    layoutGrid = Grid
    -- myTabTheme = def
    --   { fontName            = "xft:Roboto:size=12:bold"
    --   , activeColor         = grey1
    --   , inactiveColor       = grey1
    --   , activeBorderColor   = grey1
    --   , inactiveBorderColor = grey1
    --   , activeTextColor     = cyan
    --   , inactiveTextColor   = grey3
    --   , decoHeight          = 15
    --   }

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ className =? "Darktable"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
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
------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = return ()

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
    spawnOnce "~/.fehbg &"
    spawnOnce "picom &"

------------------------------------------------------------------------
--
--dynamicloghook
windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myXmobarPP h =
  xmobarPP
    { ppCurrent         = xmobarColor (green myColor) "" . wrap "[" "]",
      ppVisible         = xmobarColor (white myColor) "" . wrap "" "" . clickable,
      ppHidden          = xmobarColor (yellow myColor) "" . wrap "" "" . clickable,
      ppHiddenNoWindows = xmobarColor (white myColor) "" . clickable,
      ppSep             = " | ",
      ppTitle           = xmobarColor (white myColor) "" . shorten 60,
      ppLayout          = xmobarColor  (white myColor) "",
      -- ppOutput          = \x -> hPutStrLn xmproc0 x >> hPutStrLn xmproc1 x,
      --ppExtras          = [windowCount],
      ppOrder           = \(ws : l : t : ex) -> [ws, l, t]
    }









-- myWorkspaceIndices :: M.Map [Char] Integer
-- myWorkspaceIndices = M.fromList $ zip myWorkspaces [1..]

-- clickable :: [Char] -> [Char] -> [Char]
-- clickable icon ws = addActions [ (show i, 1), ("q", 2), ("Left", 4), ("Right", 5) ] icon
--                     where i = fromJust $ M.lookup ws myWorkspaceIndices

-- myStatusBarSpawner :: Applicative f => ScreenId -> f StatusBarConfig
-- myStatusBarSpawner (S s) = do
--                     pure $ statusBarPropTo ("_XMONAD_LOG_" ++ show s)
--                           ("xmobar -x " ++ show s ++ " ~/.config/xmonad/xmobar/xmobar" ++ show s ++ ".hs")
--                           (pure $ myXmobarPP (S s))


-- myXmobarPP :: ScreenId -> PP
-- myXmobarPP s  = filterOutWsPP [scratchpadWorkspaceTag] . marshallPP s $ def
--   { ppSep = ""
--   , ppWsSep = ""
--   , ppCurrent = xmobarColor cyan "" . clickable wsIconFull
--   , ppVisible = xmobarColor grey4 "" . clickable wsIconFull
--   , ppVisibleNoWindows = Just (xmobarColor grey4 "" . clickable wsIconFull)
--   , ppHidden = xmobarColor grey2 "" . clickable wsIconHidden
--   , ppHiddenNoWindows = xmobarColor grey2 "" . clickable wsIconEmpty
--   , ppUrgent = xmobarColor orange "" . clickable wsIconFull
--   , ppOrder = \(ws : _ : _ : extras) -> ws : extras
--   , ppExtras  = [ wrapL (actionPrefix ++ "n" ++ actionButton ++ "1>") actionSuffix
--                 $ wrapL (actionPrefix ++ "q" ++ actionButton ++ "2>") actionSuffix
--                 $ wrapL (actionPrefix ++ "Left" ++ actionButton ++ "4>") actionSuffix
--                 $ wrapL (actionPrefix ++ "Right" ++ actionButton ++ "5>") actionSuffix
--                 $ wrapL "    " "    " $ layoutColorIsActive s (logLayoutOnScreen s)
--                 , wrapL (actionPrefix ++ "q" ++ actionButton ++ "2>") actionSuffix
--                 $  titleColorIsActive s (shortenL 81 $ logTitleOnScreen s)
--                 ]
--   }
--   where
--     wsIconFull   = "  <fn=2>\xf111</fn>   "
--     wsIconHidden = "  <fn=2>\xf111</fn>   "
--     wsIconEmpty  = "  <fn=2>\xf10c</fn>   "
--     titleColorIsActive n l = do
--       c <- withWindowSet $ return . W.screen . W.current
--       if n == c then xmobarColorL cyan "" l else xmobarColorL grey3 "" l
--     layoutColorIsActive n l = do
--       c <- withWindowSet $ return . W.screen . W.current
--       if n == c then wrapL "<icon=/home/amnesia/.config/xmonad/xmobar/icons/" "_selected.xpm/>" l else wrapL "<icon=/home/amnesia/.config/xmonad/xmobar/icons/" ".xpm/>" l

--     blue     = xmobarColor "#bd93f9" ""
--     white    = xmobarColor "#f8f8f2" ""
--     yellow   = xmobarColor "#f1fa8c" ""
--     red      = xmobarColor "#ff5555" ""
--     lowWhite = xmobarColor "#bbbbbb" ""
grey1, grey2, grey3, grey4 :: String
grey1  = "#2B2E37"
grey2  = "#555E70"
grey3  = "#697180"
grey4  = "#8691A8"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
    xmproc <- spawnPipe "xmobar /home/aman/.config/xmobar/.xmobarrc" 
    xmonad $ docks $ def{
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        startupHook        = myStartupHook
        , rootMask = rootMask def .|. pointerMotionMask
        ,logHook = dynamicLogWithPP $ xmobarPP
            { ppCurrent         = xmobarColor (green myColor) "" . wrap "[" "]",
                                                    ppVisible         = xmobarColor (white myColor) "" . wrap "" "" . clickable,
                                                    ppHidden          = xmobarColor (yellow myColor) "" . wrap "" "" . clickable,
                                                    ppHiddenNoWindows = xmobarColor (white myColor) "" . clickable,
                                                    ppSep             = " | ",
                                                    ppTitle           = xmobarColor (white myColor) "" . shorten 60,
                                                    ppLayout          = xmobarColor  (white myColor) "",
                                                    ppOutput          = \x -> hPutStrLn xmproc x,
                                                    --ppExtras          = [windowCount],
                                                    ppOrder           = \(ws : l : t : ex) -> [ws, l, t]
                                            }
        }


--        , logHook            = logHook def <+> myUpdatePointer (0.75, 0.75) (0, 0)
--        -- , handleEventHook    = myHandleEventHook
--        } 

--        -- logHook = dynamicLogWithPP $ xmobarPP
--        -- {
--            -- { ppCurrent         = xmobarColor (green myColor) "" . wrap "[" "]",
--            -- ppVisible         = xmobarColor (white myColor) "" . wrap "" "" . clickable,
--            -- ppHidden          = xmobarColor (yellow myColor) "" . wrap "" "" . clickable,
--            -- ppHiddenNoWindows = xmobarColor (white myColor) "" . clickable,
--            -- ppSep             = " | ",
--            -- ppTitle           = xmobarColor (white myColor) "" . shorten 60,
--            -- ppLayout          = xmobarColor  (white myColor) "",
--            -- ppOutput =hPutStrLn xmproc
--            --ppExtras          = [windowCount],
--            -- ppOrder = (ws : l : t : ex) -> [ws, l, t]
--        -- }


---- A structure containing your configuration settings, overriding
---- fields in the default config. Any you don't override, will
---- use the defaults defined in xmonad/XMonad/Config.hs
----
---- No need to modify this.
----
defaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
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
    "mod-button3  Set the window to floating mode and resize by dragging"]
