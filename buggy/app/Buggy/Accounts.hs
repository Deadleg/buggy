{-# LANGUAGE OverloadedStrings #-}
module Buggy.Accounts (
    googleLogin,
    newLogin,
    getEmail,
    getUser
) where

import qualified  Web.JWT as JWT
import qualified  Data.Map as Map
import Data.Maybe
import Data.Aeson
import Data.Text
import Buggy.Views.Types
import Buggy.Types.Types
import qualified Buggy.Persistence.Postgre as DB

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

