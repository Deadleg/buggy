{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE TemplateHaskell #-}

module Buggy.Web.Types (
    GoogleToken(..)
) where

import Data.Text
import Data.Aeson
import qualified Web.JWT as JWT

data GoogleToken = GoogleToken
    { token :: Text
    } deriving (Eq, Read, Show)

instance FromJSON GoogleToken where
    parseJSON (Object o) = GoogleToken <$> o .: "token"