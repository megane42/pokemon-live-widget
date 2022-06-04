port module Main exposing (main)

import Browser
import Html exposing (Html, div, li, text, ul)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Pokemon =
    { name : String
    }


type alias TeamMember =
    { pokemon : Pokemon
    }


type alias BattleTeamMember =
    { living : Bool
    , order : Int
    , teamMember : TeamMember
    }


type alias Model =
    List BattleTeamMember


init : () -> ( Model, Cmd Msg )
init _ =
    ( [], Cmd.none )



-- UPDATE


type Msg
    = ReceiveBattleTeamMembers (List BattleTeamMember)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveBattleTeamMembers newBattleTeamMember ->
            ( newBattleTeamMember, Cmd.none )



-- SUBSCRIPTIONS


port receiveBattleTeamPokemons : (List BattleTeamMember -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions _ =
    receiveBattleTeamPokemons ReceiveBattleTeamMembers



-- VIEW


battleTeamMembersListItem : BattleTeamMember -> Html msg
battleTeamMembersListItem battleTeamMember =
    li [] [ text battleTeamMember.teamMember.pokemon.name ]


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ ul
                []
                (List.map battleTeamMembersListItem model)
            ]
        ]
