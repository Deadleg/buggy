{-# LANGUAGE OverloadedStrings #-}

module Buggy.Web.Views.Templates (
    mainTemplate
) where

import Happstack.Server
import Text.Blaze.Html5 ((!))
import Buggy.Web.Types
import Buggy.Core.Types
import qualified Data.Text as T
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A

mainTemplate :: Maybe User -> T.Text -> H.Html -> Response
mainTemplate user title body = toResponse $
    H.docTypeHtml $ do
        H.head $ do
            H.title (H.toHtml title)
            H.meta ! A.name "viewport" ! A.content "width=device-width, initial-scale=1, shrink-to-fit=no"
            H.meta ! A.name "google-signin-client_id" ! A.content "931217227366-grrs673cmh7rn4q1foglmnmqjq12dipl.apps.googleusercontent.com"
            H.link ! A.rel "stylesheet" ! A.href "/assets/css/styles.css"
            H.script ! A.src "https://code.jquery.com/jquery-2.1.4.min.js" $ ""
            H.script ! A.src "https://apis.google.com/js/platform.js" $ ""
            H.script ! A.src "https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.3/js/bootstrap.min.js" $ ""
            H.script ! A.src "https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.13.0/moment.min.js" $ ""
            H.script ! A.src "https://cdnjs.cloudflare.com/ajax/libs/react/15.3.0/react.js" $ ""
            H.script ! A.src "https://cdnjs.cloudflare.com/ajax/libs/react/15.3.0/react-dom.js" $ ""
            H.script ! A.src "https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.1.6/Chart.min.js" $ ""
            H.script ! A.src "https://cdnjs.cloudflare.com/ajax/libs/redux/3.5.2/redux.min.js" $ ""
            H.script ! A.src "https://cdnjs.cloudflare.com/ajax/libs/react-redux/4.4.5/react-redux.min.js" $ ""
        H.body $ do
            H.nav $ do
                H.nav ! A.class_ "navbar navbar-full" $ do
                    H.div ! A.class_ "container" $ do
                        H.a ! A.class_ "navbar-brand" ! A.href "/" $ "Buggy"
                        H.ul ! A.class_ "nav navbar-nav" $ do
                            H.li ! A.class_ "nav-item" $ do
                               H.a ! A.class_ "nav-link" ! A.href "/browse" $ "Browse games"
                            H.li ! A.class_ "nav-item" $ do
                               H.a ! A.class_ "nav-link" ! A.href "/issues/create" $ "Report an issue"
                        H.ul ! A.class_ "nav navbar-nav pull-sm-right" $ do
                            case user of
                                Nothing -> H.li ! A.class_ "nav-item" $ do
                                               H.a ! A.class_ "nav-link" ! A.id "signin-link"! A.href "/account/login" $ "Sign In"
                                Just (ExistingUser id username) -> H.li ! A.class_ "nav-item" $ do
                                                                       H.a ! A.class_ "nav-link" ! A.id "account"! A.href "#/account" $ H.toHtml $ username
            body
