{-# LANGUAGE OverloadedStrings #-}

module Buggy.Views.Index (
    indexPage
) where

import Happstack.Server
import Buggy.Views.Templates
import qualified Data.Text as T
import Text.Blaze.Html5 ((!))
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A

indexPage :: ServerPart Response
indexPage = ok $ mainTemplate "Welcome to buggy!" $ do
    H.div ! A.id "content" $ ""
    H.script ! A.src "/assets/js/index.js" $ ""

