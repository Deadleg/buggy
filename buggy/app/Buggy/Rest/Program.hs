{-# LANGUAGE OverloadedStrings #-}

module Buggy.Rest.Program (
    getAllPrograms,
    getIssuesForProgram,
    getIssueForProgram,
    getProgramJSON,
    getIssueReports,
    getIssueReport,
    createIssue,
    createIssueReport,
    updateIssue,
    issueReportFixed,
    issueFixed,
    updateIssueReport,
    createIssueComment,
    updateIssueComment, getIssueComment, getIssueComments, createIssueReportComment, updateIssueReportComment,
    getIssueReportComment,
    getIssueReportComments,
    reportIssueReportComment,
    reportIssueComment,
    loginGoogle,
    loginSteam,
    getMeBasic,
    signout
) where

import qualified Buggy.Logic.Issue as L
import qualified Data.ByteString.Lazy.Char8 as B
import Buggy.Types.Types
import Buggy.Views.Types
import qualified Buggy.Accounts as A
import Happstack.Server
import Happstack.Server.ClientSession
import Happstack.Server.Types
import qualified Web.JWT as JWT
import Control.Monad.IO.Class
import Buggy.Views.Types
import Data.Aeson
import Control.Monad (when)
import Data.Maybe (fromJust, isNothing)
import qualified Data.Text as T

signout :: ServerPart Response
signout = do
    expireCookie "buggy-user"
    seeOther ("/" :: T.Text) (toResponse ("Signing you out..." :: T.Text))

getMeBasic :: ServerPart Response
getMeBasic = do
    cookie <- lookCookieValue "buggy-user"
    liftIO $ putStrLn $ "ME"
    user <- liftIO $ A.getBuggyUser (T.pack cookie)
    liftIO $ putStrLn $ show user
    ok $ toResponse user

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

getIssueReport :: Integer -> Integer -> Integer -> ServerPart Response
getIssueReport programId issueId reportId = do
    report <- liftIO $ L.getIssueReport programId issueId reportId
    ok $ toResponse report

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

issueFixed :: Integer -> Integer -> ServerPart Response
issueFixed programId issueId = do
    liftIO $ L.issueFixed programId issueId
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

reportIssueReportComment :: Integer -> Integer -> Integer -> Integer -> ServerPart Response
reportIssueReportComment programId issueId reportId commentId = do
    body <- getBody
    let issue = eitherDecode body :: Either String IssueReportCommentReport
    case issue of
        Left s -> liftIO $ putStrLn s
        Right issue -> liftIO $ L.reportIssueReportComment programId issueId reportId commentId issue
    ok $ toResponse ("" :: T.Text)

reportIssueComment :: Integer -> Integer -> Integer -> ServerPart Response
reportIssueComment programId issueId commentId = do
    body <- getBody
    let issue = eitherDecode body :: Either String IssueCommentReport
    case issue of
        Left s -> liftIO $ putStrLn s
        Right issue -> liftIO $ L.reportIssueComment programId issueId commentId issue
    ok $ toResponse ("" :: T.Text)

workingHeader = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9" :: T.Text

-- Needed since the JWT doesn't support this type of header
constructJwt jwt = let [a,b,c] = T.splitOn "." jwt in
    workingHeader `T.append` "." `T.append` b `T.append` "." `T.append` c

loginGoogle :: ServerPart Response
loginGoogle = do
    body <- getBody
    let jwt = eitherDecode body :: Either String GoogleToken
    case jwt of
        Left s -> liftIO $ putStrLn s
        Right jwtToken -> do
            let fixedJwt = constructJwt (token jwtToken)
            let newUser = A.makeGoogleUser fixedJwt
            maybeUser <- liftIO $ A.getUser (username newUser)
            when (isNothing maybeUser) (liftIO $ A.newLogin newUser >> return ())
            let cookie = A.googleLogin newUser
            addCookie (MaxAge 60) (Cookie "1" "/" "localhost" "buggy-user" (T.unpack cookie) False True)
    ok $ toResponse ("" :: T.Text)

loginSteam :: ServerPart Response
loginSteam = do
    claimedId <- look "openid.claimed_id"
    let steamId = last (T.splitOn "/" (T.pack claimedId))
    user <- liftIO $ A.getSteamInfo steamId
    let newUser = A.makeSteamUser user
    maybeUser <- liftIO $ A.getUser (username newUser)
    when (isNothing maybeUser) (liftIO $ A.newLogin newUser >> return ())
    let cookie = A.steamLogin newUser
    addCookie (MaxAge 60) (Cookie "1" "/" "localhost" "buggy-user" (T.unpack cookie) False True)
    seeOther ("/" :: T.Text) (toResponse ("Logging you in..." :: T.Text))
