module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Database exposing (Transaction, TransactionChange(..), transactionChange)
import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src)
import Json.Decode as Decode



---- MODEL ----


type alias Model =
    { transactions : List Transaction }


init : ( Model, Cmd Msg )
init =
    ( { transactions = [] }, Cmd.none )



---- UPDATE ----


type Msg
    = Change (Result Decode.Error TransactionChange)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Change res ->
            case res of
                Ok change ->
                    ( { model | transactions = applyChange change model.transactions }, Cmd.none )

                Err e ->
                    let
                        a =
                            Debug.log "WARN: failed to parse change message:" e
                    in
                    ( model, Cmd.none )


applyChange : TransactionChange -> List Transaction -> List Transaction
applyChange change transactions =
    case change of
        Deleted id ->
            List.filter (\x -> x.id /= id) transactions

        Upserted new ->
            if List.any (\x -> x.id == new.id) transactions then
                List.map
                    (\x ->
                        if x.id == new.id then
                            new

                        else
                            x
                    )
                    transactions

            else
                transactions ++ [ new ]



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ img [ src "/logo.svg" ] []
        , h1 [] [ text "Your Elm App is working!" ]
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always <| transactionChange Change
        }
