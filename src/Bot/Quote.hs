{-# LANGUAGE OverloadedStrings #-}
module Bot.Quote where

import           Bot.Replies
import qualified Data.Map as M
import qualified Data.Text as T
import           Data.Time
import           Effect
import           Entity
import           Text.Read
import           Text.Printf

addQuoteCommand :: T.Text -> T.Text -> Effect ()
addQuoteCommand sender quoteContent =
    (quoteProperties quoteContent sender <$> now)
    >>= createEntity "quote"
    >>= (quoteAddedReply sender . entityId)

quoteCommand :: T.Text -> T.Text -> Effect ()
quoteCommand sender "" =
    getRandomEntity "quote" >>= quoteFoundReply sender
quoteCommand sender quoteIdText =
    maybe
      (replyToUser sender "Couldn't find any quotes")
      (\quoteId -> getEntityById "quote" quoteId >>= quoteFoundReply sender)
      (readMaybe $ T.unpack quoteIdText)

quoteAddedReply :: T.Text -> Int -> Effect ()
quoteAddedReply user quoteId =
    replyToUser user
      $ T.pack
      $ printf "Added the quote under the number %d"
      $ quoteId

quoteFoundReply :: T.Text -> Maybe Entity -> Effect ()
quoteFoundReply user (Nothing) = replyToUser user "Couldn't find any quotes"
quoteFoundReply user (Just entity) =
    case M.lookup "content" $ entityProperties entity of
      Nothing ->
          do logMsg
               $ T.pack
               $ printf "Quote #%d doesn't have the 'content field'"
               $ entityId entity
             replyToUser user "Couldn't find any quotes, because of some database issues."
      Just (PropertyText content) ->
          replyToUser user
            $ T.pack
            $ printf "%s (%d)" content
            $ entityId entity
      Just _ -> do logMsg
                     $ T.pack
                     $ printf "Quote #%d content is not text"
                     $ entityId entity
                   replyToUser user "Couldn't find any quotes, because of some database issues."

quoteProperties :: T.Text -> T.Text -> UTCTime -> Properties
quoteProperties content quoter timestamp =
    M.fromList [ ("content", PropertyText content)
               , ("quoter", PropertyText quoter)
               , ("timestamp", PropertyUTCTime timestamp)
               ]
