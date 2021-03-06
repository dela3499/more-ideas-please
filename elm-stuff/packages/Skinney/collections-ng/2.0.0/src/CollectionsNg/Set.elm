module CollectionsNg.Set
    exposing
        ( Set
        , empty
        , singleton
        , insert
        , remove
        , isEmpty
        , member
        , size
        , foldl
        , foldr
        , map
        , filter
        , partition
        , union
        , intersect
        , diff
        , toList
        , fromList
        )

{-| A set of unique values. The values can be any comparable type. This
includes `Int`, `Float`, `Time`, `Char`, `String`, and tuples or lists
of comparable types.

# Sets
@docs Set

# Build
@docs empty, singleton, insert, remove

# Query
@docs isEmpty, member, size

# Combine
@docs union, intersect, diff

# Lists
@docs toList, fromList

# Transform
@docs map, foldl, foldr, filter, partition
-}

import CollectionsNg.Dict as Dict exposing (Dict)


{-| Represents a set of unique values. So `(Set Int)` is a set of integers and
`(Set String)` is a set of strings.
-}
type alias Set comparable =
    Dict comparable ()


{-| Create an empty set.
-}
empty : Set comparable
empty =
    Dict.empty


{-| Create a set with one value.
-}
singleton : comparable -> Set comparable
singleton k =
    Dict.singleton k ()


{-| Insert a value into a set.
-}
insert : comparable -> Set comparable -> Set comparable
insert k d =
    Dict.insert k () d


{-| Remove a value from a set. If the value is not found, no changes are made.
-}
remove : comparable -> Set comparable -> Set comparable
remove k d =
    Dict.remove k d


{-| Determine if a set is empty.
-}
isEmpty : Set comparable -> Bool
isEmpty d =
    Dict.isEmpty d


{-| Determine if a value is in a set.
-}
member : comparable -> Set comparable -> Bool
member k d =
    Dict.member k d


{-| Determine the number of elements in a set.
-}
size : Set comparable -> Int
size d =
    Dict.size d


{-| Get the union of two sets. Keep all values.
-}
union : Set comparable -> Set comparable -> Set comparable
union d1 d2 =
    Dict.union d1 d2


{-| Get the intersection of two sets. Keeps values that appear in both sets.
-}
intersect : Set comparable -> Set comparable -> Set comparable
intersect d1 d2 =
    Dict.intersect d1 d2


{-| Get the difference between the first set and the second. Keeps values
that do not appear in the second set.
-}
diff : Set comparable -> Set comparable -> Set comparable
diff d1 d2 =
    Dict.diff d1 d2


{-| Convert a set into a list, sorted from lowest to highest.
-}
toList : Set comparable -> List comparable
toList d =
    Dict.keys d


{-| Convert a list into a set, removing any duplicates.
-}
fromList : List comparable -> Set comparable
fromList xs =
    List.foldl insert empty xs


{-| Fold over the values in a set, in order from lowest to highest.
-}
foldl : (comparable -> b -> b) -> b -> Set comparable -> b
foldl f b d =
    Dict.foldr (\k _ b -> f k b) b d


{-| Fold over the values in a set, in order from highest to lowest.
-}
foldr : (comparable -> b -> b) -> b -> Set comparable -> b
foldr f b d =
    Dict.foldr (\k _ b -> f k b) b d


{-| Map a function onto a set, creating a new set with no duplicates.
-}
map : (comparable -> comparable') -> Set comparable -> Set comparable'
map f s =
    fromList (List.map f (toList s))


{-| Create a new set consisting only of elements which satisfy a predicate.
-}
filter : (comparable -> Bool) -> Set comparable -> Set comparable
filter p d =
    Dict.filter (\k _ -> p k) d


{-| Create two new sets; the first consisting of elements which satisfy a
predicate, the second consisting of elements which do not.
-}
partition : (comparable -> Bool) -> Set comparable -> ( Set comparable, Set comparable )
partition p d =
    Dict.partition (\k _ -> p k) d
