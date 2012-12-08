What?
=====

A quick script to show the statistics for all modules that belong
to a specific user on the Puppet Forge

It supports a simple text rendering format and a Graphite output
ready to be piped to something like netcat

Usage?
------

Default text format:

    $ ./pfmodstats.rb --user ripienaar
    Modules for user: ripienaar

    Module         |Count
    ---------------+-----
    concat         |2265
    catalog_diff   |38
    catalog_print  |29

Graphite render format:

    $ ./pfmodstats.rb --user ripienaar --format graphite --graphite-prefix modules
    modules.concat 2265 1352923155
    modules.catalog_diff 38 1352923155
    modules.catalog_print 29 1352923155

To send this to your graphite server just pipe to netcat:

    $ ./pfmodstats.rb --user ripienaar --format graphite --graphite-prefix modules | nc graphite 2003

Background?
-----------

The Puppet Forge has recently been rewritten to be based on a rich
API that can be accessed by your own scripts, this script uses the
_httparty_ gem to access this REST API.

There is a lot of scope for improvement to this script and more
stats that can be pulled so this is probably just a starting point

The API is documented at http://forgeapi.puppetlabs.com/apidoc
and at present is not final so is subject to some changes, this
should stabalize around early 2013

Contact?
--------

R.I.Pienaar / rip@devco.net / @ripienaar / http://devco.net/
