%%%% -*- Mode: Prolog -*-

%%%% Manan Mohammad Ali  817205
%%%% Stranieri Francesco 816551



%%%%----------------------------------------------------------------------------
%%%% json_parse

json_parse(JSONString, Object) :-
    is_object(JSONString, More, Object),
    !,
    skip_whitespaces(More, MoreWW),
    MoreWW = [].    

json_parse(JSONString, Object) :-
    is_array(JSONString, More, Object),
    !,
    skip_whitespaces(More, MoreWW),
    MoreWW = [].

json_parse(JSONString, Object) :-
    atom_codes(JSONString, Codes),
    is_object(Codes, More, Object),
    !,
    skip_whitespaces(More, MoreWW),
    MoreWW = [].    

json_parse(JSONString, Object) :-
    atom_codes(JSONString, Codes),
    is_array(Codes, More, Object),
    !,
    skip_whitespaces(More, MoreWW),
    MoreWW = [].

%%%%----------------------------------------------------------------------------



%%%%----------------------------------------------------------------------------
%%%% is_object

is_object(Codes, MoreObject, Object) :-
    skip_whitespaces(Codes, [Head, Tail]),
    is_leftCB(Head),
    is_rightCB(Tail),
    !,
    Object = json_obj([]),
    MoreObject = [].

is_object(Codes, MoreObject, Object) :-
    skip_whitespaces(Codes, [Head | Tail]),
    is_leftCB(Head),
    is_member(Tail, [Head_2 | Tail_2], TmpObject),
    is_rightCB(Head_2),
    !,
    Object = json_obj(TmpObject),
    MoreObject = Tail_2.

%%%%----------------------------------------------------------------------------



%%%%----------------------------------------------------------------------------
%%%% is_member

is_member(Member, MoreMember, Object) :-
    is_member(Member, [], MoreMember, Object).

is_member(Member, TmpDone, MoreMember, Object) :-
    is_pair(Member, Tmp_MoreMember, TmpObject),
    append(TmpDone, [TmpObject], Done),
    skip_whitespaces(Tmp_MoreMember, [Head_Tmp_MoreMember | Tail_Tmp_MoreMember]),
    is_comma(Head_Tmp_MoreMember),
    !,
    is_member(Tail_Tmp_MoreMember, Done, MoreMember, Object).

is_member(Member, TmpDone, MoreMember, Object) :-
    is_pair(Member, Tmp_MoreMember, TmpObject),
    append(TmpDone, [TmpObject], Done),
    skip_whitespaces(Tmp_MoreMember, [Head_Tmp_MoreMember | Tail_Tmp_MoreMember]),
    !,
    Object = Done,
    MoreMember = [Head_Tmp_MoreMember | Tail_Tmp_MoreMember].

%%%%----------------------------------------------------------------------------



%%%%----------------------------------------------------------------------------
%%%% is_pair

is_pair(Pair, MorePair, Object) :-
    skip_whitespaces(Pair, PairWW),
    is_stringDQ(PairWW, Tmp_MorePair, Object_1),
    !,
    skip_whitespaces(Tmp_MorePair, [Head_Tmp_MorePair | Tail_Tmp_MorePair]),
    is_colon(Head_Tmp_MorePair),
    is_value(Tail_Tmp_MorePair, MorePair, Object_2),
    Object = (Object_1, Object_2).

is_pair(Pair, MorePair, Object) :-
    skip_whitespaces(Pair, PairWW),
    is_stringSQ(PairWW, Tmp_MorePair, Object_1),
    !,
    skip_whitespaces(Tmp_MorePair, [Head_Tmp_MorePair | Tail_Tmp_MorePair]),
    is_colon(Head_Tmp_MorePair),
    is_value(Tail_Tmp_MorePair, MorePair, Object_2),
    Object = (Object_1, Object_2).

%%%%----------------------------------------------------------------------------



%%%%----------------------------------------------------------------------------
%%%% is_array

is_array(Array, MoreArray, Object) :-
    skip_whitespaces(Array, [Head, Tail]),
    is_leftSB(Head),
    is_rightSB(Tail),
    !,
    Object = json_array([]),
    MoreArray = [].

is_array(Array, MoreArray, Object) :-
    skip_whitespaces(Array, [Head | Tail]),
    is_leftSB(Head),
    is_element(Tail, [Head_2 | Tail_2], TmpObject),
    is_rightSB(Head_2),
    !,
    Object = json_array(TmpObject),
    MoreArray = Tail_2.

%%%%----------------------------------------------------------------------------



%%%% is_element
%%%%----------------------------------------------------------------------------

is_element(Element, MoreElement, Object) :-
    is_element(Element, [], MoreElement, Object).

