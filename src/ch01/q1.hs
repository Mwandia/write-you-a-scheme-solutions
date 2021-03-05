module Main where
import System.Environment

main :: IO ()
main = do
  putStrLn("Hello! Please Enter your name: ")
  name <- getLine
  putStrLn("Welcome " ++ name)