-module('_').

-export([to_hex/1]).
-export([from_hex/1]).
-export([discharge/2]).
-export([discharge/3]).
-export([reverse/1]).

-export([position/2]).

-export([trim/1]).
-export([trim/2]).
-export([trim/3]).

-export([join/2]).
-export([apply/2]).

-export([app_get_env/2]).
-export([app_get_env/3]).

to_hex(D) when is_binary(D) ->
	<< <<(to16(X))/integer>> || <<X:4>> <= D >>.
to16(B) when B >= 0, B =< 9 -> $0 + B;
to16(B) when B < 16 -> B rem 10 + $a.

from_hex(D) when is_binary(D) ->
	<< <<(from16(X, Y))/integer>> || <<X:8, Y:8>> <= D >>.
from16(A, B) -> 16 * from16(A) + from16(B).
from16(A) when A >= $0, A =< $9 -> A - $0;
from16(A) when A >= $a, A =< $f -> A - $a + 10;
from16(A) when A >= $A, A =< $F -> A - $A + 10.

discharge(Len, Data) when Len > 0, is_binary(Data)-> discharge(Len, <<" ">>, Data).
discharge(Len, Separator, Data) when Len > 0, is_binary(Data) -> discharge(Len, Separator, Data, <<>>).
discharge(Len, Separator, Data, Result) when Len > 0, byte_size(Data) > Len ->
	<<D:Len/binary, Rest/binary>> = Data,
	discharge(Len, Separator, Rest, <<Result/binary, D/binary, Separator/binary>>);
discharge(_, Separator, Data, Result) -> <<Result/binary, Separator/binary, Data/binary>>.

position(E, Data) when is_list(Data); is_binary(Data) -> position(E, Data, 1).

position(E, [E | _], N) -> N;
position(E, [_ | T], N) -> position(E, T, N + 1);
position(_, [], _) -> 0;
position(E, <<E, _/binary>>, N) -> N;
position(E, <<_, Rest/binary>>, N) -> position(E, Rest, N + 1);
position(_, <<>>, _) -> 0.

trim(Data) when is_binary(Data); is_list(Data) ->
	trim(Data, <<" \t\r\n">>).

trim(Data, Chars) when is_binary(Data); is_list(Data) ->
	D1 = trim(left, Data, Chars),
	trim(right, D1, Chars).

trim(left, [Char | Rest] = Data, Chars) ->
	case position(Char, Chars) of
		0 -> Data;
		_ -> trim(left, Rest, Chars)
	end;
trim(left, <<Char, Rest/binary>> = Data, Chars) ->
	case position(Char, Chars) of
		0 -> Data;
		_ -> trim(left, Rest, Chars)
	end;
trim(right, Data, Chars) ->
	reverse(trim(left, reverse(Data), Chars));
trim(left, Data, _) when Data =:= []; Data =:= <<>> -> Data.

reverse(Data) when is_binary(Data) ->
	L = bit_size(Data),
	<<I:L/big-integer>> = Data,
	<<I:L/little-integer>>;
reverse(Data) when is_list(Data) ->
	lists:reverse(Data).

join([Str | _] = Strings, Separator) when is_binary(Str)->
  BinSeparator = case is_binary(Separator) of
                   true -> Separator;
                   false -> list_to_binary(Separator)
                 end,
  join_binary(Strings, BinSeparator, <<>>);
join(Strings, Separator) ->
  join_list(Strings, Separator, []).

join_binary([Str | Strings], Sep, Res) ->
  NewRes = case Res of
             <<>> -> Str;
             R -> <<R/binary, Sep/binary, Str/binary>>
           end,
  join_binary(Strings, Sep, NewRes);
join_binary([], _Sep, Res) ->
  Res.

join_list([Str | Strings], Sep, Res) ->
  join_list(Strings, Sep, [Str, Sep | Res]);
join_list([], Sep, Res) when Res =/= [] ->
  [Sep | Res1] = lists:reverse(Res),
  lists:flatten(Res1);
join_list([], _, []) ->
  [].

apply({Mod, Fun}, Args) ->
  erlang:apply(Mod, Fun, Args);
apply(Fun, Args) ->
  erlang:apply(Fun, Args).

app_get_env(Key, Default) ->
  {ok, App} = application:get_application(),
  app_get_env(App, Key, Default).

app_get_env(App, Key, Default) ->
  case application:get_env(App, Key) of
    undefined -> Default;
    {ok, Val} -> Val
  end.
