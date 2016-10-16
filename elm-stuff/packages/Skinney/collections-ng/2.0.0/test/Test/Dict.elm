module Test.Dict exposing (tests)

import CollectionsNg.Dict exposing (..)
import ElmTest exposing (..)


tests : Test
tests =
    suite "Dict tests"
        [ emptyTests
        , sizeTests
        , getSetTests
        , conversionTests
        , mergeTests
        ]


simpleDict : Dict String String
simpleDict =
    fromList
        [ ( "Key1", "Val1" )
        , ( "Key2", "Val2" )
        , ( "Key3", "Val3" )
        ]


emptyTests : Test
emptyTests =
    suite "Empty"
        [ test "empty has 0 size" <| assertEqual 0 <| size empty
        , test "0 size is empty" <| assert <| isEmpty empty
        ]


sizeTests : Test
sizeTests =
    suite "Length"
        [ test "simple count" <| assertEqual 3 <| size simpleDict
        , test "insert increases size" <| assertEqual 4 <| size (insert "Key4" "Val4" simpleDict)
        , test "replace does not increase size" <| assertEqual 3 <| size (insert "Key3" "Val45" simpleDict)
        , test "remove decreases size" <| assertEqual 2 <| size (remove "Key2" simpleDict)
        , test "remove noop does not decrease size" <| assertEqual 3 <| size (remove "Key50" simpleDict)
        , test "singleton has 1 size" <| assertEqual 1 <| size (singleton "Key1" "Val1")
        ]


getSetTests : Test
getSetTests =
    suite "Get set"
        [ test "get from singleton"
            <| assertEqual (Just "Val1")
            <| get "Key1" (singleton "Key1" "Val1")
        , test "simple get"
            <| assertEqual (Just "Val2")
            <| get "Key2" simpleDict
        , test "nonexistant get"
            <| assertEqual Nothing
            <| get "Key4" simpleDict
        , test "simple set"
            <| assertEqual (Just "Val4")
            <| get "Key4" (insert "Key4" "Val4" simpleDict)
        , test "simple remove"
            <| assertEqual Nothing
            <| get "Key2" (remove "Key2" simpleDict)
        , test "simple update"
            <| assertEqual (Just "Val3Val")
            <| get "Key3" (update (always (Just "Val3Val")) "Key3" simpleDict)
        , test "upsert"
            <| assertEqual (Just "Val5")
            <| get "Key5" (update (always (Just "Val5")) "Key5" simpleDict)
        , test "remove by update"
            <| assertEqual Nothing
            <| get "Key2" (update (always Nothing) "Key2" simpleDict)
        , test "member exists"
            <| assert
            <| member "Key2" simpleDict
        , test "member nonexist"
            <| assertEqual False
            <| member "Key4" simpleDict
        ]


conversionTests : Test
conversionTests =
    suite "Conversion"
        [ test "toList"
            <| assertEqual (fromList [ ( "Key2", "Val2" ), ( "Key1", "Val1" ), ( "Key3", "Val3" ) ])
            <| simpleDict
        , test "keys"
            <| assertEqual [ "Key2", "Key1", "Key3" ]
            <| keys simpleDict
        , test "values"
            <| assertEqual [ "Val2", "Val1", "Val3" ]
            <| values simpleDict
        ]


mergeTests : Test
mergeTests =
    let
        insertBoth key leftVal rightVal dict =
            insert key (leftVal ++ rightVal) dict

        s1 =
            singleton "u1" [ 1 ]

        s2 =
            singleton "u2" [ 2 ]

        s23 =
            singleton "u2" [ 3 ]

        b1 =
            List.map (\i -> ( i, [ i ] )) [1..10] |> fromList

        b2 =
            List.map (\i -> ( i, [ i ] )) [5..15] |> fromList

        bExpected =
            fromList [ ( 1, [ 1 ] ), ( 2, [ 2 ] ), ( 3, [ 3 ] ), ( 4, [ 4 ] ), ( 5, [ 5, 5 ] ), ( 6, [ 6, 6 ] ), ( 7, [ 7, 7 ] ), ( 8, [ 8, 8 ] ), ( 9, [ 9, 9 ] ), ( 10, [ 10, 10 ] ), ( 11, [ 11 ] ), ( 12, [ 12 ] ), ( 13, [ 13 ] ), ( 14, [ 14 ] ), ( 15, [ 15 ] ) ]
    in
        suite "merge Tests"
            [ test "merge empties"
                <| assertEqual empty
                    (merge insert insertBoth insert empty empty empty)
            , test "merge singletons in order"
                <| assertEqual (fromList [ ( "u1", [ 1 ] ), ( "u2", [ 2 ] ) ])
                    (merge insert insertBoth insert s1 s2 empty)
            , test "merge singletons out of order"
                <| assertEqual (fromList [ ( "u1", [ 1 ] ), ( "u2", [ 2 ] ) ])
                    (merge insert insertBoth insert s2 s1 empty)
            , test "merge with duplicate key"
                <| assertEqual (fromList [ ( "u2", [ 2, 3 ] ) ])
                    (merge insert insertBoth insert s2 s23 empty)
            , test "partially overlapping"
                <| assertEqual bExpected
                    (merge insert insertBoth insert b1 b2 empty)
            ]
