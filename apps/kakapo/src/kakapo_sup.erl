-module(kakapo_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init(_Args) ->
    RestartStrategy = one_for_one,
    MaxRestarts = 1000,
    MaxSecondsBetweenRestarts = 3600,

    SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},

    Dispatch = cowboy_router:compile([
                                     %% {HostMatch, list({PathMatch, Handler, Opts})}
                                     {'_', [{'_', kakapo_route_handler, []}]}
                                     ]),

    ListenPort = list_to_integer(os:getenv("PORT")),

    ChildSpecs = [ranch:child_spec(kakapo_mesh_cowboy, 100,
                                   ranch_tcp, [{port, ListenPort}],
                                   cowboy_protocol, [{env, [{dispatch, Dispatch}]}])],

    {ok, {SupFlags, ChildSpecs}}.

