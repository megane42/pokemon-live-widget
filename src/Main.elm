port module Main exposing (main)

import Browser
import Html exposing (Html, button, div, hr, li, text, ul)


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
    { battleTeamMembers : List BattleTeamMember }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { battleTeamMembers = [] }, Cmd.none )



-- UPDATE


type Msg
    = ReceiveBattleTeamMembers (List BattleTeamMember)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveBattleTeamMembers newBattleTeamMembers ->
            ( { battleTeamMembers = newBattleTeamMembers }, Cmd.none )



-- SUBSCRIPTIONS


port receiveBattleTeamPokemons : (List BattleTeamMember -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions _ =
    receiveBattleTeamPokemons ReceiveBattleTeamMembers



-- VIEW


battleTeamMembersDisplayList : List BattleTeamMember -> Html msg
battleTeamMembersDisplayList battleTeamMembers =
    ul
        []
        (List.map battleTeamMembersDisplayListItem battleTeamMembers)


battleTeamMembersDisplayListItem : BattleTeamMember -> Html msg
battleTeamMembersDisplayListItem battleTeamMember =
    li [] [ text battleTeamMember.teamMember.pokemon.name ]


battleTeamMembersControlList : List BattleTeamMember -> Html msg
battleTeamMembersControlList battleTeamMembers =
    ul
        []
        (List.map battleTeamMembersControlListItem battleTeamMembers)


battleTeamMembersControlListItem : BattleTeamMember -> Html msg
battleTeamMembersControlListItem battleTeamMember =
    li []
        [ text battleTeamMember.teamMember.pokemon.name
        , button [] [ text "ひんしにする" ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ battleTeamMembersDisplayList model.battleTeamMembers
            ]
        , hr [] []
        , div []
            [ battleTeamMembersControlList model.battleTeamMembers
            ]
        ]
