\
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Main where

import           Web.Scotty
import           Network.Wai.Middleware.Cors
import           Network.Wai (Middleware)
import           Network.HTTP.Types.Status (status400)
import           Data.Aeson (FromJSON, ToJSON)
import           GHC.Generics (Generic)

-- Dados que chegam no JSON
data CompoundRequest = CompoundRequest
  { principal    :: Double  -- P > 0
  , rate         :: Double  -- r em decimal, ex: 0.12 = 12%
  , timesPerYear :: Int     -- n >= 1
  , years        :: Double  -- t > 0
  } deriving (Show, Generic)

instance FromJSON CompoundRequest
instance ToJSON CompoundRequest

-- Resposta de sucesso
data CompoundResponse = CompoundResponse
  { amount   :: Double  -- Montante A
  , interest :: Double  -- Juros (A - P)
  } deriving (Show, Generic)

instance ToJSON CompoundResponse

-- Resposta de erro
data ErrorResponse = ErrorResponse
  { error   :: String
  , details :: String
  } deriving (Show, Generic)

instance ToJSON ErrorResponse

-- Cálculo de juros compostos: A = P * (1 + r/n)^(n*t)
calculateCompound :: CompoundRequest -> CompoundResponse
calculateCompound req =
  let p = principal req
      r = rate req
      n = fromIntegral (timesPerYear req)
      t = years req
      a = p * (1 + r / n) ** (n * t)
  in CompoundResponse
       { amount   = a
       , interest = a - p
       }

-- Validação de entrada
validateRequest :: CompoundRequest -> Either String CompoundRequest
validateRequest req
  | principal req <= 0    = Left "O valor inicial (principal) deve ser > 0."
  | rate req < 0          = Left "A taxa (rate) não pode ser negativa."
  | timesPerYear req < 1  = Left "timesPerYear deve ser >= 1."
  | years req <= 0        = Left "years deve ser > 0."
  | otherwise             = Right req

-- Middleware de CORS (liberando tudo; ideal é restringir ao domínio do frontend)
simpleCorsMiddleware :: Middleware
simpleCorsMiddleware = cors (const $ Just policy)
  where
    policy = simpleCorsResourcePolicy
      { corsRequestHeaders = ["Content-Type"]
      }

main :: IO ()
main = do
  putStrLn "Iniciando servidor na porta 8080..."
  scotty 8080 $ do
    middleware simpleCorsMiddleware

    post "/api/compound" $ do
      reqJson <- jsonData `rescue` \_ -> do
        status status400
        json $ ErrorResponse
          { error   = "JSON inválido"
          , details = "Verifique se todos os campos foram enviados corretamente."
          }
        finish

      case validateRequest reqJson of
        Left msg -> do
          status status400
          json $ ErrorResponse
            { error   = "Dados inválidos"
            , details = msg
            }
        Right validReq -> do
          let resp = calculateCompound validReq
          json resp
