{-# LANGUAGE OverloadedStrings #-}

module Buggy.Views.Issue (
    issuePage,
    createIssuePage
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

createIssueView :: View H.Html -> Integer -> H.Html
createIssueView view programId = D.form view ("/app/" `T.append` (T.pack $ show programId) `T.append` "/create") $ do
    H.div $ do
        D.label "title" view "Title:"
        D.inputText "title" view
    H.div $ do
        D.label "description" view "Description:"
        D.inputTextArea Nothing Nothing "description" view
    H.div $ do
        D.label "type" view "Type:"
        D.inputSelect "type" view
    H.div $ do
        D.label "status" view "Status:"
        D.inputSelect "status" view
    mapM_ reproductionStepsView $ zip [1..fromIntegral $ length reproductionStepsViews] reproductionStepsViews
    existingUserView view
    existingProgramView view
    D.inputSubmit $ "Create"
    where reproductionStepsViews = listSubViews "reproductionstep" view 

reproductionStepsView :: (Integer, View H.Html) -> H.Html
reproductionStepsView (stepNumber, view) = do 
    H.div $ do
        D.label "stepdescription" view (H.toHtml ("Step " ++ (show stepNumber) ++ "."))
        D.inputText "stepdescription" view

existingUserView :: View H.Html -> H.Html
existingUserView view = do
    H.div $ do
        D.inputHidden "reporter.id" view
        D.inputHidden "reporter.username" view

existingProgramView :: View H.Html -> H.Html
existingProgramView view = do
    H.div $ do
        D.inputHidden "program.id" view
        D.inputHidden "program.name" view

createIssuePage :: Integer -> ServerPart Response
createIssuePage programId = do
    decodeBody $ defaultBodyPolicy "/tmp/" 32000 1000 1000
    r <- runForm "createissue" newIssueForm
    case r of
        (view, Nothing) -> do
            let view' = fmap H.toHtml view
            ok $ mainTemplate "issue" $ do
                H.h1 "Program here"
                createIssueView view' programId 
        (_, Just issue) -> do
            liftIO $ createIssue issue
            seeOther ("/app/" `T.append` (T.pack $ show programId) `T.append` "/issue/1") (toResponse ())

issuePage :: Integer -> Integer -> ServerPart Response
issuePage programId issueId = do
    issue        <- liftIO (getIssue programId issueId)
    issueReports <- liftIO (getIssueReports programId issueId)
    issueHtml issue issueReports

issueHtml :: Issue -> [IssueReport] -> ServerPart Response
issueHtml (Existing (ExistingProgram programId name) id title description issueType reproductionSteps timeReported status (ExistingUser userId username)) issueReports = ok $ mainTemplate "issue" $ do
    H.div $ do
        H.h2 $ toHtml title
        H.h3 $ toHtml ("Reported by " ++ username)
        H.h3 $ toHtml ("Type: " ++ show issueType)
        H.h3 $ toHtml ("Status: " ++ show status)
        H.h3 $ toHtml ("Reported at: " ++ show timeReported)
        H.p $ toHtml description
        H.ol $ do
            mapM_ (\step -> H.li $ H.p (toHtml $ getStepDescription step)) reproductionSteps
    H.h2 "Reports"
    mapM_ (\issueReport -> H.div $ do
        H.h4 $ toHtml $ getUsername (getIssueReportReporter issueReport)
        mapM_ (\label -> H.span $ (toHtml $ show label)) (getIssueReportLabels issueReport)
        H.p $ toHtml $ getIssueReportDescription issueReport
        H.p $ toHtml $ getIssueReportSpecs issueReport) issueReports
    H.a ! A.href (H.textValue (T.pack ("/app/" ++ (show programId) ++ "/issue/" ++ (show id) ++ "/report/create"))) $ "Create report"
