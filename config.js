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

        downloadDir : './downloads',

        proxy : {
            isActive : false,
            settings : 0,
            server : 'http://178.15.127.98:80',
            bypassList : '*.aucoteam.de'
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

        order : ['mps', 'java', 'graphviz', 'cbmc', 'nusvm', 'yices']

    },

    packages : {

        mps : {
            uri :       "http://download.jetbrains.com/mps/MPS-{{version}}.zip"
        },

        java : {
            uri_x86 :   "http://download.oracle.com/otn-pub/java/jdk/{{version}}-b06/jre-{{version}}-windows-i586.exe",
            uri_amd64 : "http://download.oracle.com/otn-pub/java/jdk/{{version}}-b06/jre-{{version}}-windows-x64.exe"
        },

        ////
        // cliTools
        ////

        graphviz : {
            uri :       "http://www.graphviz.org/pub/graphviz/stable/windows/graphviz-{{version}}.zip"
        },

        cbmc : {
            uri :       "http://www.cprover.org/cbmc/download/cbmc-{{version}}-win.zip"
        },

        nusmv : {
            uri_x86 :   "http://nusmv.fbk.eu/distrib/NuSMV-{{version}}-i386-pc-mingw32.zip",
            uri_amd64 : "http://nusmv.fbk.eu/distrib/NuSMV-{{version}}-x86_64-w64-mingw32.zip"
        },

        yices : {
            uri_x86 :   "http://yices.csl.sri.com/cgi-bin/yices-newlicense.cgi?file=yices-{{version}}-i686-pc-mingw32.zip",
            uri_amd64 : "http://yices.csl.sri.com/cgi-bin/yices-newlicense.cgi?file=yices-{{version}}-x86_64-pc-mingw32.zip"
        }

    }

};
