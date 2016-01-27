{-# LANGUAGE OverloadedStrings #-}

module Buggy.Persistence.Postgre (
    insertIssue,
    selectIssue,
    insertIssueReport,
    selectIssueReport,
    selectIssueReports,
    selectPrograms,
    selectIssues,
    selectProgram,
    updateIssue,
    updateIssueReport,
    updateIssueReportAsFixed,
    insertIssueComment,
    selectIssueComment,
    selectIssueComments,
    updateIssueComment,
    insertIssueReportComment,
    selectIssueReportComment,
    selectIssueReportComments,
    updateIssueReportComment
) where

import Database.PostgreSQL.Simple
import Buggy.Types.Types
import Data.Time
import Control.Monad
import qualified Data.Map as M

connectionString = "host='localhost' port=5433 user='buggy' password='buggy' dbname='buggy'"

selectProgram :: Integer -> IO (Program)
selectProgram programId = do
    conn <- connectPostgreSQL connectionString
    [(id, name, issueCount)] <- query conn "SELECT DISTINCT p.id, p.name, count(i.id) OVER () FROM programs p LEFT JOIN issues i ON p.id=i.program WHERE i.status!='Closed' and p.id=?;" [programId]
    return $ ExistingProgram id name issueCount

selectPrograms :: IO ([Program])
selectPrograms = do
    conn <- connectPostgreSQL connectionString
    xs <- query_ conn "SELECT DISTINCT p.id, p.name, count(i.id) OVER () FROM programs p LEFT JOIN issues i ON p.id=i.program WHERE i.status!='Closed';"
    return $ map (\(id, name, issueCount) -> ExistingProgram id name issueCount) xs

getReproStep :: Maybe String -> [String]
getReproStep Nothing = []
getReproStep (Just x) = [x]

selectIssues :: Integer -> IO ([Issue])
selectIssues programId = do
    conn <- connectPostgreSQL connectionString
    xs <- query conn "SELECT i.id, i.type, i.title, i.description, i.time_reported, i.status, u.id, u.username, r.instruction, i.edit_time \
                     \FROM issues i \
                     \INNER JOIN users u ON i.reporter=u.id \
                     \LEFT JOIN reproduction_steps r ON i.id=r.issue \
                     \WHERE i.program=? \
                     \ORDER BY r.step_number ASC;" [programId]
    let issues = M.toList $ M.fromListWith (++)
                [((issueId :: Integer, issueType :: String, title :: String, description :: String, timeReported :: LocalTime, status :: String, userId :: Integer, username :: String, editTime :: Maybe LocalTime), getReproStep (reproSteps :: Maybe String)) | (issueId, issueType, title, description, timeReported, status, userId, username, reproSteps, editTime) <- xs]
    return $ map (\((issueId, issueType, title, description, timeReported, status, userId, username, editTime), reproSteps) ->
            (Existing programId issueId (title :: String) (description :: String) (read issueType) (map (\step -> Step step) reproSteps) (timeReported :: LocalTime) (read status) (ExistingUser userId username) editTime)) issues

insertIssue :: Issue -> IO ()
insertIssue (New programId title description issueType reproductionSteps status reporter) = do
    conn <- connectPostgreSQL connectionString
    [Only issueId] <- query conn "INSERT INTO issues (program, type, reporter, status, title, description, time_reported) VALUES (? , ?, ?, ?, ?, ?, NOW()) RETURNING id;" (programId :: Integer, (show issueType :: String), reporter :: Integer, (show status :: String), title :: String, description :: String)
    x <- executeMany conn "INSERT INTO reproduction_steps (issue, step_number, instruction) VALUES (?, ?, ?);" $ map (\(stepNumber, step) ->  (issueId :: Int, stepNumber, getStepDescription step)) (zip [1..length reproductionSteps] reproductionSteps)
    return ()

selectIssue :: Integer -> Integer -> IO (Issue)
selectIssue programId issueId = do
    conn <- connectPostgreSQL connectionString
    [(issueType, title, description, timeReported, status, userId, username, editTime)] <- query conn "SELECT i.type, i.title, i.description, i.time_reported, i.status, u.id, u.username, i.edit_time FROM issues i INNER JOIN users u  ON i.reporter=u.id WHERE i.id=? and i.program=?" (issueId, programId)
    reproSteps <- query conn "SELECT instruction FROM reproduction_steps WHERE issue=? ORDER BY step_number ASC;" [issueId]
    return (Existing programId issueId (title :: String) (description :: String) (read issueType) (map (\(Only i) -> Step i) reproSteps) (timeReported :: LocalTime) (read status) (ExistingUser userId username) editTime)

insertIssueReport :: IssueReport -> IO ()
insertIssueReport (NewIssueReport desc specs issueId programId reporter status _type) = do
    conn <- connectPostgreSQL connectionString
    execute conn "INSERT INTO issue_reports (issue, description, reporter, computer_info, status, type, time_reported) VALUES (?, ?, ?, ?, ?, ?, NOW());" (issueId, desc, reporter, specs, status, _type)
    return ()

selectIssueReport :: Integer -> Integer -> Integer -> IO (IssueReport)
selectIssueReport programId issueId reportId = do
    conn <- connectPostgreSQL connectionString
    [(desc, specs, time, status, _type, confirmed, userId, username, id)] <- query conn "SELECT i.description, i.computer_info, i.time_reported, i.status, i.type, i.confirmed, u.id, u.username FROM issue_reports i INNER JOIN users u  ON i.reporter=u.id WHERE i.id=?" [reportId]
    return (ExistingIssueReport desc specs issueId programId id (ExistingUser userId username) (read status) (read _type) confirmed time)

selectIssueReports :: Integer -> Integer -> IO ([IssueReport])
selectIssueReports programId issueId = do
    conn <- connectPostgreSQL connectionString
    xs <- query conn "SELECT i.description, i.computer_info, i.time_reported, i.status, i.type, i.confirmed, u.id, u.username, i.id FROM issue_reports i INNER JOIN users u ON i.reporter=u.id INNER JOIN issues q ON q.id=i.issue WHERE q.id=?" [issueId]
    return $ map (\(desc, specs, time, status, _type, confirmed, userId, username, id) -> (ExistingIssueReport desc specs issueId programId id (ExistingUser userId username) (read status) (read _type) confirmed time)) xs

updateIssue :: Issue -> IO ()
updateIssue (Edit programId issueId title description issueType reproductionSteps status) = do
    conn <- connectPostgreSQL connectionString
    execute conn "UPDATE issues SET type=?, status=?, title=?, edit_time=NOW(), description=? WHERE id=? AND program=?;" (show issueType, show status, title, description, issueId, programId)
    execute conn "DELETE FROM reproduction_steps WHERE issue=?;" [issueId]
    executeMany conn "INSERT INTO reproduction_steps (issue, step_number, instruction) VALUES (?, ?, ?);" $ map (\(stepNumber, step) ->  (issueId, stepNumber, getStepDescription step)) (zip [1..length reproductionSteps] reproductionSteps)
    return ()

updateIssueReport :: IssueReport -> IO ()
updateIssueReport (EditIssueReport description specs reportId issueId programId status _type confirmed) = do
    conn <- connectPostgreSQL connectionString
    execute conn "UPDATE issue_reports SET description=?, specs=?, status=?, type=?, confirmed=? WHERE id=? and program=? and issue=?;" (description, specs, status, _type, confirmed, reportId, programId, issueId)
    return ()

updateIssueReportAsFixed :: Integer -> Integer -> Integer -> IO ()
updateIssueReportAsFixed programId issueId reportId = do
    conn <- connectPostgreSQL connectionString
    execute conn "UPDATE issue_reports SET status='Fixed' WHERE id=? AND issue=?" (reportId, issueId)
    return ()

insertIssueComment :: Integer -> IssueComment -> IO ()
insertIssueComment issueId (NewIssueComment text userId parentId) = do
    conn <- connectPostgreSQL connectionString
    execute conn "INSERT INTO issue_comments (issue, text, commenter, parent_comment) VALUES (?,?,?,?)" (issueId, text, userId, parentId)
    return ()

selectIssueComment :: Integer -> IO (DbIssueComment)
selectIssueComment commentId = do
    conn <- connectPostgreSQL connectionString
    [(id, issueId, text, timeCreated, editTime, userId, parentId)] <- query conn "SELECT id, issue, text, time_created, edit_time, commenter, parent_comment FROM issue_comments WHERE id=?;" [commentId]
    return $ ExistingDbIssueComment issueId text userId parentId timeCreated editTime id

selectIssueComments :: Integer -> Integer -> IO ([DbIssueComment])
selectIssueComments programId issueId = do
    conn <- connectPostgreSQL connectionString
    xs <- query conn "SELECT id, issue, text, time_created, edit_time, commenter, parent_comment FROM issue_comments WHERE issue=?;" [issueId]
    return $ map (\(id, issue, text, timeCreated, editTime, userId, parentComment) -> ExistingDbIssueComment issue text userId parentComment timeCreated editTime id) xs

updateIssueComment :: Integer -> IssueComment -> IO ()
updateIssueComment commentId (EditIssueComment text) = do
    conn <- connectPostgreSQL connectionString
    execute conn "UPDATE issue_comments SET text=?, edit_time=NOW() WHERE id=?" [commentId]
    return ()

insertIssueReportComment :: Integer -> IssueReportComment -> IO ()
insertIssueReportComment issueId (NewIssueReportComment text userId parentId) = do
    conn <- connectPostgreSQL connectionString
    execute conn "INSERT INTO issue_report_comments (issue_report, text, commenter, parent_comment) VALUES (?,?,?,?)" (issueId, text, userId, parentId)
    return ()

selectIssueReportComment :: Integer -> IO (DbIssueReportComment)
selectIssueReportComment commentId = do
    conn <- connectPostgreSQL connectionString
    [(id, issueId, text, timeCreated, editTime, userId, parentId)] <- query conn "SELECT id, issue_report, text, time_created, edit_time, commenter, parent_comment FROM issue_report_comments WHERE id=?;" [commentId]
    return $ ExistingDbIssueReportComment issueId text userId parentId timeCreated editTime id

selectIssueReportComments :: Integer -> Integer -> Integer -> IO ([DbIssueReportComment])
selectIssueReportComments programId issueId reportId = do
    conn <- connectPostgreSQL connectionString
    xs <- query conn "SELECT id, issue_report, text, time_created, edit_time, commenter, parent_comment FROM issue_report_comments WHERE issue_report=?;" [reportId]
    return $ map (\(id, issueReport, text, timeCreated, editTime, userId, parentComment) -> ExistingDbIssueReportComment issueReport text userId parentComment timeCreated editTime id) xs

updateIssueReportComment :: Integer -> IssueReportComment -> IO ()
updateIssueReportComment commentId (EditIssueReportComment text) = do
    conn <- connectPostgreSQL connectionString
    execute conn "UPDATE issue_report_comments SET text=?, edit_time=NOW() WHERE id=?" [commentId]
    return ()
