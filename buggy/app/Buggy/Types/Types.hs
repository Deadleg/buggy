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
    IssueCommentReport(..),
    IssueReportCommentReport(..),
    DbIssueComment(..),
    DbIssueReportComment(..),
    Messageable(..),
    Reportable(..),
    convertToIssueCommentTree,
    convertToReportCommentTree,
    toForest,
    NewUser(..),
    LoginType(..),
    MyIssue(..),
    UserOperations(..),
    UserOperationsT(..),
    UserOperationsIO(..)
) where

import Data.Time
import Data.Aeson
import Database.PostgreSQL.Simple.ToField
import qualified Data.ByteString.Char8 as B
import Happstack.Server
import Data.List (groupBy)
import Data.Text (Text)
import Data.Maybe (isNothing, fromJust)
import Control.Monad
import Control.Monad.IO.Class
import Control.Monad.Trans.Class
import Control.Applicative
import Happstack.Server (Cookie)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import qualified Data.ByteString.Lazy as L

type ErrorCode = Int

data UserOperations a = Authorized a | NotAuthenticated | NotAuthorized | BadRequest ErrorCode Text

newtype UserOperationsT m a = UserOperationsT { runUserOperations :: m (UserOperations a) }

type UserOperationsIO a = UserOperationsT IO a

instance Functor m => Functor (UserOperationsT m) where
    fmap f a = UserOperationsT $ fmap (fmap f) (runUserOperations a)

instance Applicative m => Applicative (UserOperationsT m) where
    pure = UserOperationsT . pure . pure
    UserOperationsT m1 <*> userOp = UserOperationsT $ liftA2 (<*>) m1 (runUserOperations userOp)

instance (Monad m, Applicative m, Functor m) => Monad (UserOperationsT m) where
    return = UserOperationsT . return . Authorized

    x >>= f = UserOperationsT $ do
        op <- runUserOperations x
        case op of
            Authorized a -> runUserOperations (f a)
            NotAuthorized -> return NotAuthorized
            NotAuthenticated -> return NotAuthenticated

instance MonadTrans UserOperationsT where
    lift m = UserOperationsT $ liftM Authorized m

instance (MonadIO m) => MonadIO (UserOperationsT m) where
    liftIO = lift . liftIO

instance Functor UserOperations where
    fmap f (Authorized x) = Authorized (f x)
    fmap f NotAuthenticated = NotAuthenticated
    fmap f NotAuthorized = NotAuthorized

instance Applicative UserOperations where
    pure x = Authorized x

    Authorized f <*> m = fmap f m
    NotAuthenticated <*> _ = NotAuthenticated
    NotAuthorized <*> _ = NotAuthorized

    Authorized f *> m = m
    NotAuthenticated *> _ = NotAuthenticated
    NotAuthorized *> _ = NotAuthorized

instance Monad UserOperations where
    return = pure
    op >>= f = case op of
        Authorized a -> f a
        NotAuthenticated -> NotAuthenticated
        NotAuthorized -> NotAuthorized
    fail _ = NotAuthorized

instance Alternative UserOperations where
    empty = NotAuthorized

    l <|> NotAuthorized = l
    l <|> NotAuthenticated = l
    _ <|> r = r

instance MonadPlus UserOperations

instance (ToJSON a) => ToMessage a where
    toContentType _  = B.pack "application/json;charset=utf-8"
    toMessage        = encode

data IssueType = Bug | Feature | UX | Graphic deriving (Eq, Show, Read)

data StatusType = Fixed | Open | Workaround | Reproducible | NotEnoughInformation deriving (Eq, Show, Read)

data LoginType = Google | Steam deriving (Eq, Show, Read)

data ReproductionStep = Step { getStepDescription :: String 
                             } deriving (Eq, Show, Read)

data NewUser = NewUser
                { username :: Text
                , email :: Maybe Text
                , steamId :: Maybe Text
                , loginType :: LoginType
                } deriving (Eq, Show, Read)

