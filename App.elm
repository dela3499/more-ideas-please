module App exposing (..)

import Html exposing (Html, text, div, span, a, img, p, i, input)
import Html.App as Html
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Attributes exposing (..)
import Maybe exposing (withDefault)
import Set exposing (Set)
import Dict exposing (Dict)
import String

import Types exposing (..)
import Util
import View
import Update
import Keyboard
import Time
import Ports
import Random.Pcg
import Time

main = 
  Html.program
    { init = ( initModel, Cmd.none )
    , update = Update.app
    , view = View.app
    , subscriptions = subscriptions
    }


subscriptions: Model -> Sub Msg
subscriptions model = 
  Sub.batch
    [ Keyboard.ups KeyUp
    , Ports.randomSeed ( \int -> SetInitialSeed int )
    , Time.every Time.second SetTime
    ]


initModel: Model
initModel = 
  { lists = 
      Dict.fromList
        [ ("db836197-9767-423c-ab74-13f91d59ff9f", 
            { id = "db836197-9767-423c-ab74-13f91d59ff9f"
            , name = "Places"
            , items = ["home", "work", "school", "pool"]
            , created = 1.0
            }
          )
        , ("647b5514-5b61-41fa-a47c-4df52df7c1a7", 
            { id = "647b5514-5b61-41fa-a47c-4df52df7c1a7"
            , name = "Hobbies"
            , items = ["swimming", "playing guitar", "badminton"]
            , created = 2.0
            }
          )
        , ("a574832d-461f-4a32-b50f-25c597ecd718", 
            { id = "a574832d-461f-4a32-b50f-25c597ecd718"
            , name = "Foods"
            , items = ["burgers", "bacon", "sandwiches", "pizza"]
            , created = 3.0
            }
          )
        , ("af48ee10-c95f-43d4-a9be-4cd4cab3fea9", 
            { id = "af48ee10-c95f-43d4-a9be-4cd4cab3fea9"
            , name = "Companies"
            , items = ["Uber", "Google", "Facebook", "Apple"]
            , created = 4.0
            }
          )
        ]
  , selected = 
      Set.fromList
        [ "db836197-9767-423c-ab74-13f91d59ff9f"
        , "647b5514-5b61-41fa-a47c-4df52df7c1a7"
        ]
  , shuffle = False
  , mode = Editing
  , editList = 
      { id = ""
      , name = ""
      , items = []
      , created = 0.0
      }
  , editItem = ""
  , focus = NoFocus
  , seed = Random.Pcg.initialSeed 123894123097 --replaced on start
  , t = 0.0
  }


