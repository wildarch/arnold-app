module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Database exposing (NewTransaction, PointTotal, Transaction, TransactionChange(..), createTransaction, pointTotalChange, transactionChange)
import Html exposing (Html, button, div, h1, img, input, li, text, ul)
import Html.Attributes exposing (id, src, type_)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Time



---- MODEL ----


type alias Model =
    { transactions : List Transaction
    , totals : List PointTotal
    }


init : ( Model, Cmd Msg )
init =
    ( { transactions = [], totals = [] }, Cmd.none )



---- UPDATE ----


type Msg
    = CreateTransaction NewTransaction
    | TransactionChange (Result Decode.Error TransactionChange)
    | PointTotalChange (Result Decode.Error (List PointTotal))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TransactionChange res ->
            case res of
                Ok change ->
                    ( { model | transactions = applyChange change model.transactions }, Cmd.none )

                Err e ->
                    let
                        a =
                            Debug.log "WARN: failed to parse change message:" e
                    in
                    ( model, Cmd.none )

        PointTotalChange res ->
            case res of
                Ok totals ->
                    ( { model | totals = totals }, Cmd.none )

                Err e ->
                    let
                        a =
                            Debug.log "WARN: failed to parse point total message:" e
                    in
                    ( model, Cmd.none )

        CreateTransaction trans ->
            ( model, createTransaction trans )


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


fileInputId : String
fileInputId =
    "file_input"


view : Model -> Html Msg
view model =
    div []
        [ img [ src "/logo.svg" ] []
        , h1 [] [ text "Your Elm App is working!" ]
        , viewTransactions model.transactions
        , viewAddTransaction
        , input [ type_ "file", id fileInputId ] []
        ]


viewTransactions : List Transaction -> Html Msg
viewTransactions transactions =
    let
        mapper t =
            li [] [ text <| String.fromInt t.points ++ " points from " ++ t.from ++ " to " ++ t.to ]
    in
    ul [] <| List.map mapper transactions


viewAddTransaction : Html Msg
viewAddTransaction =
    button
        [ onClick <|
            CreateTransaction
                { from = "daan"
                , to = "frits"
                , points = 1000
                , description = "Test desc."
                , mediaId = Just fileInputId
                , time = Time.millisToPosix 0
                }
        ]
        [ text "Add transaction" ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always <| Sub.batch [ transactionChange TransactionChange, pointTotalChange PointTotalChange ]
        }
