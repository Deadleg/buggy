{-# LANGUAGE OverloadedStrings #-}

module Buggy.Views.IssueReport (
    createIssueReportPage
) where

import Happstack.Server
import Happstack.Server.Monads
import Buggy.Views.Templates
import Buggy.Views.Form
import Buggy.Types.Types
import Buggy.Logic.Issue
import qualified Data.Text as T
import Text.Blaze.Html5 ((!), toHtml)
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A
import qualified Text.Digestive.Blaze.Html5 as D
import Text.Digestive.Happstack
import Text.Digestive.View
import Control.Monad.IO.Class

createIssueReportView :: View H.Html -> Integer -> Integer -> H.Html
createIssueReportView view programId issueId = D.form view ("/app/" `T.append` (T.pack $ show programId) `T.append` "/issue/" `T.append` (T.pack $ show issueId) `T.append` "/report/create") $ do
    H.div $ do
        D.label "description" view "Description:"
        D.inputTextArea Nothing Nothing "description" view
    H.div $ do
        D.label "specs" view "Computer specs:"
        D.inputTextArea Nothing Nothing "specs" view
    existingUserView view
    D.inputHidden "issueid" view
    D.inputHidden "programid" view
    D.inputSubmit $ "Create"

existingUserView :: View H.Html -> H.Html
existingUserView view = do
    H.div $ do
        D.inputHidden "reporter.id" view
        D.inputHidden "reporter.username" view

createIssueReportPage :: Integer -> Integer -> ServerPart Response
createIssueReportPage programId issueId = do
    decodeBody $ defaultBodyPolicy "/tmp/" 32000 1000 1000
    r <- runForm "createissuereport" newIssueReportForm
    case r of
        (view, Nothing) -> do
            let view' = fmap H.toHtml view
            ok $ mainTemplate "issue" $ do
                H.h1 "Program here"
                createIssueReportView view' programId issueId
        (_, Just issue) -> do
            liftIO $ createIssueReport issue
            seeOther ("/app/" `T.append` (T.pack $ show programId) `T.append` "/issue/1") (toResponse ())
