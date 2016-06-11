{-# LANGUAGE OverloadedStrings #-}
module Main where

import Buggy.Web.Views.Index
import Control.Monad (msum)
import Control.Applicative ((<$>), optional)
import Happstack.Server
import qualified Buggy.Web.Entry as R

main = do
    simpleHTTP nullConf $ msum
        [ dir "assets" $ serveDirectory EnableBrowsing [] "/home/deadleg/buggy/web/assets"
        , dirs "api/account/login/google" $ R.loginGoogle
        , dirs "api/account/me/basic" $ R.getMeBasic
        , dirs "api/issues/me/watch" $ path $ \issueId -> do method POST
                                                             R.watchIssue issueId
        , dirs "api/issues/me/watching" $ R.myIssueWatches
        , dirs "account/signout" $ R.signout
        , dirs "login/steam" $ R.loginSteam
        --, dirs "api/account/me" $ R.myDetails
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
        , dirs "api/programs" $ path $ \programId -> dir "issues" $ path $ \issueId -> dir "reports" $ path $ \reportId -> do method GET
                                                                                                                              R.getIssueReport programId issueId reportId
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
        , dirs "api/programs" $ path $ \programId -> dir "issues" $ path $ \issueId -> dir "me" $ R.getMyIssueStuffForProgram programId issueId
        , dirs "api/programs" $ path $ \programId -> dir "issues" $ path $ \issueId -> R.getIssueForProgram programId issueId
        , dirs "api/programs" $ path $ \programId -> dir "issues" $ R.getIssuesForProgram programId
        , dirs "api/programs" $ path $ \programId -> R.getProgramJSON programId
        , dirs "api/programs/popular" $ R.getPopularPrograms
        , dirs "api/issues/popular" $ R.getPopularIssues
        , dirs "api/programs" $ R.getAllPrograms
        , dirs "" $ indexPage
        ]
