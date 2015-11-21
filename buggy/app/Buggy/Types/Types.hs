module Buggy.Types.Types (
    Issue(..),
    IssueType(..),
    IssueReport(..),
    StatusType(..),
    ReproductionStep(..),
    Program(..),
    User(..),
    IssueReportLabel(..)
) where

import Data.Time

data IssueType = Bug | Feature | UX | Graphic deriving (Eq, Show, Read)

data StatusType = Fixed | Open | Workaround | Reproducible | NotEnoughInformation deriving (Eq, Show, Read)

data ReproductionStep = Step { getStepDescription :: String 
                             } deriving (Eq, Show, Read)

data User = ExistingUser { getUserId :: Integer 
                         , getUsername :: String 
                         } deriving (Eq, Show, Read)

data Program = ExistingProgram { getProgramId :: Integer
                               , getProgramName :: String
                               } | 
               NewProgram { getProgramName :: String } deriving (Eq, Show, Read)

data IssueReportLabel = PendingFeedBack | Fix | PartialFix | Unconfirmed | Confirmed | PartiallyWorking deriving (Eq, Show, Read)

data IssueReport = NewIssueReport { getIssueReportDescription :: String
                                  , getIssueReportSpecs :: String
                                  , getIssueReportIssueId :: Integer
                                  , getIssueReportProgramId :: Integer
                                  , getIssueReportReporter :: User
                                  , getIssueReportLabels :: [IssueReportLabel]
                                  } |
                   ExistingIssueReport { getIssueReportDescription :: String
                                       , getIssueReportSpecs :: String
                                       , getIssueReportIssueId :: Integer
                                       , getIssueReportProgramId :: Integer
                                       , getIssueReportReporter :: User
                                       , getIssueReportLabels :: [IssueReportLabel]
                                       , getIssueReportTime :: LocalTime } deriving (Eq, Read)

data Issue = New { getProgram :: Program
                 , getTitle :: String
                 , getDescription :: String
                 , getIssueType :: IssueType
                 , getReproductionSteps :: [ReproductionStep]
                 , getStatus :: StatusType 
                 , getReporter :: User
                 } |
             Existing { getProgram :: Program
                      , getIssueId :: Integer
                      , getTitle :: String
                      , getDescription :: String
                      , getIssueType :: IssueType
                      , getReproductionSteps :: [ReproductionStep]
                      , getTimeReported :: LocalTime
                      , getStatus :: StatusType 
                      , getReporter :: User
                      } deriving (Eq, Read, Show)
