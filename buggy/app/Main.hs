{-# LANGUAGE OverloadedStrings #-}

module Main where

import Buggy.Views.Index
import Buggy.Views.Game
import Buggy.Views.Issue
import Buggy.Views.IssueReport
import Buggy.Logic.Issue
import Control.Monad (msum)
import Control.Applicative ((<$>), optional)
import Happstack.Server
import qualified Data.Text as T
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A

main = simpleHTTP nullConf $ msum
    [ dir "app" $ path $ \programId -> dir "issue" $ path $ \issueId -> dir "report" $ dir "create" $ createIssueReportPage programId issueId
    , dir "app" $ path $ \programId -> dir "issue" $ path $ \issueId -> issuePage programId issueId
    , dir "app" $ path $ \programId -> dir "create" $ createIssuePage programId
    , dir "app" $ path $ \programId -> dir "create" $ do method POST
                                                         createIssuePage programId
    , dir "app" $ path $ \programId ->  gamePage programId
    , dirs "" $ indexPage 
    ]

