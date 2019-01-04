port module Database exposing
    ( NewTransaction
    , PointTotal
    , Transaction
    , TransactionChange(..)
    , Uuid
    , createTransaction
    , pointTotalChange
    , transactionChange
    )

import Json.Decode as Decode exposing (Decoder, int, string)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as E
import Time


type alias Uuid =
    String


uuidDecode : Decoder Uuid
uuidDecode =
    string


type alias Blob =
    String


blobDecode : Decoder Blob
blobDecode =
    string


type alias Transaction =
    { id : Uuid
    , rev : Uuid
    , from : Uuid
    , to : Uuid
    , points : Int
    , description : String
    , time : Time.Posix
    , media : Maybe Blob
    }


type TransactionChange
    = Upserted Transaction
    | Deleted Uuid


transactionDecoder : Decoder Transaction
transactionDecoder =
    Decode.succeed Transaction
        |> required "_id" uuidDecode
        |> required "_rev" uuidDecode
        |> required "from" uuidDecode
        |> required "to" uuidDecode
        |> required "points" int
        |> required "description" string
        |> required "time" (Decode.map Time.millisToPosix int)
        |> optional "media" (Decode.map Just blobDecode) Nothing


deletedDecoder : Decoder Uuid
deletedDecoder =
    Decode.at [ "deleted", "id" ] uuidDecode


upsertedDecoder : Decoder Transaction
upsertedDecoder =
    Decode.at [ "upserted" ] transactionDecoder


transactionChangeDecoder : Decoder TransactionChange
transactionChangeDecoder =
    Decode.oneOf
        [ Decode.map Upserted upsertedDecoder
        , Decode.map Deleted deletedDecoder
        ]


port transactionChangeInternal : (E.Value -> msg) -> Sub msg


transactionChange : (Result Decode.Error TransactionChange -> msg) -> Sub msg
transactionChange mapper =
    transactionChangeInternal (mapper << Decode.decodeValue transactionChangeDecoder)


type alias PointTotal =
    { user : Uuid
    , points : Int
    }


port pointTotalChangeInternal : (E.Value -> msg) -> Sub msg


pointTotalDecoder : Decoder PointTotal
pointTotalDecoder =
    Decode.succeed PointTotal
        |> required "key" uuidDecode
        |> required "value" int


pointTotalChange : (Result Decode.Error (List PointTotal) -> msg) -> Sub msg
pointTotalChange mapper =
    pointTotalChangeInternal (mapper << (Decode.decodeValue <| Decode.list pointTotalDecoder))


type alias NewTransaction =
    { from : Uuid
    , to : Uuid
    , points : Int
    , mediaId : Maybe String
    , description : String
    , time : Time.Posix
    }


newTransactionEncode : NewTransaction -> E.Value
newTransactionEncode t =
    E.object
        [ ( "from", E.string t.from )
        , ( "to", E.string t.to )
        , ( "points", E.int t.points )
        , ( "media_id", encodeNullable E.string t.mediaId )
        , ( "description", E.string t.description )
        , ( "time", E.int <| Time.posixToMillis t.time )
        ]


encodeNullable : (a -> E.Value) -> Maybe a -> E.Value
encodeNullable mapper val =
    val
        |> Maybe.map mapper
        |> Maybe.withDefault E.null


createTransaction : NewTransaction -> Cmd msg
createTransaction =
    createTransactionInternal << newTransactionEncode


port createTransactionInternal : E.Value -> Cmd msg
