module Buggy.Persistence.Types (
    DbIssue(..),
    DbIssueType(..)
) where

import Buggy.Types.Types

data DbIssue = DbNew { getProgram :: String
                     , getTitle :: String
                     , getDescription :: String
                     , getIssueType :: IssueType
                     , getReproductionSteps :: [ReproductionStep]
                     , getStatus :: StatusType 
                     , getReporter :: User
                     } |
               DbExisting { getProgram :: String
                          , getIssueId :: Integer
                          , getTitle :: String
                          , getDescription :: String
                          , getIssueType :: IssueType
                          , getReproductionSteps :: [ReproductionStep]
                          , getTimeReported :: String
                          , getStatus :: StatusType 
                          , getReporter :: User
                          } deriving (Eq, Read, Show)
