module ElmFormat.ImportInfoTest where

import Elm.Utils ((|>))

import AST.V0_16
import AST.Module (ImportMethod(..))
import AST.Variable (Listing(..))
import Test.Tasty
import Test.Tasty.HUnit

import qualified Data.Map as Dict
import qualified Data.Set as Set
import qualified ElmFormat.ImportInfo as ImportInfo

tests :: TestTree
tests =
    testGroup "ElmFormat.ImportInfo"
    [ testGroup "_directImports" $
        let
            assertIncludes = assert "include" True
            assertExcludes = assert "exclude" False

            assert what expected name i =
                let
                    set =
                        i
                            |> fmap (\(a, b, c) -> (fmap UppercaseIdentifier a, ImportMethod (fmap (\x -> ([], ([], UppercaseIdentifier x))) b) ([], ([], c))))
                            |> Dict.fromList
                            |> ImportInfo.fromImports
                            |> ImportInfo._directImports
                in
                Set.member (fmap UppercaseIdentifier name) set
                    |> assertEqual ("expected " ++ show set ++ " to " ++ what ++ ": " ++ show name) expected
        in
        [ testCase "includes Basics" $
          []
            |> assertIncludes ["Basics"]
        , testCase "includes normal imports" $
          [ (["A"], Nothing, ClosedListing) ]
            |> assertIncludes ["A"]
        , testCase "includes normal deep imports" $
          [ (["A", "Deep"], Nothing, ClosedListing) ]
            |> assertIncludes ["A", "Deep"]
        , testCase "excludes imports with aliases" $
          [ (["A"], Just "X", ClosedListing) ]
            |> assertExcludes ["A"]

        -- TODO: what if the alias is the same as the import name?
        ]
    ]
