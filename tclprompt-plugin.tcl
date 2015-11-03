# META TCL/TK prompt plugin
# META DESCRIPTION enables a wee Tcl/Tk cmdline within the Pd-console
# META AUTHOR IOhannes m zmölnig <zmoelnig@umlaeute.mur.at>, Hans-Christoph Steiner <hans@eds.org>
# META VERSION 0.1

package require pdwindow 0.1
namespace eval ::tclprompt:: { }
## first check if the Pd-runtime provides a tcl_entry (and use it)
if {[catch ::pdwindow::create_tcl_entry errorname]} {

    ## if that fails, we need to provide our own (code shamelessly taken from Pd-0.46)

    namespace eval ::tclprompt:: {
	variable tclentry {}
	variable tclentry_history {"console show"}
	variable history_position 0
	variable show 1
    }

    proc ::tclprompt::eval_tclentry {} {
	variable tclentry
	variable tclentry_history
	variable history_position 0
	if {$tclentry eq ""} {return} ;# no need to do anything if empty
	if {[catch {uplevel #0 $tclentry} errorname]} {
	    global errorInfo
	    switch -regexp -- $errorname {
		"missing close-brace" {
		    ::pdwindow::error [concat [_ "(Tcl) MISSING CLOSE-BRACE '\}': "] $errorInfo]\n
		} "missing close-bracket" {
		    ::pdwindow::error [concat [_ "(Tcl) MISSING CLOSE-BRACKET '\]': "] $errorInfo]\n
		} "^invalid command name" {
		    ::pdwindow::error [concat [_ "(Tcl) INVALID COMMAND NAME: "] $errorInfo]\n
		} default {
		    ::pdwindow::error [concat [_ "(Tcl) UNHANDLED ERROR: "] $errorInfo]\n
		}
	    }
	}
	lappend tclentry_history $tclentry
	set tclentry {}
    }


    proc ::tclprompt::get_history {direction} {
	variable tclentry_history
	variable history_position

	incr history_position $direction
	if {$history_position < 0} {set history_position 0}
	if {$history_position > [llength $tclentry_history]} {
	    set history_position [llength $tclentry_history]
	}
	.pdwindow.tclprompt.entry delete 0 end
	.pdwindow.tclprompt.entry insert 0 \
	    [lindex $tclentry_history end-[expr $history_position - 1]]
    }


    proc ::tclprompt::validate_tcl {} {
	variable tclentry
	if {[info complete $tclentry]} {
	    .pdwindow.tclprompt.entry configure -background "white"
	} else {
	    .pdwindow.tclprompt.entry configure -background "#FFF0F0"
	}
    }

    #--create tcl entry-----------------------------------------------------------#

    proc ::tclprompt::create {} {
	# Tcl entry box frame
	frame .pdwindow.tclprompt -borderwidth 0
	pack .pdwindow.tclprompt -side bottom -fill x -before .pdwindow.text
	label .pdwindow.tclprompt.label -text [_ "Tcl:"] -anchor e
	pack .pdwindow.tclprompt.label -side left
	entry .pdwindow.tclprompt.entry -width 200 \
	    -exportselection 1 -insertwidth 2 -insertbackground blue \
	    -textvariable ::tclprompt::tclentry -font {$::font_family -12}
	pack .pdwindow.tclprompt.entry -side left -fill x

	# bindings for the Tcl entry widget
	bind .pdwindow.tclprompt.entry <$::modifier-Key-a> "%W selection range 0 end; break"
	bind .pdwindow.tclprompt.entry <Return> "::tclprompt::eval_tclentry"
	bind .pdwindow.tclprompt.entry <Up>     "::tclprompt::get_history 1"
	bind .pdwindow.tclprompt.entry <Down>   "::tclprompt::get_history -1"
	bind .pdwindow.tclprompt.entry <KeyRelease> +"::tclprompt::validate_tcl"

	bind .pdwindow.text <Key-Tab> "focus .pdwindow.tclprompt.entry; break"
	#    pack .pdwindow.tclprompt
    }

    proc ::tclprompt::destroy {} {
	::destroy .pdwindow.tclprompt
    }

    set mymenu .menubar.help
    $mymenu add separator
    $mymenu add check -label [_ "Tcl prompt"] -variable ::tclprompt::show \
        -command {::tclprompt::toggle $::tclprompt::show}

# bind all <$::modifier-Key-s> {::deken::open_helpbrowser .helpbrowser2}

    ::tclprompt::create


} else {
    puts "built-in TclPrompt"
    proc ::tclprompt::create {} {}
    proc ::tclprompt::destroy {} {
	# actually we *can* destroy it, but we cannot re-create it
	::pdwindow::error "cannot destroy built-in TclPrompt"
    }
}

proc ::tclprompt::toggle {state} {
    if { $state } { ::tclprompt::create } { ::tclprompt::destroy }
}
proc ::tclprompt::test {} {
    after 1000 ::tclprompt::create
    ::tclprompt::destroy
}
pdtk_post "loaded tclprompt-plugin\n"
