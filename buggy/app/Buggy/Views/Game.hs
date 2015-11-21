{-# LANGUAGE OverloadedStrings #-}

module Buggy.Views.Game (
    gamePage
) where

import Happstack.Server
import Buggy.Views.Templates
import qualified Data.Text as T
import Text.Blaze.Html5 ((!))
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A

gamePage :: Integer -> ServerPart Response
gamePage programId = ok $ mainTemplate "Counter strike!" $ do
    H.h2 "Issues"
    H.a ! A.href "/app/1/create" $ "create issue"
    H.ul $ do
        H.li $ do
            H.a ! A.href "/app/1/issue/1" $ "Hitreg pls"
        H.li $ do
            H.a ! A.href "/app/1/issue/2" $ "Lighing pls"
