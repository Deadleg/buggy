{-# LANGUAGE OverloadedStrings #-}

module Buggy.Views.Templates (
    mainTemplate
) where

import Happstack.Server
import Text.Blaze.Html5 ((!))
import qualified Data.Text as T
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A

mainTemplate :: T.Text -> H.Html -> Response
mainTemplate title body = toResponse $
    H.html $ do
        H.head $ do
            H.title (H.toHtml title)
            H.link ! A.rel "stylesheet" ! A.href "http://fonts.googleapis.com/icon?family=Material+Icons"
            H.link ! A.rel "stylesheet" ! A.href "https://cdnjs.cloudflare.com/ajax/libs/materialize/0.97.3/css/materialize.min.css"
            H.meta ! A.name "viewport" ! A.content "width=device-width, initial=scale=1.0"
            H.script ! A.src "https://code.jquery.com/jquery-2.1.4.min.js" $ ""
            H.script ! A.src "https://cdnjs.cloudflare.com/ajax/libs/materialize/0.97.3/js/materialize.min.js" $ ""
        H.body $ do
            H.nav $ do
                H.div ! A.class_ "nav-wrapper container" $ do
                    H.a ! A.class_ "brand-logo" ! A.href "/" $ "Buggy"
            H.div ! A.class_ "row" $ do
                H.div ! A.class_ "container" $ do
                    body