is_element(Element, TmpDone, MoreElement, Object) :-
    is_value(Element, Tmp_MoreElement, TmpObject),
    append(TmpDone, [TmpObject], Done),
    skip_whitespaces(Tmp_MoreElement, [Head_Tmp_MoreElement | Tail_Tmp_MoreElement]),
    is_comma(Head_Tmp_MoreElement),
    !,
    is_element(Tail_Tmp_MoreElement, Done, MoreElement, Object).

is_element(Element, TmpDone, MoreElement, Object) :-
    is_value(Element, Tmp_MoreElement, TmpObject),
    append(TmpDone, [TmpObject], Done),
    skip_whitespaces(Tmp_MoreElement, [Head_Tmp_MoreElement | Tail_Tmp_MoreElement]),
    not(is_comma(Head_Tmp_MoreElement)),
    !,
    Object = Done,
    MoreElement = [Head_Tmp_MoreElement | Tail_Tmp_MoreElement].

%%%%----------------------------------------------------------------------------



%%%%----------------------------------------------------------------------------
%%%% is_value

is_value(Value, MorePair, Object) :-
    is_stringDQ(Value, MorePair, Object),
    !.

is_value(Value, MorePair, Object) :-
    is_stringSQ(Value, MorePair, Object),
    !.

is_value(Value, MorePair, Object) :-
    is_number(Value, MorePair, Object),
    !.

is_value(Value, MorePair, Object) :-
    is_object(Value, MorePair, Object),
    !.

is_value(Value, MorePair, Object) :-
    is_array(Value, MorePair, Object),
    !.

%%%%----------------------------------------------------------------------------



%%%%----------------------------------------------------------------------------
%%%% is_number

is_number(Number, MorePair, Object) :-
    skip_whitespaces(Number, [Head_Number | Tail_Number]),
    is_digit(Head_Number),
    !,
    is_number(Tail_Number, [Head_Number], MorePair, Object).

is_number(Number, MorePair, Object) :-
    skip_whitespaces(Number, [Head_Number | Tail_Number]),
    is_signum(Head_Number),
    !,
    is_number(Tail_Number, [Head_Number], MorePair, Object).

is_number([Head_Number | Tail_Number], Done, MorePair, Object) :-
    is_digit(Head_Number),
    !,
    append(Done, [Head_Number], TmpDone),
    is_number(Tail_Number, TmpDone, MorePair, Object).

is_number([Head_Number | Tail_Number], Done, MorePair, Object) :-
    is_dot(Head_Number),
    Tail_Number \= [],
    last(Done, Last),
    is_digit(Last),  
    !,               
    append(Done, [Head_Number], TmpDone),
    is_float(Tail_Number, TmpDone, MorePair, Object).

is_number([Head_Number | Tail_Number], Done, MorePair, Object) :-
    not(is_digit(Head_Number)),
    last(Done, Last),
    is_digit(Last),
    !,
    number_codes(Object, Done),
    MorePair = ([Head_Number | Tail_Number]).

%%%%----------------------------------------------------------------------------
%%%% is_float

is_float([Head_Float | Tail_Float], Done, MorePair, Object) :-
    is_digit(Head_Float),
    !,
    append(Done, [Head_Float], TmpDone),
    is_float(Tail_Float, TmpDone, MorePair, Object).

is_float([Head_Float | Tail_Float], Done, MorePair, Object) :-
    not(is_digit(Head_Float)),
    last(Done, Last),
    is_digit(Last),
    !,
    number_codes(Object, Done),
    MorePair = ([Head_Float | Tail_Float]).

%%%%----------------------------------------------------------------------------



%%%%----------------------------------------------------------------------------
%%%% is_string DQ

is_stringDQ(String, MorePair, Object) :-
    skip_whitespaces(String, [Head_String | Tail_String]),
    is_DQ(Head_String),
    is_stringDQ(Tail_String, [], Head_String, MorePair, Object).

is_stringDQ([Head_String | MorePair], Done, Head_String, MorePair, Object) :-
    is_DQ(Head_String),
    !,
    string_codes(Object, Done).

is_stringDQ([Head_String | Tail_String], Done, DQ, MorePair, Object) :-
    not(is_DQ(Head_String)),
    is_ascii(Head_String),
    !,
    append(Done, [Head_String], TmpDone),
    is_stringDQ(Tail_String, TmpDone, DQ, MorePair, Object).

%%%%----------------------------------------------------------------------------



%%%%----------------------------------------------------------------------------
%%%% is_string SQ

is_stringSQ(String, MorePair, Object) :-
    skip_whitespaces(String, [Head_String | Tail_String]),
    is_SQ(Head_String),
    is_stringSQ(Tail_String, [], Head_String, MorePair, Object).

is_stringSQ([Head_String | MorePair], Done, Head_String, MorePair, Object) :-
    is_SQ(Head_String),
    !,
    string_codes(Object, Done).

