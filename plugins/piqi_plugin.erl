-module(piqi_plugin).

-export([pre_compile/2]).

pre_compile(Config, AppFile) ->
    case is_explicit_plugin(Config) of
        true ->
            lists:foreach(
                fun(Defn) -> run_piqic(Config, Defn) end,
                rebar_config:get_local(Config, piqi_plugin, [])
            );
        false ->
            ok
    end.

run_piqic(Config, {KindOf, File}) ->
    run_piqic(Config, {KindOf, File, []});

run_piqic(Config, {KindOf, File, Opts}) ->
    PiqiArgs = case proplists:get_value("-C", Opts) of
        undefined ->
            ["-C", "src" | Opts];
        _ ->
            Opts
    end ++ [File],
    PiqiArgs2 = figure_deps(Config, PiqiArgs),
    rebar_log:log(debug, "Executing ~p: ~p~n", [KindOf, PiqiArgs2]),
    case piqic_erlang:piqic_erlang(KindOf, PiqiArgs2) of
        ok ->
            ok;
        {error, ErrorStr} ->
            rebar_log:log(error, ErrorStr, []),
            rebar_utils:delayed_halt(1)
    end.


%%% ============================================================================
%%% Stuff copied from rebar_deps.erl
%%% ============================================================================

get_shared_deps_dir(Config, Default) ->
    rebar_config:get_xconf(Config, deps_dir, Default).

get_deps_dir(Config) ->
    get_deps_dir(Config, "").

get_deps_dir(Config, App) ->
    BaseDir = rebar_config:get_xconf(Config, base_dir, []),
    DepsDir = get_shared_deps_dir(Config, "deps"),
    {true, filename:join([BaseDir, DepsDir, App])}.

%%% ============================================================================
%%% Random helpers
%%% ============================================================================

is_explicit_plugin(Config) ->
    lists:member(?MODULE,
        lists:flatten(rebar_config:get_local(Config, plugins, []))).

%% @doc Given a list, replaces items like this:
%% [deps_dir, AnyList] with
%% DepsDir "/" AnyList
figure_deps(Config, PiqiArgs) ->
    {true, DepsDir} = get_deps_dir(Config),
    {Hrls, Args2} = lists:foldl(fun
            ({incl_dep, App, PiqiMod}, {Hrls, Acc}) ->
                InclHrl = piqic:erlname(piqic:basename(PiqiMod)),
                Path = [DepsDir, atom_to_list(App), filename:dirname(PiqiMod)],
                {
                    [InclHrl | Hrls],
                    [filename:join(Path), "-I" | Acc]
                };
            (X, {Hrls, Acc}) when is_list(X) ->
                {Hrls, [X | Acc]}
        end,
        {[], []},
        PiqiArgs
    ),
    io:format(standard_error, "HRLs: ~p~n", [Hrls]),
    lists:reverse(Args2).
