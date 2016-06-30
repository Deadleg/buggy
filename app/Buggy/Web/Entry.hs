{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleInstances #-}

module Buggy.Web.Entry (
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
    updateIssueComment,
    getIssueComment,
    getIssueComments,
    createIssueReportComment,
    updateIssueReportComment,
    getIssueReportComment,
    getIssueReportComments,
    reportIssueReportComment,
    reportIssueComment,
    loginGoogle,
    loginSteam,
    getMeBasic,
    signout,
    myIssueWatches,
    watchIssue,
    getMyIssueStuffForProgram,
    getPopularPrograms,
    getPopularIssues,
    getIssueStats
) where

import Buggy.Core.Types hiding (id)
import Buggy.Web.Types
import Buggy.Web.Util (getBuggyCookie)
import Happstack.Server
import Happstack.Server.Types
import Control.Monad (when, mzero, liftM)
import Control.Monad.IO.Class
import Control.Monad.Trans.Class
import Control.Exception
import Data.Aeson
import Data.Maybe (fromJust, isNothing)
import Database.PostgreSQL.Simple (SqlError, sqlState)
import qualified Buggy.Core.Issue as L
import qualified Data.ByteString.Lazy.Char8 as B
import qualified Web.JWT as JWT
import qualified Buggy.Web.Signin as A
import qualified Data.Text as T

mapUserOperation :: (ToMessage a) => UserOperations a -> ServerPart Response
mapUserOperation (Authorized a) = ok $ toResponse a
mapUserOperation NotAuthenticated = unauthorized $ toResponse ("Not logged in!" :: T.Text)
mapUserOperation NotAuthorized = unauthorized $ toResponse ("Not authorized!" :: T.Text)

class AuthenticationRequired a where
    doAuthenticated :: Maybe Cookie -> (User -> a) -> ServerPart Response

instance (ToJSON a) => AuthenticationRequired (UserOperationsIO a) where
    doAuthenticated Nothing f = unauthorized $ toResponse ("Not logged in!" :: T.Text)
    doAuthenticated (Just cookie) f = do
        maybeUser <- liftIO $ A.getBuggyUser (T.pack $ cookieValue cookie)
        case maybeUser of
            Nothing -> unauthorized $ toResponse ("Not logged in!" :: T.Text)
            Just user -> (lift $ runUserOperations (f user)) >>= mapUserOperation

getPopularPrograms :: ServerPart Response
getPopularPrograms = (liftIO L.getTopPrograms) >>= (ok . toResponse)

getPopularIssues :: ServerPart Response
getPopularIssues = (liftIO L.getPopularIssues) >>= (ok . toResponse)

getMyIssueStuffForProgram :: Integer -> Integer -> ServerPart Response
getMyIssueStuffForProgram programId issueId = do
    req <- askRq
    let maybeCookie = getBuggyCookie (rqCookies req)
    doAuthenticated maybeCookie (\user ->
        lift $ L.getMyIssueStuff programId issueId (getUserId user) :: UserOperationsIO MyIssue)

myIssueWatches :: ServerPart Response
myIssueWatches = do
    req <- askRq
    let maybeCookie = getBuggyCookie (rqCookies req)
    doAuthenticated maybeCookie (\user ->
        lift $ L.getUserWatches (getUserId user) :: UserOperationsIO [Issue])

watchIssue :: Integer -> ServerPart Response
watchIssue issueId = do
    req <- askRq
    let maybeCookie = getBuggyCookie (rqCookies req)
    doAuthenticated maybeCookie (\user -> do
        success <- liftIO $ try $ L.watchIssue (getUserId user) issueId
        case success of
            Left ex -> do
                if sqlState (ex :: SqlError) == "23505" then
                    (return $ "Already watching") :: UserOperationsIO T.Text
                else
                    UserOperationsT $ return (BadRequest 400 (T.pack $ show ex))
            Right _ -> (return "") :: UserOperationsIO T.Text)

signout :: ServerPart Response
signout = do
    expireCookie "buggy-user"
    seeOther ("/" :: T.Text) (toResponse ("Signing you out..." :: T.Text))

getMeBasic :: ServerPart Response
getMeBasic = do
    req <- askRq
    let maybeCookie = getBuggyCookie (rqCookies req)
    doAuthenticated maybeCookie (\user -> return user :: UserOperationsIO User)

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
    req <- askRq
    body <- getBody
    let maybeCookie = getBuggyCookie (rqCookies req)
    doAuthenticated maybeCookie (\user -> do
        let issue = eitherDecode body :: Either String Issue
        case issue of
            Left s -> badOperation 400 (T.pack s)
            Right issue -> do
                response <- liftIO $ L.createIssue issue (getUserId user)
                return response :: UserOperationsIO NewIssueResponse)

createIssueReport :: Integer -> Integer -> ServerPart Response
createIssueReport programId issueId = do
    req <- askRq
    body <- getBody
    let maybeCookie = getBuggyCookie (rqCookies req)
    doAuthenticated maybeCookie (\user -> do
        let issue = eitherDecode body :: Either String IssueReport
        case issue of
            Left s -> badOperation 400 (T.pack s)
            Right issue -> do
                liftIO $ L.createIssueReport issue (getUserId user)
                return ("" :: T.Text) :: UserOperationsIO T.Text)

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
    req <- askRq
    body <- getBody
    let maybeCookie = getBuggyCookie (rqCookies req)
    doAuthenticated maybeCookie (\user -> do
        let issue = eitherDecode body :: Either String Issue
        case issue of
            Left s -> badOperation 400 (T.pack s)
            Right issue -> do
                liftIO $ L.updateIssue issue
                return ("" :: T.Text) :: UserOperationsIO T.Text)

updateIssueReport :: Integer -> Integer -> Integer -> ServerPart Response
updateIssueReport programId issueId reportId = do
    req <- askRq
    body <- getBody
    let maybeCookie = getBuggyCookie (rqCookies req)
    doAuthenticated maybeCookie (\user -> do
        let issue = eitherDecode body :: Either String IssueReport
        case issue of
            Left s -> badOperation 400 (T.pack s)
            Right issue -> do
                liftIO $ L.updateIssueReport issue
                return ("" :: T.Text) :: UserOperationsIO T.Text)

issueReportFixed :: Integer -> Integer -> Integer -> ServerPart Response
issueReportFixed programId issueId reportId = do
    req <- askRq
    let maybeCookie = getBuggyCookie (rqCookies req)
    doAuthenticated maybeCookie (\user -> do
        liftIO $ L.issueReportFixed programId issueId reportId
        return ("" :: T.Text) :: UserOperationsIO T.Text)

issueFixed :: Integer -> Integer -> ServerPart Response
issueFixed programId issueId = do
    req <- askRq
    body <- getBody
    let maybeCookie = getBuggyCookie (rqCookies req)
    doAuthenticated maybeCookie (\user -> do
        liftIO $ L.issueFixed programId issueId
        return ("" :: T.Text) :: UserOperationsIO T.Text)

createIssueComment :: Integer -> Integer -> ServerPart Response
createIssueComment programId issueId = do
    req <- askRq
    body <- getBody
    let maybeCookie = getBuggyCookie (rqCookies req)
    doAuthenticated maybeCookie (\user -> do
        let issue = eitherDecode body :: Either String IssueComment
        case issue of
            Left s -> badOperation 400 (T.pack s)
            Right issue -> do
                liftIO $ L.createIssueComment issueId issue
                return ("" :: T.Text) :: UserOperationsIO T.Text)

updateIssueComment :: Integer -> ServerPart Response
updateIssueComment commentId = do
    req <- askRq
    body <- getBody
    let maybeCookie = getBuggyCookie (rqCookies req)
    doAuthenticated maybeCookie (\user -> do
        let issue = eitherDecode body :: Either String IssueComment
        case issue of
            Left s -> badOperation 400 (T.pack s)
            Right issue -> do
                liftIO $ L.updateIssueComment commentId issue
                return ("" :: T.Text) :: UserOperationsIO T.Text)

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
    req <- askRq
    body <- getBody
    let maybeCookie = getBuggyCookie (rqCookies req)
    doAuthenticated maybeCookie (\user -> do
        let issue = eitherDecode body :: Either String IssueReportComment
        case issue of
            Left s -> badOperation 400 (T.pack s)
            Right issue -> do
                liftIO $ L.createIssueReportComment reportId issue
                return ("" :: T.Text) :: UserOperationsIO T.Text)

updateIssueReportComment :: Integer -> ServerPart Response
updateIssueReportComment commentId = do
    req <- askRq
    body <- getBody
    let maybeCookie = getBuggyCookie (rqCookies req)
    doAuthenticated maybeCookie (\user -> do
        let issue = eitherDecode body :: Either String IssueReportComment
        case issue of
            Left s -> badOperation 400 (T.pack s)
            Right issue -> do
                liftIO $ L.updateIssueReportComment commentId issue
                return ("" :: T.Text) :: UserOperationsIO T.Text)

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
    req <- askRq
    body <- getBody
    let maybeCookie = getBuggyCookie (rqCookies req)
    doAuthenticated maybeCookie (\user -> do
        let issue = eitherDecode body :: Either String IssueReportCommentReport
        case issue of
            Left s -> badOperation 400 (T.pack s)
            Right issue -> do
                liftIO $ L.reportIssueReportComment programId issueId reportId commentId issue
                return ("" :: T.Text) :: UserOperationsIO T.Text)

reportIssueComment :: Integer -> Integer -> Integer -> ServerPart Response
reportIssueComment programId issueId commentId = do
    req <- askRq
    body <- getBody
    let maybeCookie = getBuggyCookie (rqCookies req)
    doAuthenticated maybeCookie (\user -> do
        let issue = eitherDecode body :: Either String IssueCommentReport
        case issue of
            Left s -> badOperation 400 (T.pack s)
            Right issue -> do
                liftIO $ L.reportIssueComment programId issueId commentId issue
                return ("" :: T.Text) :: UserOperationsIO T.Text)

getIssueStats :: Integer -> ServerPart Response
getIssueStats programId = (liftIO $ L.getIssueStats programId) >>= (ok . toResponse)

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
            addCookie (MaxAge 3600) (Cookie "1" "/" "localhost" "buggy-user" (T.unpack cookie) False True)
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
    addCookie (MaxAge 3600) (Cookie "1" "/" "localhost" "buggy-user" (T.unpack cookie) False True)
    seeOther ("/" :: T.Text) (toResponse ("Logging you in..." :: T.Text))