data User = ExistingUser
                { getUserId :: Integer
                , getUsername :: Text
                } |
             FullExistingUser
                { getUserId :: Integer
                , getUsername :: Text
                , getUserEmail :: Maybe Text
                , getUserSteamId :: Maybe Text
                , getUserLoginType :: LoginType
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
                                       , getIssueReportTime :: LocalTime
                                       , getIssueUpvotes :: Integer } deriving (Eq, Read)

instance ToJSON IssueReport where
    toJSON (ExistingIssueReport description specs issueId programId reportId reporter status _type confirmed time upvotes) = object [ "description" .= description
                                                                                                     , "specs" .= specs
                                                                                                     , "issueId" .= issueId
                                                                                                     , "programId" .= programId
                                                                                                     , "reporter" .= reporter
                                                                                                     , "status" .= status
                                                                                                     , "type" .= _type
                                                                                                     , "time" .= time
                                                                                                     , "id" .= reportId
                                                                                                     , "confirmed" .= confirmed
                                                                                                     , "upvotes" .= upvotes
                                                                                                     ]

instance FromJSON IssueReportStatus where
    parseJSON (String s) = pure $ read $ T.unpack s

instance FromJSON IssueReportType where
    parseJSON (String s) = pure $ read $ T.unpack s

instance ToJSON IssueReportStatus where
    toJSON status = toJSON $ show status

instance ToJSON IssueReportType where
    toJSON _type = toJSON $ show _type

instance ToJSON IssueType where
    toJSON _type = toJSON $ show _type

instance ToJSON StatusType where
    toJSON status = toJSON $ show status

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
    toJSON (Existing programId issueId title description itype reproSteps time status reporter editTime upvotes) = object
                                                                                                [ "programId" .= programId
                                                                                                , "id" .= issueId
                                                                                                , "title" .= title
                                                                                                , "description" .= description
                                                                                                , "type" .= itype
                                                                                                , "reproductionSteps" .= reproSteps
                                                                                                , "time" .= time
                                                                                                , "status" .= status
                                                                                                , "reporter" .= reporter
                                                                                                , "lastEdited" .= editTime
                                                                                                , "upvotes" .= upvotes
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
                      , getUpvotes :: Integer
                      } |
             Edit { getProgram :: Integer
                  , getIssueId :: Integer
                  , getTitle :: String
                  , getDescription :: String
                  , getIssueType :: IssueType
                  , getReproductionSteps :: [ReproductionStep]
                  , getStatus :: StatusType
             } deriving (Eq, Read, Show)

data MyIssue = MyIssue
    {
        getMyIssueIsWatching :: Bool,
        getMyIssueIsMine :: Bool
    }

instance ToJSON MyIssue where
    toJSON (MyIssue watching mine) = object [ "watching" .= watching, "mine" .= mine ]

data DbIssueReportComment = ExistingDbIssueReportComment { getDbReportId :: Integer,
                                                           getDbReportCommentText :: Text,
                                                           getDbReportCommentUserId :: Integer,
                                                           getDbReportCommentParentComment :: Maybe Integer,
                                                           getDbReportCommentTimeCreated :: LocalTime,
                                                           getDbReportCommentEditTime :: Maybe LocalTime,
                                                           getDbReportCommentId :: Integer,
                                                           getDbReportCommentUpvotes :: Integer
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
                                                       getReportCommentId :: Integer,
                                                       getReportCommentUpvotes :: Integer
                          } |
                          EditIssueReportComment { getReportCommentText :: Text
                          } deriving (Eq, Read, Show)

instance ToJSON IssueReportComment where
    toJSON (ExistingIssueReportComment reportId text userId children timeCreated editTime id upvotes) = object
                                                                                  [ "reportId" .= reportId
                                                                                  , "comment" .= text
                                                                                  , "timeCreated" .= timeCreated
                                                                                  , "userId" .= userId
                                                                                  , "children" .= children
                                                                                  , "editTime" .= editTime
                                                                                  , "id" .= id
                                                                                  , "upvotes" .= upvotes
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
                                           getCommentId :: Integer,
                                           getCommentUpvotes :: Integer
                    } |
                    EditIssueComment { getCommentText :: Text
                    } deriving (Eq, Read, Show)

