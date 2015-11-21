{-# LANGUAGE OverloadedStrings #-}

module Buggy.Persistence.Postgre (
    insertIssue,
    selectIssue,
    insertIssueReport,
    selectIssueReport,
    selectIssueReports,
    selectIssueReportLabels
) where

import Database.PostgreSQL.Simple
import Buggy.Types.Types
import Data.Time
import Control.Monad

connectionString = "host='localhost' port=5433 user='buggy' password='buggy' dbname='buggy'"

insertIssue :: Issue -> IO ()
insertIssue (New (ExistingProgram programId name) title description issueType reproductionSteps status reporter) = do
    conn <- connectPostgreSQL connectionString
    [Only issueId] <- query conn "INSERT INTO issues (program, type, reporter, status, title, description, time_reported) VALUES (? , ?, ?, ?, ?, ?, NOW()) RETURNING id;" (programId :: Integer, (show issueType :: String), (getUserId reporter :: Integer) :: Integer, (show status :: String), title :: String, description :: String)
    x <- executeMany conn "INSERT INTO reproduction_steps (issue, step_number, instruction) VALUES (?, ?, ?);" $ map (\(stepNumber, step) ->  (issueId :: Int, stepNumber, getStepDescription step)) (zip [1..length reproductionSteps] reproductionSteps)
    return ()

selectIssue :: Integer -> Integer -> IO (Issue)
selectIssue programId issueId = do
    conn <- connectPostgreSQL connectionString
    [(program, issueType, title, description, timeReported, status, userId, username)] <- query conn "SELECT p.name, i.type, i.title, i.description, i.time_reported, i.status, u.id, u.username FROM issues i INNER JOIN users u  ON i.reporter=u.id INNER JOIN programs p ON p.id=i.program  WHERE i.id=? and i.program=?" (issueId, programId)
    reproSteps <- query conn "SELECT instruction FROM reproduction_steps WHERE issue=? ORDER BY step_number ASC;" [issueId]
    return (Existing (ExistingProgram programId program) issueId (title :: String) (description :: String) (read issueType) (map (\(Only i) -> Step i) reproSteps) (timeReported :: LocalTime) (read status) (ExistingUser userId username))

insertIssueReport :: IssueReport -> IO ()
insertIssueReport (NewIssueReport desc specs issueId programId reporter labels) = do
    conn <- connectPostgreSQL connectionString
    [Only reportId] <- query conn "INSERT INTO issue_reports (issue, description, reporter, computer_info, time_reported) VALUES (?, ?, ?, ?, NOW()) RETURNING id;" (issueId, desc, (getUserId reporter), specs)
    let reportLabels = map (\x -> (reportId :: Integer, show x)) labels
    executeMany conn "INSERT INTO issue_report_labels (issue_report, label) VALUES (?, ?);" reportLabels
    return ()

selectIssueReport :: Integer -> Integer -> Integer -> IO (IssueReport)
selectIssueReport programId issueId reportId = do
    conn <- connectPostgreSQL connectionString
    [(desc, specs, time, userId, username)] <- query conn "SELECT i.description, i.computer_info, i.time_reported, u.id, u.username FROM issue_reports i INNER JOIN users u  ON i.reporter=u.id WHERE i.id=?" [reportId]
    labels <- selectIssueReportLabels reportId
    return (ExistingIssueReport desc specs issueId programId (ExistingUser userId username) labels time)

selectIssueReports :: Integer -> Integer -> IO ([IssueReport])
selectIssueReports programId issueId = do
    conn <- connectPostgreSQL connectionString
    xs <- query conn "SELECT i.description, i.computer_info, i.time_reported, u.id, u.username, i.id FROM issue_reports i INNER JOIN users u ON i.reporter=u.id INNER JOIN issues q ON q.id=i.issue WHERE q.id=?" [issueId]
    let reports = map (\(desc, specs, time, userId, username, id) -> (desc :: String, specs :: String, time :: LocalTime, userId :: Integer, username :: String, selectIssueReportLabels id, issueId, programId)) xs
    let x = map (mapLabels) reports
    sequence x

mapLabels :: (String, String, LocalTime, Integer, String, IO ([IssueReportLabel]), Integer, Integer) ->  IO (IssueReport)
mapLabels (desc, specs, time, userId, username, labels, issueId, programId) = do
    r <- labels
    return (ExistingIssueReport desc specs issueId programId (ExistingUser userId username) r time)

selectIssueReportLabels :: Integer -> IO [IssueReportLabel]
selectIssueReportLabels reportId = do
    conn <- connectPostgreSQL connectionString
    labels <- query conn "SELECT label FROM issue_report_labels where issue_report=?" [reportId]
    return $ map (\(Only x) -> read x) labels

