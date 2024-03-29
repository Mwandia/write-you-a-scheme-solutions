module Main where
import Control.Monad (liftM)
import Data.Char (toLower)
import Data.Complex (Complex (..))
import Data.Ratio ((%), Rational)
import Numeric (readOct, readHex)
import System.Environment
import Text.ParserCombinators.Parsec hiding (spaces)

main :: IO ()
main = do
  args <- getArgs
  putStrLn(readExpr (args !! 0))

data LispVal = Atom String
  | List [LispVal]
  | DottedList [LispVal] LispVal
  | Number Integer
  | String String
  | Bool Bool
  | Char Char
  | Float Double 
  | Ratio Rational
  | Complex (Complex Double)
    deriving (Show)

-----------------------------------------
--           LispVal Parsers           --
-----------------------------------------
parseList :: Parser LispVal
parseList = liftM List $ sepBy parseExpr spaces

parseDottedList :: Parser LispVal
parseDottedList = do
  head <- endBy parseExpr spaces
  tail <- char '.' >> spaces >> parseExpr
  return $ DottedList head tail

parseQuoted :: Parser LispVal
parseQuoted = do
  char '\'0'
  x <- parseExpr
  return $ List [Atom "quote", x]

parseFloat :: Parser LispVal
parseFloat = do 
  whole <- many1 digit
  char '.'
  decimal <- many1 digit
  return $ Float(read (whole ++ "." ++ decimal) :: Double) 

parseChar :: Parser LispVal
parseChar = do
  string "#\\"
  s <- many1 letter
  return $ case (map toLower s) of
    "space" -> Char ' '
    "newline" -> Char '\n'
    [x] -> Char x

parseString :: Parser LispVal
parseString = do 
  char '"'
  s <- many (escapedChars <|> (noneOf ['\\', '"']))
  char '"'
  return $ String s

parseBool :: Parser LispVal
parseBool = do
  char '#'
  c <- oneOf "tf"
  return $ case c of
    't' -> Bool True
    'f' -> Bool False

parseNatNumber :: Parser LispVal
parseNatNumber = many1 digit >>= return . Number . read

parseRadixNumber :: Parser LispVal
parseRadixNumber = char '#' >>
  (
    parseDecimal <|> parseBinary <|> parseOctal <|> parseHex
  )

parseDecimal :: Parser LispVal
parseDecimal = do
  char 'd'
  n <- many digit
  (return . Number . read) n

parseBinary :: Parser LispVal
parseBinary = do
  char 'b'
  n <- many $ oneOf "01"
  (return . Number . bin2int) n

parseOctal :: Parser LispVal
parseOctal = do
  char 'o'
  n <- many $ oneOf "01234567"
  (return . Number . (readWith $ readHex)) n

parseHex :: Parser LispVal
parseHex = do
  char 'x'
  n <- many $ oneOf "0123456789abcdefABCDEF"
  (return . Number . (readWith $ readHex)) n

parseNumber :: Parser LispVal
parseNumber = do
  digits <- many1 digit
  return $ (Number . read) digits

parseRatio :: Parser LispVal
parseRatio = do
  num <- fmap read $ many1 digit
  char '/'
  denom <- fmap read $ many1 digit
  (return . Ratio) (num % denom)

parseComplex :: Parser LispVal
parseComplex = do
  r <- fmap toDouble (try parseFloat <|> parseNatNumber)
  char '+'
  i <- fmap toDouble (try parseFloat <|> parseNatNumber)
  char 'i'
  (return . Complex) (r :+ i)
  where toDouble (Float x) = x
        toDouble (Number x) = fromIntegral x

parseAtom :: Parser LispVal
parseAtom = do 
  first <- letter <|> symbol
  rest <- many (letter <|> digit <|> symbol)
  (return . Atom) (first:rest)

parseExpr :: Parser LispVal
parseExpr = parseAtom
  <|> parseString
  <|> parseChar
  <|> parseComplex
  <|> parseFloat
  <|> parseRatio
  <|> parseNumber
  <|> parseBool

-----------------------------------------
--          Helper Functions           --
-----------------------------------------
readExpr :: String -> String
readExpr input = case
  parse parseExpr "lisp" input of
    Left err -> "No match: " ++ show err
    Right _ -> "Found value"

escapedChars :: Parser Char
escapedChars = do
  char '\\'
  c <- oneOf ['\\','"','n','r','t']
  return $ case c of 
    '\\' -> c
    '"' -> c 
    'n' -> '\n' 
    'r' -> '\r' 
    't' -> '\t'

bin2int :: String -> Integer
bin2int s = sum $ map (\(i,x) -> i*(2^x)) $ zip [0..] $ map p (reverse s)
  where p '0' = 0
        p '1' = 1

symbol :: Parser Char
symbol = oneOf "!#$%&*|+-/:<=>?@^_~"

spaces :: Parser ()
spaces = skipMany1 space

readWith f s = fst $ f s !! 0 