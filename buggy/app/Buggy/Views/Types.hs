{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE TemplateHaskell #-}
module Buggy.Views.Types (
    GoogleToken(..)
) where

import Data.SafeCopy (base, deriveSafeCopy)
import Happstack.Server.ClientSession
import Data.Text
import Data.Data
import Data.Aeson
import qualified Web.JWT as JWT

data GoogleToken = GoogleToken
    { token :: Text
    } deriving (Eq, Read, Show)

instance FromJSON GoogleToken where
    parseJSON (Object o) = GoogleToken <$> o .: "token"