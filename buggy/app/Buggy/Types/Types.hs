{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE OverloadedStrings #-}

module Buggy.Types.Types (
    Issue(..),
    IssueType(..),
    IssueReport(..),
    StatusType(..),
    ReproductionStep(..),
    Program(..),
    User(..),
    IssueReportStatus(..),
    IssueReportType(..),
    IssueComment(..),
    IssueReportComment(..),
    DbIssueComment(..),
    DbIssueReportComment(..),
    convertToIssueCommentTree,
    convertToReportCommentTree,
    toForest
) where

import Data.Time
import Data.Aeson
import Database.PostgreSQL.Simple.ToField
import qualified Data.ByteString.Char8 as B
import Happstack.Server
import Data.List (groupBy)
import Data.Text (Text)
import Data.Maybe (isNothing, fromJust)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import qualified Data.ByteString.Lazy as L

instance (ToJSON a) => ToMessage a where
    toContentType _  = B.pack "application/json;charset=utf-8"
    toMessage        = encode

data IssueType = Bug | Feature | UX | Graphic deriving (Eq, Show, Read)

data StatusType = Fixed | Open | Workaround | Reproducible | NotEnoughInformation deriving (Eq, Show, Read)

data ReproductionStep = Step { getStepDescription :: String 
                             } deriving (Eq, Show, Read)

data User = ExistingUser { getUserId :: Integer 
                         , getUsername :: String 
                         } deriving (Eq, Show, Read)

instance ToJSON User where
    toJSON (ExistingUser id name) = object ["id" .= id, "username" .= name]

data Program = ExistingProgram { getProgramId :: Integer
                               , getProgramName :: String
                               , getProgramIssueCount :: Integer
                               } | 
               NewProgram { getProgramName :: String } deriving (Eq, Show, Read)

instance ToJSON Program where
    toJSON (ExistingProgram id name issueCount) = object ["id" .= id, "name" .= name, "issues" .= issueCount]

data IssueReportStatus = Broken | Working | PartiallyWorking | Works | NoWork deriving (Eq, Show, Read)
data IssueReportType = Fix | PartialFix | Report deriving (Eq, Show, Read)

data IssueReport = NewIssueReport { getIssueReportDescription :: String
                                  , getIssueReportSpecs :: String
                                  , getIssueReportIssueId :: Integer
                                  , getIssueReportProgramId :: Integer
                                  , getIssueReportReporterId :: Integer
                                  , getIssueReportStatus :: IssueReportStatus
                                  , getIssueReportType :: IssueReportType
                                  } |
                   EditIssueReport { getIssueReportDescription :: String
                                   , getIssueReportSpecs :: String
                                   , getIssueReportId :: Integer
                                   , getIssueReportIssueId :: Integer
                                   , getIssueReportProgramId :: Integer
                                   , getIssueReportStatus :: IssueReportStatus
                                   , getIssueReportType :: IssueReportType
                                   , getIssueReportConfirmed :: Bool
                                   } |
                   ExistingIssueReport { getIssueReportDescription :: String
                                       , getIssueReportSpecs :: String
                                       , getIssueReportIssueId :: Integer
                                       , getIssueReportProgramId :: Integer
                                       , getIssueReportId :: Integer
                                       , getIssueReportReporter :: User
                                       , getIssueReportStatus :: IssueReportStatus
                                       , getIssueReportType :: IssueReportType
                                       , getIssueReportConfirmed :: Bool
                                       , getIssueReportTime :: LocalTime } deriving (Eq, Read)

instance ToJSON IssueReport where
    toJSON (ExistingIssueReport description specs issueId programId reportId reporter status _type confirmed time) = object [ "description" .= description
                                                                                                     , "specs" .= specs
                                                                                                     , "issueId" .= issueId
                                                                                                     , "programId" .= programId
                                                                                                     , "reporter" .= reporter
                                                                                                     , "status" .= status
                                                                                                     , "type" .= _type
                                                                                                     , "time" .= time
                                                                                                     , "id" .= reportId
                                                                                                     , "confirmed" .= confirmed
                                                                                                     ]

instance FromJSON IssueReportStatus where
    parseJSON (String s) = pure $ read $ T.unpack s

instance FromJSON IssueReportType where
    parseJSON (String s) = pure $ read $ T.unpack s

instance ToJSON IssueReportStatus where
    toJSON status = toJSON $ show status

instance ToJSON IssueReportType where
    toJSON _type = toJSON $ show _type

instance ToField IssueReportStatus where
    toField status = Escape (B.pack $ show status)

instance ToField IssueReportType where
    toField _type = Escape (B.pack $ show _type)

instance FromJSON IssueReport where
    parseJSON (Object v) = NewIssueReport <$>
                           v .: "description" <*>
                           v .: "specs" <*>
                           v .: "issueId" <*>
                           v .: "programId" <*>
                           v .: "reporterId" <*>
                           v .: "status" <*>
                           v .: "type"

instance ToJSON ReproductionStep where
    toJSON (Step instruction) = object ["instruction" .= instruction]

instance ToJSON Issue where
    toJSON (Existing programId issueId title description itype reproSteps time status reporter editTime) = object
                                                                                                [ "programId" .= programId
                                                                                                , "id" .= issueId
                                                                                                , "title" .= title
                                                                                                , "description" .= description
                                                                                                , "type" .= (show itype)
                                                                                                , "reproductionSteps" .= reproSteps
                                                                                                , "time" .= time
                                                                                                , "status" .= (show status)
                                                                                                , "reporter" .= reporter
                                                                                                , "lastEdited" .= (editTime)
                                                                                                ]

instance FromJSON IssueType where
    parseJSON (String s) = pure $ read $ T.unpack s

instance FromJSON ReproductionStep where
    parseJSON (String s) = pure $ Step (T.unpack s)

instance FromJSON Issue where
    parseJSON = withObject "issue" $ \o -> do
        id <- o .:? ("id")
        case id :: Maybe Integer of
            Nothing -> (New <$>
                        o .: "programId" <*>
                        o .: "title" <*>
                        o .: "description" <*> o .: "type" <*>
                        o .: "reproductionSteps" <*>
                        pure Open <*>
                        pure 1)
            _ -> (Edit <$>
                  o .: "programId" <*>
                  o .: "id" <*>
                  o .: "title" <*>
                  o .: "description" <*>
                  o .: "type" <*>
                  o .: "reproductionSteps" <*>
                  pure Open)

data Issue = New { getProgram :: Integer
                 , getTitle :: String
                 , getDescription :: String
                 , getIssueType :: IssueType
                 , getReproductionSteps :: [ReproductionStep]
                 , getStatus :: StatusType 
                 , getReporterId :: Integer
                 } |
             Existing { getProgram :: Integer
                      , getIssueId :: Integer
                      , getTitle :: String
                      , getDescription :: String
                      , getIssueType :: IssueType
                      , getReproductionSteps :: [ReproductionStep]
                      , getTimeReported :: LocalTime
                      , getStatus :: StatusType 
                      , getReporter :: User
                      , getEditTime :: Maybe LocalTime
                      } |
             Edit { getProgram :: Integer
                  , getIssueId :: Integer
                  , getTitle :: String
                  , getDescription :: String
                  , getIssueType :: IssueType
                  , getReproductionSteps :: [ReproductionStep]
                  , getStatus :: StatusType
             } deriving (Eq, Read, Show)

data DbIssueReportComment = ExistingDbIssueReportComment { getDbReportId :: Integer,
                                                           getDbReportCommentText :: Text,
                                                           getDbReportCommentUserId :: Integer,
                                                           getDbReportCommentParentComment :: Maybe Integer,
                                                           getDbReportCommentTimeCreated :: LocalTime,
                                                           getDbReportCommentEditTime :: Maybe LocalTime,
                                                           getDbReportCommentId :: Integer
                          } deriving (Eq, Read, Show)

data IssueReportComment = NewIssueReportComment { getReportCommentText :: Text,
                                                  getReportCommentUserId :: Integer,
                                                  getReportCommentParentComment :: Maybe Integer
                          } |
                          ExistingIssueReportComment { getReportId :: Integer,
                                                       getReportCommentText :: Text,
                                                       getReportCommentUserId :: Integer,
                                                       getReportCommentChildren :: [IssueReportComment],
                                                       getReportCommentTimeCreated :: LocalTime,
                                                       getReportCommentEditTime :: Maybe LocalTime,
                                                       getReportCommentId :: Integer
                          } |
                          EditIssueReportComment { getReportCommentText :: Text
                          } deriving (Eq, Read, Show)

instance ToJSON IssueReportComment where
    toJSON (ExistingIssueReportComment reportId text userId children timeCreated editTime id) = object
                                                                                  [ "reportId" .= reportId
                                                                                  , "comment" .= text
                                                                                  , "timeCreated" .= timeCreated
                                                                                  , "userId" .= userId
                                                                                  , "children" .= children
                                                                                  , "editTime" .= editTime
                                                                                  , "id" .= id
                                                                                  ]

instance FromJSON IssueReportComment where
    parseJSON (Object v) = NewIssueReportComment <$>
                           v .: "comment" <*>
                           v .: "userId" <*>
                           v .:? "parentCommentId"


data IssueComment = NewIssueComment { getCommentText :: Text,
                                      getCommentUserId :: Integer,
                                      getCommentParentComment :: Maybe Integer
                    } |
                    ExistingIssueComment { getCommentIssueId :: Integer,
                                           getCommentText :: Text,
                                           getCommentUserId :: Integer,
                                           getCommentChildren :: [IssueComment],
                                           getCommentTimeCreated :: LocalTime,
                                           getCommentEditTime :: Maybe LocalTime,
                                           getCommentId :: Integer
                    } |
                    EditIssueComment { getCommentText :: Text
                    } deriving (Eq, Read, Show)

data DbIssueComment = ExistingDbIssueComment { getDbCommentIssueId :: Integer,
                                               getDbCommentText :: Text,
                                               getDbCommentUserId :: Integer,
                                               getDbCommentParentComment :: Maybe Integer,
                                               getDbCommentTimeCreated :: LocalTime,
                                               getDbCommentEditTime :: Maybe LocalTime,
                                               getDbCommentId :: Integer
                    } deriving (Eq, Read, Show)

instance ToJSON IssueComment where
    toJSON (ExistingIssueComment issueId text userId children timeCreated editTime id) = object
                                                                                  [ "issueId" .= issueId
                                                                                  , "comment" .= text
                                                                                  , "timeCreated" .= timeCreated
                                                                                  , "userId" .= userId
                                                                                  , "children" .= children
                                                                                  , "editTime" .= editTime
                                                                                  , "id" .= id
                                                                                  ]

instance FromJSON IssueComment where
    parseJSON (Object v) = NewIssueComment <$>
                           v .: "comment" <*>
                           v .: "userId" <*>
                           v .:? "parentCommentId"

class CommentTree a where
    getChildren :: a -> [a]

class ChildComment a where
    getDbParentId :: a -> Maybe Integer

instance ChildComment DbIssueComment where
    getDbParentId = getDbCommentParentComment

instance ChildComment DbIssueReportComment where
    getDbParentId = getDbReportCommentParentComment

instance CommentTree IssueComment where
    getChildren = getCommentChildren

instance CommentTree IssueReportComment where
    getChildren = getReportCommentChildren

class ParentTree a where
    toForest :: CommentTree b => [a] -> ([a] -> a -> b) -> [b]
    getParentId :: a -> Maybe Integer
    getId :: a -> Integer

instance ParentTree DbIssueComment where
    toForest comments f = map
                           (f comments)
                           (filter (\comment -> isNothing (getDbCommentParentComment comment)) comments)
    getParentId = getDbCommentParentComment
    getId = getDbCommentId

instance ParentTree DbIssueReportComment where
    toForest comments f = map
                           (f comments)
                           (filter (\comment -> isNothing (getDbReportCommentParentComment comment)) comments)
    getParentId = getDbReportCommentParentComment
    getId = getDbReportCommentId

convertToIssueCommentTree :: [DbIssueComment] -> DbIssueComment -> IssueComment
convertToIssueCommentTree comments root = (ExistingIssueComment
                                (getDbCommentIssueId root)
                                (getDbCommentText root)
                                (getDbCommentUserId root)
                                (map (\x -> convertToIssueCommentTree comments x) (getChildComments (getDbCommentId root) comments))
                                (getDbCommentTimeCreated root)
                                (getDbCommentEditTime root)
                                (getDbCommentId root))

convertToReportCommentTree :: [DbIssueReportComment] -> DbIssueReportComment -> IssueReportComment
convertToReportCommentTree comments root = (ExistingIssueReportComment
                                (getDbReportId root)
                                (getDbReportCommentText root)
                                (getDbReportCommentUserId root)
                                (map (\x -> convertToReportCommentTree comments x) (getChildComments (getDbReportCommentId root) comments))
                                (getDbReportCommentTimeCreated root)
                                (getDbReportCommentEditTime root)
                                (getDbReportCommentId root))

getChildComments :: ChildComment a =>  Integer -> [a] -> [a]
getChildComments id comments = filter (\x -> (maybe False (\y -> y == id) (getDbParentId x))) comments
