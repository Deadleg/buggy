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
    H.docTypeHtml $ do
        H.head $ do
            H.title (H.toHtml title)
            H.meta ! A.name "viewport" ! A.content "width=device-width, initial-scale=1, shrink-to-fit=no"
            H.link ! A.rel "stylesheet" ! A.href "/assets/css/styles.css"
            H.script ! A.src "https://code.jquery.com/jquery-2.1.4.min.js" $ ""
            H.script ! A.src "https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.2/js/bootstrap.min.js" $ ""
        H.body $ do
            H.nav $ do
                H.nav ! A.class_ "navbar navbar-full" $ do
                    H.div ! A.class_ "container" $ do
                        H.a ! A.class_ "navbar-brand" ! A.href "/" $ "Buggy"
                        H.ul ! A.class_ "nav navbar-nav" $ do
                            H.li ! A.class_ "nav-item" $ do
                               H.a ! A.class_ "nav-link" ! A.href "/browse" $ "Browse games"
                        H.ul ! A.class_ "nav navbar-nav pull-sm-right" $ do
                            H.li ! A.class_ "nav-item" $ do
                               H.a ! A.class_ "nav-link" ! A.href "/account/login" $ "login"
            body
