/*!
 *
 * Copyright(c) 2013 Uli Fuchs <ufuchs@gmx.com>
 * MIT Licensed
 *
 * [ The true sign of intelligence is not knowledge but imagination. ]
 * [                                             - Albert Einstein - ]
 *
 *
 * Invoke at your Windows console(cmd.exe):
 * 1.concat-scripts.bat
 * 2.cscript //NoLogo app.js
 *
 */

var config = {

    app : {

        downloadDir : '.\\downloads',

        proxy : {
            isActive : false,

            // HttpRequest SetCredentials flags.
            //
            // HTTPREQUEST_PROXYSETTING_DEFAULT   = 0;
            // HTTPREQUEST_PROXYSETTING_PRECONFIG = 0;
            // HTTPREQUEST_PROXYSETTING_DIRECT    = 1;
            // HTTPREQUEST_PROXYSETTING_PROXY     = 2;
            settings : 0,
            server : 'http://178.15.127.98:80',
            bypassList : '*.aucodream.de'
        }

    },

    dependencies : {

        mps : "2.5.4",
        java : "6u45",
        graphviz : "2.32",
        cbmc : "4-4",
        nusmv : "2.5.4",
        yices : "1.0.39"

    },

    install : {

        mps : {
            dir : "",
            patch : "a"
        },

        java : {
            dir : "",
            options : ""
        },


        cliTools : {
            dir : ''
        },

        order : ['mps', 'java', 'graphviz', 'cbmc', 'nusvm', 'yices', 'cygwin']

    },

    packages : {

        mps : {
            uri :       "http://download.jetbrains.com/mps/MPS-{{version}}.zip",
            desc :      "Jetbrains Meta Programming System {{version}}"
        },

        java : {
            uri_x86 :   "http://download.oracle.com/otn-pub/java/jdk/{{version}}-b06/jre-{{version}}-windows-i586.exe",
            uri_amd64 : "http://download.oracle.com/otn-pub/java/jdk/{{version}}-b06/jre-{{version}}-windows-x64.exe",
            desc :      "Java Runtime {{version}}"
        },

        cygwin : {
            uri_x86 :   "http://cygwin.com/setup-x86.exe",
            uri_amd64 : "http://cygwin.com/setup-x86_64.exe",
            desc :      "Unix-like environment and command-line interface for Microsoft Windows"
        },

        ////
        // cliTools
        ////

        graphviz : {
            uri :       "http://www.graphviz.org/pub/graphviz/stable/windows/graphviz-{{version}}.zip",
            desc :      "Graph Visualization Software {{version}}"
        },

        cbmc : {
            uri :       "http://www.cprover.org/cbmc/download/cbmc-{{version}}-win.zip",
            desc :      "Bounded Model Checker for ANSI-C and C++ programs {{version}}"
        },

        nusmv : {
            uri_x86 :   "http://nusmv.fbk.eu/distrib/NuSMV-{{version}}-i386-pc-mingw32.zip",
            uri_amd64 : "http://nusmv.fbk.eu/distrib/NuSMV-{{version}}-x86_64-w64-mingw32.zip",
            desc :      "A New Symbolic Model Checker {{version}}"
        },

        yices : {
            uri_x86 :   "http://yices.csl.sri.com/cgi-bin/yices-newlicense.cgi?file=yices-{{version}}-i686-pc-mingw32.zip",
            uri_amd64 : "http://yices.csl.sri.com/cgi-bin/yices-newlicense.cgi?file=yices-{{version}}-x86_64-pc-mingw32.zip",
            desc :      "The Yices SMT Solver {{version}}"
        }

    }

};
