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
    { battleTeamMembers : List BattleTeamMember
    , teamMembers : List TeamMember
    , pokemons : List Pokemon
    , pickIndex : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { battleTeamMembers = []
      , teamMembers = []
      , pokemons = []
      , pickIndex = 1
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = GetBattleTeamMembers (List BattleTeamMember)
    | GetTeamMembers (List TeamMember)
    | GetPokemons (List Pokemon)
    | FaintBattleTeamMember BattleTeamMember
    | ReviveBattleTeamMember BattleTeamMember
    | PickTeamMemberAsBattleTeamMember TeamMember


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetBattleTeamMembers newBattleTeamMembers ->
            ( { model | battleTeamMembers = newBattleTeamMembers }, Cmd.none )

        GetTeamMembers newTeamMembers ->
            ( { model | teamMembers = newTeamMembers }, Cmd.none )

        GetPokemons newPokemons ->
            ( { model | pokemons = newPokemons }, Cmd.none )

        FaintBattleTeamMember battleTeamMember ->
            ( model, setBattleTeamMember { battleTeamMember | living = False } )

        ReviveBattleTeamMember battleTeamMember ->
            ( model, setBattleTeamMember { battleTeamMember | living = True } )

        PickTeamMemberAsBattleTeamMember teamMember ->
            ( { model | pickIndex = model.pickIndex + 1 }, setBattleTeamMember (BattleTeamMember "__RANDOM_ID__" True model.pickIndex teamMember) )



-- PORTS


port getBattleTeamMembers : (List BattleTeamMember -> msg) -> Sub msg


port getTeamMembers : (List TeamMember -> msg) -> Sub msg


port getPokemons : (List Pokemon -> msg) -> Sub msg


port setBattleTeamMember : BattleTeamMember -> Cmd msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ getBattleTeamMembers GetBattleTeamMembers
        , getTeamMembers GetTeamMembers
        , getPokemons GetPokemons
        ]



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


teamMembersControlList : List TeamMember -> Html Msg
teamMembersControlList teamMembers =
    ul
        []
        (List.map teamMembersControlListItem teamMembers)


teamMembersControlListItem : TeamMember -> Html Msg
teamMembersControlListItem teamMember =
    li []
        [ text teamMember.pokemon.name
        , button [ onClick (PickTeamMemberAsBattleTeamMember teamMember) ] [ text "選出する" ]
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
        , hr [] []
        , div []
            [ teamMembersControlList model.teamMembers
            ]
        ]