data DbIssueComment = ExistingDbIssueComment { getDbCommentIssueId :: Integer,
                                               getDbCommentText :: Text,
                                               getDbCommentUserId :: Integer,
                                               getDbCommentParentComment :: Maybe Integer,
                                               getDbCommentTimeCreated :: LocalTime,
                                               getDbCommentEditTime :: Maybe LocalTime,
                                               getDbCommentId :: Integer,
                                               getDbCommentUpvotes :: Integer
                    } deriving (Eq, Read, Show)

instance ToJSON IssueComment where
    toJSON (ExistingIssueComment issueId text userId children timeCreated editTime id upvotes) = object
                                                                                  [ "issueId" .= issueId
                                                                                  , "comment" .= text
                                                                                  , "timeCreated" .= timeCreated
                                                                                  , "userId" .= userId
                                                                                  , "children" .= children
                                                                                  , "editTime" .= editTime
                                                                                  , "id" .= id
                                                                                  , "upvotes" .= upvotes
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
                                (getDbCommentId root)
                                (getDbCommentUpvotes root))

convertToReportCommentTree :: [DbIssueReportComment] -> DbIssueReportComment -> IssueReportComment
convertToReportCommentTree comments root = (ExistingIssueReportComment
                                (getDbReportId root)
                                (getDbReportCommentText root)
                                (getDbReportCommentUserId root)
                                (map (\x -> convertToReportCommentTree comments x) (getChildComments (getDbReportCommentId root) comments))
                                (getDbReportCommentTimeCreated root)
                                (getDbReportCommentEditTime root)
                                (getDbReportCommentId root)
                                (getDbReportCommentUpvotes root))

getChildComments :: ChildComment a =>  Integer -> [a] -> [a]
getChildComments id comments = filter (\x -> (maybe False (\y -> y == id) (getDbParentId x))) comments

class Messageable a where
    sendMessage :: a -> [b] -> IO ()

class Messageable a => Reportable a where
    notifyReportee :: a -> IO ()

instance Messageable Issue where
    sendMessage _ _ = return () -- TODO

instance Messageable IssueCommentReport where
    sendMessage _ _ = return () -- TODO

instance Reportable IssueCommentReport where
    notifyReportee report = do
        sendMessage report [] -- TODO get recipients

instance Messageable IssueReportCommentReport where
    sendMessage _ _ = return () -- TODO

instance Reportable IssueReportCommentReport where
    notifyReportee report = do
        sendMessage report [] -- TODO get recipients

-- TODO define instances for the above
data IssueCommentReport = NewIssueCommentReport {
                              getIssueCommentReporter :: Integer
                          } |
                          ExistingIssueCommentReport {
                              getIssueCommentReporter :: Integer
                            , getIssueCommentId :: Integer
                            , getIssueCommentReportId :: Integer
                            , getIssueCommentReportTime :: LocalTime
                            , getIssueCommentReporteeNotified :: Maybe LocalTime
                          }

data IssueReportCommentReport = NewIssueReportCommentReport {
                              getIssueReportCommentReporter :: Integer
                          } |
                          ExistingIssueReportCommentReport {
                              getIssueReportCommentReporter :: Integer
                            , getIssueReportCommentId :: Integer
                            , getIssueReportCommentReportId :: Integer
                            , getIssueReportCommentReportTime :: LocalTime
                            , getIssueReportCommentReporteeNotified :: Maybe LocalTime
                          }

instance FromJSON IssueCommentReport where
    parseJSON (Object v) = NewIssueCommentReport <$> v .: "reporter"

instance FromJSON IssueReportCommentReport where
    parseJSON (Object v) = NewIssueReportCommentReport <$> v .: "reporter"
