# META TCL/TK prompt plugin
# META DESCRIPTION enables a wee Tcl/Tk cmdline within the Pd-console
# META AUTHOR IOhannes m zm�lnig <zmoelnig@umlaeute.mur.at>, Hans-Christoph Steiner <hans@eds.org>
# META VERSION 0.1

package require pdwindow 0.1

## first check if the Pd-runtime provides a tcl_entry (and use it)
if {[catch ::pdwindow::create_tcl_entry errorname]} {

## if that fails, we need to provide our own (code shamelessly taken from Pd-0.46)

namespace eval ::tclprompt:: {
    variable tclentry {}
    variable tclentry_history {"console show"}
    variable history_position 0
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

    bind .pdwindow.text <Key-Tab> "puts tclprompt; focus .pdwindow.tclprompt.entry; puts bye; break"

    pack .pdwindow.tclprompt
    pack .pdwindow.text
}


::tclprompt::create
}

pdtk_post "loaded tclprompt-plugin\n"
