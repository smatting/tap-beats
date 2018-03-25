{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Monad
import Data.Foldable (for_)
import Foreign.C.Types
import SDL.Vect
import SDL (($=))
import qualified SDL
import Data.Word (Word8)
import SDL.Time (time)

screenWidth, screenHeight :: CInt
(screenWidth, screenHeight) = (640, 480)

expFadeOut a t = exp (- (a * t))

intensityColor :: Double -> V4 Word8
intensityColor intensity =
    let s = fromIntegral $ min (ceiling $ 255.0 * intensity) 255
    in V4 s s 0 0

bmp2Secs bmp = 60.0 / bmp
secs2bmp secs = 60.0 / secs

(%) :: (RealFrac a) => a -> a -> a  
(%) dividend divisor = dividend - divisor * (fromIntegral $ floor (dividend/divisor))

keyWasPressed keyMapLast keyMap scancode =
    (keyMap scancode) && not (keyMapLast scancode)

triangleDist width origin x = 
    let d = x - origin
    in max (1 - d / width) 0

estimateBeats :: (Double, Double) -> [Double] -> (Double, Double)
estimateBeats oldEst []      = oldEst
estimateBeats oldEst (x:xs)  = estimateBeats' oldEst (takeWhile (\y -> x - y < 10.0) (x:xs))
    where estimateBeats' (tZero, periodLength) ys@(x:xs) =
              let d'  = zipWith (-) ys (tail ys)
                  d   = takeWhile (< (bmp2Secs 70)) d'
                  avg = sum d / fromIntegral (max (length d) 1)
              in if length d > 0 then (x, avg)
              else (x, periodLength)

main :: IO ()
main = do
  SDL.initialize [SDL.InitVideo]

  SDL.HintRenderScaleQuality $= SDL.ScaleLinear
  do renderQuality <- SDL.get SDL.HintRenderScaleQuality
     when (renderQuality /= SDL.ScaleLinear) $
       putStrLn "Warning: Linear texture filtering not enabled!"

  window <-
    SDL.createWindow
      "SDL Tutorial"
      SDL.defaultWindow {SDL.windowInitialSize = V2 screenWidth screenHeight}
  SDL.showWindow window

  renderer <-
    SDL.createRenderer
      window
      (-1)
      SDL.RendererConfig
         { SDL.rendererType = SDL.AcceleratedVSyncRenderer
         , SDL.rendererTargetTexture = False
         }

  SDL.rendererDrawColor renderer $= V4 maxBound maxBound maxBound maxBound

  let loop keyMap tZero periodLength timestamps = do
        now <- time

        events <- SDL.pollEvents

        keyMap' <- SDL.getKeyboardState

        let quit = (elem SDL.QuitEvent $ map SDL.eventPayload events)
                   || keyWasPressed keyMap keyMap' SDL.ScancodeQ

        let spacePressed            = keyWasPressed keyMap keyMap' SDL.ScancodeSpace
            timestamps'             = if spacePressed then now:timestamps else timestamps
            (tZero', periodLength') = estimateBeats (tZero, periodLength) timestamps'
            -- tZero'        = if spacePressed then now else tZero
            -- periodLength' = periodLength
        when spacePressed $ print (tZero', secs2bmp periodLength')


        SDL.rendererDrawColor renderer $= V4 maxBound maxBound maxBound maxBound
        SDL.clear renderer

        let tBeat' = (now - tZero') % periodLength'
            tBeat  = tBeat' / periodLength'

        -- SDL.rendererDrawColor renderer $= V4 255 255 0 0
        SDL.rendererDrawColor renderer $= (intensityColor (expFadeOut (3*periodLength') tBeat))
        SDL.fillRect renderer Nothing

        SDL.present renderer

        unless quit $ loop keyMap' tZero' periodLength' timestamps'

  tZero <- time
  keyMap <- SDL.getKeyboardState
  let periodLength = (bmp2Secs 120.0)
  loop keyMap tZero periodLength []

  SDL.destroyRenderer renderer
  SDL.destroyWindow window
  SDL.quit