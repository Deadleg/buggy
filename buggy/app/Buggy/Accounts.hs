{-# LANGUAGE OverloadedStrings #-}
module Buggy.Accounts (
    googleLogin,
    steamLogin,
    newLogin,
    getEmail,
    getUser,
    getSteamInfo,
    SteamUser(..),
    SteamResponse(..)
) where

import qualified  Web.JWT as JWT
import qualified  Data.Map as Map
import Data.Maybe
import Data.Aeson
import Data.Text hiding (head)
import Buggy.Views.Types
import Buggy.Types.Types
import Network.HTTP.Simple
import Network.HTTP.Conduit
import qualified Buggy.Persistence.Postgre as DB

data SteamUser = SteamUser {
    steamid :: String,
    personname :: String,
    realname :: String,
    loccountrycode :: String
} deriving (Eq, Read, Show)

data SteamPlayers = SteamPlayers { players :: [SteamUser] } deriving (Eq, Read, Show)
data SteamResponse = SteamResponse { steamResponse :: SteamPlayers } deriving (Eq, Read, Show)

instance FromJSON SteamPlayers where
    parseJSON (Object v) = SteamPlayers <$> v .: "players"

instance FromJSON SteamResponse where
    parseJSON (Object v) = SteamResponse <$> v .: "response"

instance FromJSON SteamUser where
    parseJSON (Object v) = SteamUser <$>
                v .: "steamid" <*>
                v .: "personaname" <*>
                v .: "realname" <*>
                v .: "loccountrycode"

steamLogin :: Text -> JWT.JSON
steamLogin steamId = JWT.encodeUnsigned (JWT.JWTClaimsSet (JWT.stringOrURI "buggy") (JWT.stringOrURI (steamId)) (Just $ Left (fromJust $ JWT.stringOrURI "buggy")) Nothing Nothing Nothing Nothing Map.empty)

getSteamInfo :: Text -> IO (SteamUser)
getSteamInfo steamId = do
    request <- parseUrl $ unpack ("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=***REMOVED***&steamids=" `append` steamId)
    response <- httpJSON request
    return (head $ players $ steamResponse (getResponseBody response :: SteamResponse))

googleLogin :: JWT.JSON -> JWT.JSON
googleLogin rawJwt = JWT.encodeUnsigned (JWT.JWTClaimsSet (JWT.stringOrURI "buggy") (JWT.stringOrURI (getEmail rawJwt)) (Just $ Left (fromJust $ JWT.stringOrURI "buggy")) Nothing Nothing Nothing Nothing Map.empty)

newLogin :: NewUser -> IO (User)
newLogin newUser = do
    id <- DB.createNewUser newUser
    putStrLn "new user"
    return $ ExistingUser id (email newUser)

getUser :: Text -> IO (Maybe User)
getUser email = DB.getUser email

getEmail :: JWT.JSON -> Text
getEmail rawJwt = case result of
                        Success email -> email
                        Error s -> pack s
     where result = fromJSON $ fromJust (Map.lookup "email" $ fromJust $ fmap (JWT.unregisteredClaims . JWT.claims) (JWT.decode rawJwt))

