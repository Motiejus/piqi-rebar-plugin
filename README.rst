Piqi rebar plugin
=================

Warning
-------

This is work in progress and you shouldn't use this yet, unless you want to
experiment and give feedback. API will definitely change. Use Makefiles.

About
-----

This is a rebar plugin to generate rebar artefacts. Example usage of
``rebar.config``::

    {deps,[
            {piqi_plugin, "0.0.1",
                {git, "git://github.com/Motiejus/piqi-rebar-plugin.git",
                    {tag, "0.0.1"}}}
    ]}.

    {plugins, [piqi_plugin]}.
    {piqi_plugin, [
            {piqic_erlang, "priv/labels-defs.piqi", [
                    "-I", "priv",
                    {incl_dep, storagetypes, "priv/storagetypes.piqi"},
                    {incl_dep, gidless_core, "priv/gidless-common.piqi"}
                ]
            },
            {piqic_erlang_rpc, "priv/labels-rpc.piqi", [
                    "-I", "priv",
                    {incl_dep, storagetypes, "priv/storagetypes.piqi"},
                    {incl_dep, gidless_core, "priv/gidless-common.piqi"}
                ]
            }
        ]
    }.


This is `work-in-progress`_, because better support from piqic-erlang is
required.

Currently works
---------------

1. Simple compilation which does not ``.import a-module``.
2. Rebar dependency handling (must be prettier though).

TODO
----

1. ``clean`` target.
2. properly import HRLs of dependencies (in case of ``.import a-module``).

Special requirements
--------------------

Requires rebar with patch `252b31f2a4b`_.

Plugin philosophy (and how it works)
------------------------------------

It emulates ``piqic-erlang`` or ``piqic-erlang-rpc`` with the arguments provided
in the options line. It tries to be just a small step ahead of Makefiles and the
plugin is intended to be as thin as possible.

Some help from piqic-erlang and rebar is needed to make dynamic directories
work, but we are working hard making it clean.

.. _`work-in-progress`: https://groups.google.com/forum/?fromgroups#!topic/piqi/qXRnQxS53HQ
.. _252b31f2a4b: https://github.com/rebar/rebar/commit/252b31f2a4b95670ef75a6a712788af977e869e9
