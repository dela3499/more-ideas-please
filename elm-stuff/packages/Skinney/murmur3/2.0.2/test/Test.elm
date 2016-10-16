module Test.Hash exposing (main)

import ElmTest exposing (..)
import Murmur3


hashFn : a -> Int
hashFn =
    toString >> Murmur3.hashString 63476


tests : Test
tests =
    suite "Hashing"
        [ test "int" <| assertEqual 1992578978 <| hashFn -102433675
        , test "float" <| assertEqual 335970363 <| hashFn 4.32
        , test "rec" <| assertEqual 3455049611 <| hashFn { name = "Robin", age = "27", male = True }
        , test "tuple" <| assertEqual 12752532 <| hashFn ( "Robin", 27, True )
        , test "ls" <| assertEqual 4202619459 <| hashFn [1..6]
        , test "bool" <| assertEqual 108766572 <| hashFn False
        ]


main =
    runSuite tests
