{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Types (
    Player(..)
  , Name(..)
  , Rank
  , Rating(..)
  , RatingTable(..)  
  , RatingEntry(..)
  , Odds(..)
  , RecentMatches(..)
  , MatchList(..)
  , MatchOutcome(..)
  , CurrentMatch(..)
) where

import           Data.Semigroup
import           Control.Applicative

import           Data.Aeson                  as JSON

import           Text.Blaze
import qualified Text.Blaze.Html5            as H
import qualified Text.Blaze.Html5.Attributes as A
import           Text.Blaze.Internal (textValue)

import qualified Data.Text                   as T

import           Web.Encodings (encodeUrl)
import           Data.Attoparsec.ByteString.Char8

instance Semigroup T.Text where
  (<>) = mappend

data Name = Name T.Text
  deriving (Show)

newtype Rating = Rating Double
  deriving (Show, Num, Real, Ord, Eq, RealFrac, Fractional)

type Rank = Integer

data Player = Player {
    playerName    :: Name
  , playerRank    :: Rank
  , playerRating  :: Rating
  , playerHistory :: MatchList
}

data RatingEntry = RatingEntry Name Rank Rating

data RatingTable = RatingTable Rank [RatingEntry]

newtype Odds = Odds Double
  deriving (Show, Num, Real, Ord, Eq, RealFrac, Fractional)

data MatchOutcome = MatchOutcome Name Name Bool Odds
  deriving Show

data CurrentMatch = CurrentMatch Name Name Odds
  deriving Show

data MatchList = MatchList [MatchOutcome]
  deriving Show

instance FromJSON Name where
  parseJSON (String name) = return . Name $ name

instance ToJSON Name where
  toJSON (Name n) = toJSON n

instance FromJSON Odds where
  parseJSON (Number (D x)) = return . Odds $ x

instance FromJSON MatchOutcome where
  parseJSON (Object v) = MatchOutcome <$>
                         v .: "p1" <*>
                         v .: "p2" <*>
                         v .: "p1Won" <*>
                         v .: "odds"

instance FromJSON CurrentMatch where
  parseJSON (Object v) = CurrentMatch 
                      <$> v .: "p1" 
                      <*> v .: "p2"
                      <*> v .: "odds"

sigfig :: Double -> Double
sigfig x = fromIntegral (round (x * 100.0)) / 100.0

instance ToMarkup Player where
  toMarkup (Player name rank rating matches) = do 
    H.h2 $ do
      H.toHtml name
      "'s Matches"
    H.h4 $ do
      "Elo rating of "
      H.toHtml rating
      ""
    H.toHtml matches

instance ToMarkup Name where
  toMarkup (Name name) = H.a
    ! A.class_ "player"
    ! A.href (textValue $ "/player/"<>encodeUrl name)
    $ H.toHtml name

instance ToMarkup RatingEntry where
  toMarkup (RatingEntry name rank score) = do
    H.tr $ do
      H.td $ H.toHtml $ rank
      H.td $ H.toHtml $ name
      H.td $ H.toHtml $ score

instance ToMarkup RatingTable where
  toMarkup (RatingTable _ ratings) = do
    H.table ! A.class_ "table table-striped"! A.id "rankings" $ do
      H.thead $ H.tr $ do
        H.th $ H.toHtml $ ("rank" :: T.Text)
        H.th $ H.toHtml $ ("name" :: T.Text)
        H.th $ H.toHtml $ ("score" :: T.Text)
      mapM_ H.toHtml ratings

newtype RecentMatches = RecentMatches MatchList

instance ToMarkup RecentMatches where
  toMarkup (RecentMatches ms) = (H.toHtml ms) ! A.id "recentMatches" 

instance ToMarkup MatchList where
  toMarkup (MatchList matches) = H.table ! A.class_ "table table-striped" $ do
    H.thead $ do
      H.tr $ do
        H.th ! A.class_ "p1" $ do "Player 1"
        H.th ! A.class_ "p2" $ do "Player 2"
        H.th $ do "Odds"
    mapM_ H.toHtml matches

instance ToMarkup Rating where
  toMarkup (Rating r) = do
    H.toHtml $ sigfig r

instance ToMarkup Odds where
  toMarkup (Odds o) = do
    H.toHtml . sigfig . (*100.0) $ o
    "%"


{-    let (p1, p2) = if o > 0.5
                   then (H.toHtml . sigfig $ o/(1.0-o), "1")
                   else ("1", H.toHtml . sigfig $ o/(1.0-o))
    H.span ! A.class_ "p1" $ p1
    ":"
    H.span ! A.class_ "p2" $ p2
-}

instance ToMarkup MatchOutcome where
  toMarkup (MatchOutcome p1 p2 p1Won odds) = do
    H.tr $ do
      let (p1Class, p2Class) = if p1Won
          then ("winner", "loser")
          else ("loser", "winner")
      H.td ! A.class_ p1Class $ H.toHtml p1
      H.td ! A.class_ p2Class $ H.toHtml p2
      let oddsClass = if odds >= 0.6
          then "correct"
          else if odds <= 0.4
            then "incorrect"
            else "ok"
      H.td ! A.class_ oddsClass $ H.toHtml odds

instance ToMarkup CurrentMatch where
  toMarkup (CurrentMatch p1 p2 odds) = do 
    H.div $ do
      H.span ! A.class_ "p1" $ H.toHtml p1
      " vs. "
      H.span ! A.class_ "p2" $ H.toHtml p2
    H.div $ do
      H.toHtml odds
      " and "
      H.toHtml (1.0 - odds)

