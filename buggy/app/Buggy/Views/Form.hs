{-# LANGUAGE OverloadedStrings #-}

module Buggy.Views.Form (
    newIssueForm,
    newIssueReportForm
) where

import Buggy.Types.Types
import Text.Digestive.Form
import Data.Text
import qualified Data.Text as T

newIssueForm :: Monad m => Form Text m Issue
newIssueForm = New <$> "program" .: existingProgramForm Nothing 
                   <*> "title" .: string Nothing
                   <*> "description" .: string Nothing
                   <*> "type" .: choice [(Bug, "Bug"), (Feature, "Feature")] (Just Bug)
                   <*> "reproductionstep" .: listOf reproductionStepForm (Just [Step "step 1", Step "step 2"])
                   <*> "status" .: choice [(Fixed, "Fixed"), (Open, "Open"), (Workaround, "Work around"), (Reproducible, "Reproducable"), (NotEnoughInformation, "Not enough information")] (Just Open)
                   <*> "reporter" .: existingUserForm Nothing

newIssueReportForm :: Monad m => Form Text m IssueReport
newIssueReportForm = NewIssueReport <$> "description" .: string Nothing
                   <*> "specs" .: string Nothing
                   <*> "issueid" .: stringRead "Issue id must be an integer" (Just 1)
                   <*> "programid" .: stringRead "Program id must be an integer" (Just 1)
                   <*> "reporter" .: existingUserForm Nothing
                   <*> "labels" .: listOf (stringRead "") (Just [])

reproductionStepForm :: Monad m => Formlet Text m ReproductionStep
reproductionStepForm _ =  Step <$> "stepdescription" .: string Nothing

existingUserForm :: Monad m => Formlet Text m User
existingUserForm _ = ExistingUser <$> "id" .: stringRead "Id must be an integer" (Just 1) 
                                  <*> "username" .: string (Just "Deadleg")

existingProgramForm :: Monad m => Formlet Text m Program
existingProgramForm _ = ExistingProgram <$> "id" .: stringRead "Id must be an integer" (Just 1) 
                                  <*> "name" .: string (Just "CS") 
