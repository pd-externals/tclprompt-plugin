interactive Tcl/Tk prompt
===

When developing GUI-plugins (or debugging Pd) it often helps
to have a little interactive Tcl/Tk prompt within Pd.

This plugin enables one for you.

For Pd versions that come with their own implementation of a TclPrompt
(that's Pd-0.43..0.46) it will simply enable that one.
For newer versions of Pd that lack a built-in TclPrompt, the plugin provides one.

## Installing
simply copy the [tclprompt-plugin.tcl](https://raw.githubusercontent.com/pure-data/tclprompt-plugin/master/tclprompt-plugin.tcl) into your Pd searchpath.

## AUTHORS

- IOhannes m zmölnig
- Hans-Christoph Steiner
