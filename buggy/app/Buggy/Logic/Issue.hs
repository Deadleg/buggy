module Buggy.Logic.Issue (
    createIssue,
    getIssue,
    getIssueReport,
    getIssueReports,
    createIssueReport
) where

import Buggy.Types.Types
import Buggy.Persistence.Postgre

createIssue :: Issue -> IO ()
createIssue issue = insertIssue issue

createIssueReport :: IssueReport -> IO ()
createIssueReport issue = insertIssueReport issue

getIssueReport :: Integer -> Integer -> Integer -> IO (IssueReport)
getIssueReport programId issueId reportId = selectIssueReport programId issueId reportId

getIssueReports :: Integer -> Integer -> IO ([IssueReport])
getIssueReports programId issueId = selectIssueReports programId issueId

getIssue :: Integer -> Integer -> IO (Issue)
getIssue programId issueId = selectIssue programId issueId
