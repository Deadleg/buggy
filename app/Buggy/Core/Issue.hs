{-# LANGUAGE OverloadedStrings #-}
module Buggy.Core.Issue (
    createIssue,
    getIssue,
    getIssueReport,
    getIssueReports,
    createIssueReport,
    getPrograms,
    getProgram,
    getIssues,
    updateIssue,
    updateIssueReport,
    issueReportFixed,
    issueFixed,
    createIssueComment,
    updateIssueComment,
    getIssueComment,
    getIssueComments,
    createIssueReportComment,
    updateIssueReportComment,
    getIssueReportComment,
    getIssueReportComments,
    reportIssueComment,
    reportIssueReportComment,
    getUserWatches,
    watchIssue,
    getMyIssueStuff,
    getTopPrograms,
    getPopularIssues
) where

import qualified Buggy.Core.Types as T
import qualified Buggy.Persistence.Postgre as P

getPopularIssues :: IO ([T.Issue])
getPopularIssues = P.getPopularIssues

getTopPrograms :: IO ([T.ProgramSummary])
getTopPrograms = P.getTopPrograms

getMyIssueStuff :: Integer -> Integer -> Integer -> IO (T.MyIssue)
getMyIssueStuff programId issueId userId = P.getMyIssue programId issueId userId

getUserWatches :: Integer -> IO ([T.Issue])
getUserWatches userId = P.getUserWatches userId

watchIssue :: Integer -> Integer -> IO ()
watchIssue userId issueId = P.watchIssue userId issueId

getPrograms :: IO ([T.Program])
getPrograms = P.selectPrograms

getIssues :: Integer -> IO ([T.Issue])
getIssues programId = P.selectIssues programId

createIssue :: T.Issue -> IO ()
createIssue issue = P.insertIssue issue

createIssueReport :: T.IssueReport -> IO ()
createIssueReport issue = P.insertIssueReport issue

getIssueReport :: Integer -> Integer -> Integer -> IO (T.IssueReport)
getIssueReport programId issueId reportId = P.selectIssueReport programId issueId reportId

getIssueReports :: Integer -> Integer -> IO ([T.IssueReport])
getIssueReports programId issueId = P.selectIssueReports programId issueId

getIssue :: Integer -> Integer -> IO (T.Issue)
getIssue programId issueId = P.selectIssue programId issueId

getProgram :: Integer -> IO (T.Program)
getProgram programId = P.selectProgram programId

updateIssue :: T.Issue -> IO ()
updateIssue issue = P.updateIssue issue

updateIssueReport :: T.IssueReport -> IO ()
updateIssueReport issueReport = P.updateIssueReport issueReport

issueReportFixed :: Integer -> Integer -> Integer -> IO ()
issueReportFixed programId issueId reportId = P.updateIssueReportAsFixed programId issueId reportId

issueFixed :: Integer -> Integer -> IO ()
issueFixed programId issueId = do
    P.updateIssueAsFixed programId issueId
    users <- P.selectIssueSubscriptors issueId
    issue <- P.selectIssue programId issueId
    T.sendMessage issue users

createIssueComment :: Integer -> T.IssueComment -> IO ()
createIssueComment issueId comment = P.insertIssueComment issueId comment

updateIssueComment :: Integer -> T.IssueComment -> IO ()
updateIssueComment commentId comment = P.updateIssueComment commentId comment

getIssueComment :: Integer -> IO (T.IssueComment)
getIssueComment commentId = do
    comment <- P.selectIssueComment commentId
    return $ head $ T.toForest [comment] T.convertToIssueCommentTree

getIssueComments :: Integer -> Integer -> IO ([T.IssueComment])
getIssueComments programId issueId = do
    comments <- P.selectIssueComments programId issueId
    return $ T.toForest comments T.convertToIssueCommentTree

createIssueReportComment :: Integer -> T.IssueReportComment -> IO ()
createIssueReportComment reportId comment = P.insertIssueReportComment reportId comment

updateIssueReportComment :: Integer -> T.IssueReportComment -> IO ()
updateIssueReportComment commentId comment = P.updateIssueReportComment commentId comment

getIssueReportComment :: Integer -> IO (T.IssueReportComment)
getIssueReportComment commentId = do
    comment <- P.selectIssueReportComment commentId
    return $ head $ T.toForest [comment] T.convertToReportCommentTree

getIssueReportComments :: Integer -> Integer -> Integer -> IO ([T.IssueReportComment])
getIssueReportComments programId issueId reportId = do
    comments <- P.selectIssueReportComments programId issueId reportId
    return $ T.toForest comments T.convertToReportCommentTree

reportIssueComment :: Integer -> Integer -> Integer -> T.IssueCommentReport -> IO ()
reportIssueComment programId issueId commentId report = do
    P.createIssueCommentReport programId issueId commentId report
    T.notifyReportee report

reportIssueReportComment :: Integer -> Integer -> Integer -> Integer -> T.IssueReportCommentReport -> IO ()
reportIssueReportComment programId issueId reportId commentId report = do
    P.createIssueReportCommentReport programId issueId commentId reportId report
    T.notifyReportee report
