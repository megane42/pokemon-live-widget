port module Main exposing (main)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type alias Model =
    Int


init : () -> ( Model, Cmd Msg )
init _ =
    ( 0, Cmd.none )


type Msg
    = Increment
    | Decrement
    | ReceiveBattleTeamPokemons Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( model + 1, Cmd.none )

        Decrement ->
            ( model - 1, Cmd.none )

        ReceiveBattleTeamPokemons _ ->
            ( model, Cmd.none )


port receiveBattleTeamPokemons : (Int -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions _ =
    receiveBattleTeamPokemons ReceiveBattleTeamPokemons


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Increment ] [ text "+" ]
        , text <| "Count is: " ++ String.fromInt model
        , button [ onClick Decrement ] [ text "-" ]
        ]
