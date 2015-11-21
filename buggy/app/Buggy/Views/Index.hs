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
    H.div $ do
        H.h2 "Games"
        H.ul $ do
            H.li $ do
                H.a ! A.href "/app/1" $ "Counter-Strike"
            H.li $ do
                H.a ! A.href "/app/2" $ "Dota 2"
    H.div $ do
        H.a ! A.href "/issues/new" $ "create issue"

