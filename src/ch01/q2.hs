module Main where
import System.Environment

main :: IO ()
main = do
  args <- fmap (fmap $ read) getArgs
  (putStrLn . show) ((args !! 0) + (args !! 1))