{-# LANGUAGE OverloadedStrings #-}

module Buggy.Views.Templates (
    mainTemplate
) where

import Happstack.Server
import qualified Data.Text as T
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A

mainTemplate :: T.Text -> H.Html -> Response
mainTemplate title body = toResponse $
    H.html $ do
        H.head $ do
            H.title (H.toHtml title)
        H.body $ do
            body
