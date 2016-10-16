module Types exposing (..)

import Set exposing (Set)
import Dict exposing (Dict)


type alias Model = 
  { lists: Dict String (List String)
  , selected: Set String
  , shuffle: Bool
  }


type Msg
  = ToggleSelected String
  | ToggleShuffle