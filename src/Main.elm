port module Main exposing (main)

import Browser
import Html exposing (Html, button, div, hr, li, text, ul)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)


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
    { id : String
    , name : String
    }


type alias TeamMember =
    { id : String
    , pokemon : Pokemon
    }


type alias BattleTeamMember =
    { id : String
    , living : Bool
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
    | FaintBattleTeamMember BattleTeamMember
    | ReviveBattleTeamMember BattleTeamMember


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveBattleTeamMembers newBattleTeamMembers ->
            ( { battleTeamMembers = newBattleTeamMembers }, Cmd.none )

        FaintBattleTeamMember battleTeamMember ->
            ( model, setBattleTeamMember { battleTeamMember | living = False } )

        ReviveBattleTeamMember battleTeamMember ->
            ( model, setBattleTeamMember { battleTeamMember | living = True } )



-- PORTS


port receiveBattleTeamPokemons : (List BattleTeamMember -> msg) -> Sub msg


port setBattleTeamMember : BattleTeamMember -> Cmd msg



-- SUBSCRIPTIONS


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
    li
        [ style "text-decoration-line"
            (if battleTeamMember.living then
                "none"

             else
                "line-through"
            )
        ]
        [ text battleTeamMember.teamMember.pokemon.name ]


battleTeamMembersControlList : List BattleTeamMember -> Html Msg
battleTeamMembersControlList battleTeamMembers =
    ul
        []
        (List.map battleTeamMembersControlListItem battleTeamMembers)


battleTeamMembersControlListItem : BattleTeamMember -> Html Msg
battleTeamMembersControlListItem battleTeamMember =
    li []
        [ text battleTeamMember.teamMember.pokemon.name
        , button [ onClick (FaintBattleTeamMember battleTeamMember) ] [ text "ひんしにする" ]
        , button [ onClick (ReviveBattleTeamMember battleTeamMember) ] [ text "げんきにする" ]
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
