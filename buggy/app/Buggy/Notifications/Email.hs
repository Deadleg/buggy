module Email where (
    sendEmail
)

import Buggy.Types.Types
import Network.Mail.SMTP

sendEmail :: Messageable a => a -> [String] -> IO ()
sendEmail _ _ = return

