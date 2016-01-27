{-# LANGUAGE OverloadedStrings #-}

module Buggy.Rest.Program (
    getAllPrograms,
    getIssuesForProgram,
    getIssueForProgram,
    getProgramJSON,
    getIssueReports,
    createIssue,
    createIssueReport,
    updateIssue,
    issueReportFixed,
    updateIssueReport,
    createIssueComment,
    updateIssueComment,
    getIssueComment,
    getIssueComments,
    createIssueReportComment,
    updateIssueReportComment,
    getIssueReportComment,
    getIssueReportComments
) where

import qualified Buggy.Logic.Issue as L
import qualified Data.ByteString.Lazy.Char8 as B
import Buggy.Types.Types
import Happstack.Server
import Happstack.Server.Types
import Control.Monad.IO.Class
import Data.Aeson
import Data.Maybe (fromJust)

getAllPrograms :: ServerPart Response
getAllPrograms = do
    programs <- liftIO L.getPrograms
    ok $ toResponse programs

getIssuesForProgram :: Integer -> ServerPart Response
getIssuesForProgram programId = do
    issues <- liftIO $ L.getIssues programId
    ok $ toResponse issues

getBody :: ServerPart B.ByteString
getBody = do
    req <- askRq
    body <- liftIO $ takeRequestBody req
    case body of
        Just b -> return . unBody $ b
        Nothing -> return ""

getIssueForProgram :: Integer -> Integer -> ServerPart Response
getIssueForProgram programId issueId = do
    issue <- liftIO $ L.getIssue programId issueId
    ok $ toResponse issue

createIssue :: Integer -> ServerPart Response
createIssue programId = do
    body <- getBody
    let issue = eitherDecode body :: Either String Issue
    case issue of
        Left s -> liftIO $ putStrLn s
        Right issue -> liftIO $ L.createIssue issue
    ok $ toResponse ("" :: String)

createIssueReport :: Integer -> Integer -> ServerPart Response
createIssueReport programId issueId = do
    body <- getBody
    let issue = eitherDecode body :: Either String IssueReport
    case issue of
        Left s -> liftIO $ putStrLn s
        Right issue -> liftIO $ L.createIssueReport issue
    ok $ toResponse ("" :: String)

getIssueReports :: Integer -> Integer -> ServerPart Response
getIssueReports programId issueId = do
    reports <- liftIO $ L.getIssueReports programId issueId
    ok $ toResponse reports

getProgramJSON :: Integer -> ServerPart Response
getProgramJSON programId = do
    program <- liftIO $ L.getProgram programId
    ok $ toResponse program

updateIssue :: Integer -> Integer -> ServerPart Response
updateIssue programId issueId = do
    body <- getBody
    let issue = eitherDecode body :: Either String Issue
    case issue of
        Left s -> liftIO $ putStrLn s
        Right issue -> liftIO $ L.updateIssue issue
    ok $ toResponse ("" :: String)

updateIssueReport :: Integer -> Integer -> Integer -> ServerPart Response
updateIssueReport programId issueId reportId = do
    body <- getBody
    let issue = eitherDecode body :: Either String IssueReport
    case issue of
        Left s -> liftIO $ putStrLn s
        Right issue -> liftIO $ L.updateIssueReport issue
    ok $ toResponse ("" :: String)

issueReportFixed :: Integer -> Integer -> Integer -> ServerPart Response
issueReportFixed programId issueId reportId = do
    liftIO $ L.issueReportFixed programId issueId reportId
    ok $ toResponse ("" :: String)

createIssueComment :: Integer -> Integer -> ServerPart Response
createIssueComment programId issueId = do
    body <- getBody
    let issue = eitherDecode body :: Either String IssueComment
    case issue of
        Left s -> liftIO $ putStrLn s
        Right issue -> liftIO $ L.createIssueComment issueId issue
    ok $ toResponse ("" :: String)

updateIssueComment :: Integer -> ServerPart Response
updateIssueComment commentId = do
    body <- getBody
    let issue = eitherDecode body :: Either String IssueComment
    case issue of
        Left s -> liftIO $ putStrLn s
        Right issue -> liftIO $ L.updateIssueComment commentId issue
    ok $ toResponse ("" :: String)

getIssueComment :: Integer -> ServerPart Response
getIssueComment commentId = do
    comment <- liftIO $ L.getIssueComment commentId
    ok $ toResponse comment

getIssueComments :: Integer -> Integer -> ServerPart Response
getIssueComments programId issueId = do
    comment <- liftIO $ L.getIssueComments programId issueId
    ok $ toResponse comment

createIssueReportComment :: Integer -> Integer -> Integer -> ServerPart Response
createIssueReportComment programId issueId reportId = do
    body <- getBody
    let issue = eitherDecode body :: Either String IssueReportComment
    case issue of
        Left s -> liftIO $ putStrLn s
        Right issue -> liftIO $ L.createIssueReportComment reportId issue
    ok $ toResponse ("" :: String)

updateIssueReportComment :: Integer -> ServerPart Response
updateIssueReportComment commentId = do
    body <- getBody
    let issue = eitherDecode body :: Either String IssueReportComment
    case issue of
        Left s -> liftIO $ putStrLn s
        Right issue -> liftIO $ L.updateIssueReportComment commentId issue
    ok $ toResponse ("" :: String)

getIssueReportComment :: Integer -> ServerPart Response
getIssueReportComment commentId = do
    comment <- liftIO $ L.getIssueReportComment commentId
    ok $ toResponse comment

getIssueReportComments :: Integer -> Integer -> Integer -> ServerPart Response
getIssueReportComments programId issueId reportId = do
    comment <- liftIO $ L.getIssueReportComments programId issueId reportId
    ok $ toResponse comment
