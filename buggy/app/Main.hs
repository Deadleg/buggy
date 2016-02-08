{-# LANGUAGE OverloadedStrings #-}
module Main where

import Buggy.Views.Index
import qualified Buggy.Rest.Program as R
import Buggy.Logic.Issue
import Control.Monad (msum)
import Control.Applicative ((<$>), optional)
import Happstack.Server
import qualified Data.Text as T
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A

main = simpleHTTP nullConf $ msum
    [ dir "assets" $ serveDirectory EnableBrowsing [] "/home/deadleg/buggy/buggy/web/assets"
    , dirs "api/programs" $ path $ \programId -> dirs "issues/new" $ do method POST
                                                                        R.createIssue programId
    , dirs "api/programs" $ path $ \programId -> dir "issues" $ path $ \issueId -> dirs "reports/new" $ do method POST
                                                                                                           R.createIssueReport programId issueId
    , dirs "api/programs" $ path $ \programId -> dir "issues" $ path $ \issueId -> dir "reports" $ path $ \reportId -> dir "fixed" $ do method POST
                                                                                                                                        R.issueReportFixed programId issueId reportId
    , dirs "api/programs" $ path $ \programId -> dir "issues" $ path $ \issueId -> dir "fixed" $ do method POST
                                                                                                    R.issueFixed programId issueId
    , dirs "api/programs" $ path $ \programId -> dir "issues" $ path $ \issueId -> dir "reports" $ path $ \reportId -> dir "comments" $ path $ \commentId -> dir "report" $ do method POST
                                                                                                                                                                               R.reportIssueReportComment programId issueId reportId commentId
    , dirs "api/programs" $ path $ \programId -> dir "issues" $ path $ \issueId -> dir "reports" $ path $ \reportId -> dir "comments" $ do method GET
                                                                                                                                           R.getIssueReportComments programId issueId reportId
    , dirs "api/programs" $ path $ \programId -> dir "issues" $ path $ \issueId -> dir "reports" $ path $ \reportId -> dir "comments" $ do method POST
                                                                                                                                           R.createIssueReportComment programId issueId reportId
    , dirs "api/programs" $ path $ \programId -> dir "issues" $ path $ \issueId -> dir "comments" $ path $ \commentId -> dir "report" $ do method POST
                                                                                                                                           R.reportIssueComment programId issueId commentId
    , dirs "api/programs" $ path $ \programId -> dir "issues" $ path $ \issueId -> dir "comments" $ do method GET
                                                                                                       R.getIssueComments programId issueId
    , dirs "api/programs" $ path $ \programId -> dir "issues" $ path $ \issueId -> dir "comments" $ do method POST
                                                                                                       R.createIssueComment programId issueId
    , dirs "api/programs" $ path $ \programId -> dir "issues" $ path $ \issueId -> dir "reports" $ path $ \reportId -> do method PUT
                                                                                                                          R.updateIssueReport programId issueId reportId
    , dirs "api/programs" $ path $ \programId -> dir "issues" $ path $ \issueId -> dir "reports" $ R.getIssueReports programId issueId
    , dirs "api/programs" $ path $ \programId -> dir "issues" $ path $ \issueId -> do method PUT
                                                                                      R.updateIssue programId issueId
    , dirs "api/programs" $ path $ \programId -> dir "issues" $ path $ \issueId -> R.getIssueForProgram programId issueId
    , dirs "api/programs" $ path $ \programId -> dir "issues" $ R.getIssuesForProgram programId
    , dirs "api/programs" $ path $ \programId -> R.getProgramJSON programId
    , dirs "api/programs" $ R.getAllPrograms
    , dirs "" $ indexPage
    ]

