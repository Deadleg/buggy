{-# LANGUAGE OverloadedStrings #-}

module Buggy.Web.Views.Index (
    indexPage
) where

import Buggy.Web.Views.Templates
import Buggy.Web.Types
import Buggy.Web.Util (getBuggyCookie)
import Happstack.Server
import Control.Monad.IO.Class
import Text.Blaze.Html5 ((!))
import qualified Data.Text as T
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A

indexPage :: ServerPart Response
indexPage = do
    req <- askRq
    let cookies = getBuggyCookie (rqCookies req)
    liftIO $ putStrLn $ show cookies
    ok $ mainTemplate Nothing "Welcome to buggy!" $ do
        H.div ! A.id "content" $ ""
        H.script ! A.src "/assets/js/index.js" $ ""
        H.script ! A.src "/assets/js/user.js" $ ""
        H.script ! A.src "/assets/js/login.js" $ ""

