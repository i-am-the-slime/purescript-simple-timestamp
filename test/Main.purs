module Test.Main where

import Prelude

import Control.Monad.Except (runExcept)
import Data.DateTime (DateTime(..), Month(..), Time(..), canonicalDate)
import Data.Either (Either(..))
import Data.Enum (toEnum)
import Data.Maybe (fromJust)
import Data.Traversable (traverse_)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Partial.Unsafe (unsafePartial)
import Simple.JSON (readImpl, write, writeImpl)
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter (consoleReporter)
import Test.Spec.Runner (runSpec)
import Timestamp (Timestamp(..))

main :: Effect Unit
main = launchAff_ do
  runSpec [consoleReporter] do
    describe "timestamp" do
      it "should parse a timestamp" do
        let
          ts = unsafePartial $ fromJust
            do
              y <- (toEnum 2018)
              d <- (toEnum 12)
              h <- (toEnum 12)
              m <- (toEnum 58)
              s <- (toEnum 10)
              ms <- (toEnum 862)
              pure $ (Timestamp (DateTime (canonicalDate y July d) (Time h m s ms)))
        (runExcept $ readImpl (write "2018-07-12T12:58:10.862Z")) `shouldEqual` (Right ts)
      it "should roundtrip a few timestamps from nakadi" do
        let
          timestamps =
            [ "2019-06-27T14:36:51.956Z"
            , "2019-06-04T00:31:05.642Z"
            , "2018-03-20T09:45:39.143Z"
            , "2019-06-02T02:41:45.244Z"
            , "2018-07-12T12:58:10.862Z"
            , "2019-07-04T07:43:48.398Z"
            ]
          roundtrip e =
            runExcept $ do
              w <- writeImpl <$> (readImpl (write e) :: _ Timestamp)
              readImpl w
        traverse_ (\e -> (Right e) `shouldEqual` (roundtrip e)) timestamps