is_stringSQ([Head_String | Tail_String], Done, SQ, MorePair, Object) :-
    not(is_SQ(Head_String)),
    is_ascii(Head_String),
    !,
    append(Done, [Head_String], TmpDone),
    is_stringSQ(Tail_String, TmpDone, SQ, MorePair, Object).

%%%%----------------------------------------------------------------------------



%%%%----------------------------------------------------------------------------
%%%% json_load

json_load(FileName, JSON) :-
    read_file_to_codes(FileName, Codes, []),
    json_parse(Codes, JSON).

%%%%----------------------------------------------------------------------------



%%%%----------------------------------------------------------------------------
%%%% json_write

json_write(JSON, FileName) :-
    write_object(JSON, [], Codes),
    !,
    string_codes(Result, Codes),
    write_string_to_file(FileName, Result).

json_write(JSON, FileName) :-
    write_array(JSON, [], Codes),
    !,
    string_codes(Result, Codes),
    write_string_to_file(FileName, Result).

write_object(json_obj(Object), Done, Result) :-
    append(Done, [123], TmpDone),
    write_pair(Object, TmpDone, TmpResult),
    append(TmpResult, [125], Result).

write_array(json_array(Array), Done, Result) :-
    append(Done, [91], TmpDone),
    write_values(Array, TmpDone, TmpResult),
    append(TmpResult, [93], Result).

write_values([], [91], Result) :-
    !,
    append([], [91], Result).

write_values([], Done, Result) :-
    !,
    remove_last(Done, Result).

write_values([Head_Values | Tail_Values], Done, Result) :-
    !,
    write_value(Head_Values, Done, TmpDone),
    append(TmpDone, [44], TmpResult),
    write_values(Tail_Values, TmpResult, Result).

write_pair([], [123], Result) :-
    !,
    append([], [123], Result).

write_pair([], Done, Result) :-
    !,
    remove_last(Done, Result).

write_pair([(String, Value) | MorePair], Done, Result) :-
    atom_codes(String, Codes),
    !,
    append([34 | Codes], [34], Tmp_String),
    append(Done, Tmp_String, TmpDone),
    append(TmpDone, [58], TmpPair),
    write_value(Value, TmpPair, TmpResult),
    append(TmpResult, [44], Pair),
    write_pair(MorePair, Pair, Result).

write_value(json_obj(Object), Done, Result) :-
    !,
    write_object(json_obj(Object), Done, Result).

write_value(json_array(Array), Done, Result) :-
    !,
    write_array(json_array(Array), Done, Result).

write_value(String, Done, Result) :-
    string(String),
    !,
    string_codes(String, Codes),
    append([34 | Codes], [34], Tmp_String),
    append(Done, Tmp_String, Result).

write_value(Number, Done, Result) :-
    number_codes(Number, Codes),
    append(Done, Codes, Result).

remove_last(In, Out) :-
    append(Out, [_], In).

write_string_to_file(Filename, Result) :-
    open(Filename, write, Out),
    write(Out, Result),
    close(Out).

%%%%----------------------------------------------------------------------------



%%%%----------------------------------------------------------------------------
%%%% json_get

json_get(Result, [], Result) :-
    !.

json_get(json_obj(List), Field, Result) :-
    Field \= [_ | _],
    !,
    json_get(json_obj(List), [Field], Result).

json_get(json_obj(List), [Field | MoreField], Result) :-
    !,
    find_pair(List, Field, TmpDone),
    json_get(TmpDone, MoreField, Result).

json_get(json_array(List), [Field | MoreField], Result) :-
    !,
    nth0(Field, List, TmpDone),
    json_get(TmpDone, MoreField, Result).

%%%%----------------------------------------------------------------------------



%%%%----------------------------------------------------------------------------
%%%% find_pair

find_pair([Head_List | _], Field, Result) :-
    Head_List = (Field, Result),
    !.

find_pair([Head_List | Tail_List], Field, Result) :-
    Head_List \= (Field, Result),
    !,
    find_pair(Tail_List, Field, Result).

%%%%----------------------------------------------------------------------------



%%%%----------------------------------------------------------------------------
%%%% skip_whitespaces

skip_whitespaces([WS | MoreCodes], Codes_WW) :-
    is_whitespace(WS),
    !,
    skip_whitespaces(MoreCodes, Codes_WW).

skip_whitespaces([C | MoreCodes], [C | MoreCodes]) :-
    !.

skip_whitespaces([], []) :-
    !.

is_whitespace(C) :-
    char_type(C, white) ; char_type(C, newline).

%%%%----------------------------------------------------------------------------

is_leftCB(123).

is_rightCB(125).

is_leftSB(91).

is_rightSB(93).

is_comma(44).

is_colon(58).

is_DQ(34).

is_SQ(39).

is_ascii(C) :-
    char_type(C, ascii).

is_signum(43) :-
    !.

is_signum(45) :-
    !.

is_dot(46).



%%%% end of file -- json-parsing.pl --
