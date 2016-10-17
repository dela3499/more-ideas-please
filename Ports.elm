port module Ports exposing (..)


port randomSeed : (Int -> msg) -> Sub msg
port clearField : String -> Cmd msg 
port setInputValue : (String, String) -> Cmd msg 