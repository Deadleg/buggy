module Buggy.Persistence.Instances (
   DatabaseConvertable(..) 
)

import Buggy.Persistence.Types
import Buggy.Persistence.Postgre

class DatabaseConvertable a where
    convertToDatabase :: a -> IO (b)
    convertToDomain :: IO (b) -> a

instance DatabaseConvertable DbNew where
    convertToDatabase :: a -> IO (a)
