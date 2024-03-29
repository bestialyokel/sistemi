% Fuad Tabba
% cs.auckland.ac.nz AT fuad

-module(bst).
-export([rpcContains/2, rpcInsert/2, rpcDelete/2, rpcDump/1]).
-compile(export_all). % for debugging
-compile(nowarn_export_all).


% To get started:-
% createTree() creates a sample tree
% randCreate(KeyRange) creates a random tree within a certain range
% testTree(KeyRange, Operations) creates and performs a bunch of operations
% on the tree.
% Insert, Delete and Contains should always be correct. Dump is used for
% debugging and can show an inconsistent state if changes are pending. Dump
% must always be correct for a stable tree.
% Node Structure: {Key, PidLeft, PidRight}
% true if the tree contains the Key, false otherwise


rpcContains(_, nil) ->
    alse;
rpcContains(Key, Pid) ->
    Pid ! {contains, Key, self()},
    receive
    Result -> Result
end.


% Insering into an empty (nil) node - spawn a new proccess for the new node
rpcInsert(Key, nil) ->
    spawn(fun() -> nodeState({Key, nil, nil}) end);


% Insering into an existing node - ask its process to deal with it
rpcInsert(Key, Pid) ->
    Pid ! {insert, Key},
    Pid.

% Deleting an empty (nil) node - just results in an empty leaf (not found)


rpcDelete(_, nil) ->
    nil;
% Deleting from an existing node send a request to it

rpcDelete(Key, Pid) ->
    Pid ! {delete, Key},
    Pid.


% For debugging: returns the whole tree

rpcDump(nil) ->
    nil;

rpcDump(Pid) ->
    Pid ! {dump, self()},
    receive
        Tree -> Tree
    end.


% Maintains the state of the node

nodeState(Node) ->
    receive
        {contains, Key, Requester} ->
            contains(Key, Node, Requester),
            nodeState(Node);
        {insert, Key} ->
            insert(Key, Node),
            nodeState(Node);
        {delete, Key} ->
            delete(Key, Node),
            nodeState(Node);
        {node, Requester} ->
            Requester ! Node,
            nodeState(Node);
        {dump, Requester} ->
            dump(Node, Requester),
            nodeState(Node)
    end.


% Get the dump of the subtree
dump(Node, Requester) ->
    if
        nil =:= Node ->
            Requester ! Node;
        true ->
            {Key, PidLeft, PidRight} = Node,
            Requester ! {Key, rpcDump(PidLeft), rpcDump(PidRight)}
    end.


% Check whether the subtree contains the key.
contains(Kfind, {Key, PidLeft, _}, Requester) when Kfind < Key ->
    relayContain(Kfind, PidLeft, Requester);
contains(Kfind, {Key, _, PidRight}, Requester) when Kfind > Key ->
    relayContain(Kfind, PidRight, Requester);
contains(Key, {Key, _, _}, Requester) ->
    Requester ! true;
contains(_, nil, Requester) ->
    Requester ! false.


% Relays the contain request to the next node,
% Or informs the requestor that it's not there if it's a nil node
relayContain(_, nil, Requester) ->
    Requester ! false;
relayContain(Key, NodePid, Requester) ->
    NodePid ! {contains, Key, Requester}.


insert(Knew, {Key, PidLeft, PidRight}) when Knew < Key ->
    {Key, rpcInsert(Knew, PidLeft), PidRight};
insert(Knew, {Key, PidLeft, PidRight}) when Knew > Key ->
    {Key, PidLeft, rpcInsert(Knew, PidRight)};
insert(Key, {Key, PidLeft, PidRight}) ->
    {Key, PidLeft, PidRight};
insert(Key, nil) ->
    {Key, nil, nil}.



delete(Kdel, {Key, PidLeft, PidRight}) when Kdel < Key ->
    {Key, rpcDelete(Kdel, PidLeft), PidRight};
delete(Kdel, {Key, PidLeft, PidRight}) when Kdel > Key ->
    {Key, PidLeft, rpcDelete(Kdel, PidRight)};

delete(Key, {Key, PidLeft, PidRight}) ->
    NodeLeft = getNode(PidLeft),
    NodeRight = getNode(PidRight),
    if
        NodeLeft =:= nil ->
            NodeRight;
        NodeRight =:= nil ->
            NodeLeft;

        true ->
            Kmax = max(NodeLeft),
            rpcDelete(Kmax, PidLeft),
            {Kmax, PidLeft, PidRight}
    end;


% Not found
delete(_, nil) ->
    nil.
% Gets the state of the node from its associated process
getNode(nil) ->
    nil;
% Ask the process for its state then wait for it to respond.
getNode(Pid) ->
    Pid ! {node, self()},
    receive
        Node -> Node
    end.


% returns the biggest key in this subtree
% can't really be parallelized
max({Key, _, PidRight}) ->
    NodeRight = getNode(PidRight),
    if
        NodeRight =:= nil ->
            Key;
    true ->
        max(NodeRight)
    end.


% Create a pre-determined test tree
createTree() ->
    Root = rpcInsert(260, nil),
    rpcInsert(240, Root),
    rpcInsert(140, Root),
    rpcInsert(320, Root),
    rpcInsert(250, Root),
    rpcInsert(170, Root),
    rpcInsert(60, Root),
    rpcInsert(100, Root),
    rpcInsert(20, Root),
    rpcInsert(40, Root),
    rpcInsert(290, Root),
    rpcInsert(280, Root),
    rpcInsert(270, Root),
    rpcInsert(30, Root),
    rpcInsert(265, Root),
    rpcInsert(275, Root),
    rpcInsert(277, Root),
    rpcInsert(278, Root).


% Creates a random tree within the specified range. KeyRange/2 is the root of
% the tree

randCreate(KeyRange) ->
    Kroot = trunc(KeyRange/2),
    Operations = KeyRange,
    Root = rpcInsert(Kroot, nil),
    lists:foreach(fun(_) -> rpcInsert(rand:uniform(KeyRange), Root) end, lists:seq(1, Operations)),
    Root.


% First creates a random tree, then performs randomly selected operations on it
testTree(KeyRange, Operations) ->
    Root = randCreate(KeyRange),
    lists:foreach(fun(_) -> spawn (fun() -> randOperation(Root, KeyRange) end) end, lists:seq(1,Operations)),
    Root.

% Perform a randomly select
randOperation(RootPid, KeyRange) ->
    Op = rand:uniform(3),
    Key = rand:uniform(KeyRange),
    case Op of
        1 -> rpcInsert(Key, RootPid);
        2 -> rpcDelete(Key, RootPid);
        3 -> rpcContains(Key, RootPid)
    end.


myTest(KeyRange, Operations) ->
    T1 = erlang:timestamp(),
    bst:testTree(KeyRange, Operations),
    T2 = erlang:timestamp(),
    Ret = timer:now_diff(T2, T1),
    Ret.


main(Args) ->
    {KeyRange, _} = string:to_integer( lists:nth(1, Args) ),
    {Operations, _} = string:to_integer( lists:nth(2, Args) ),
    Res = myTest(KeyRange, Operations),
    io:write( Res ).


