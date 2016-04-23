{-# LANGUAGE OverloadedStrings #-}

module Buggy.Views.Index (
    indexPage
) where

import Happstack.Server
import Happstack.Server.ClientSession
import Buggy.Views.Templates
import Buggy.Views.Types
import Control.Monad.IO.Class
import qualified Data.Text as T
import Text.Blaze.Html5 ((!))
import Buggy.Views.Types
import Buggy.Views.Util (getBuggyCookie)
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
