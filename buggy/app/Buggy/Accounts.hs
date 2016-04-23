{-# LANGUAGE OverloadedStrings #-}
module Buggy.Accounts (
    googleLogin,
) where

import qualified  Web.JWT as JWT
import qualified  Data.Map as Map
import Data.Maybe
import Data.Aeson
import Data.Text
import Buggy.Views.Types

googleLogin :: JWT.JSON -> Either Text JWT.JSON
googleLogin rawJwt = case email of
                        Success s -> Right $ JWT.encodeUnsigned (JWT.JWTClaimsSet (JWT.stringOrURI "buggy") (JWT.stringOrURI s) (Just $ Left (fromJust $ JWT.stringOrURI "buggy")) Nothing Nothing Nothing Nothing Map.empty)
                        Error s -> Left $ pack s
    where email = fromJSON $ fromJust (Map.lookup "email" $ fromJust $ fmap (JWT.unregisteredClaims . JWT.claims) (JWT.decode rawJwt))

