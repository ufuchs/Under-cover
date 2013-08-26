

var app = {

    downloadDir : '',

    proxy : {
        isActive : false,
        settings : 0,
        server : 'http://proxy.aucoteam.de:80',
        bypassList : '*.aucoteam.de'
    }

};


var versions = {

    mps : "2.5.4",
    java : "6u45",
    graphviz : "2.32",
    cbmc : "4-4",
    nusmv : "2.5.4",
    yices : "1.0.39"

};

var downloads = {

    "mps" : {
        "url_x86" : "http://download.jetbrains.com/mps/MPS-{{version}}.zip",
        "url_amd64" : "http://download.jetbrains.com/mps/MPS-{{version}}.zip"
    },

    "java" : {

        url_x86 :   "http://download.oracle.com/otn-pub/java/jdk/{{version}}-b06/jre-{{version}}-windows-i586.exe",
        url_amd64 : "http://download.oracle.com/otn-pub/java/jdk/{{version}}-b06/jre-{{version}}-windows-x64.exe"
    },


    "graphviz" : {
        url_x86 :   "http://www.graphviz.org/pub/graphviz/stable/windows/graphviz-{{version}}.zip",
        url_amd64 : "http://www.graphviz.org/pub/graphviz/stable/windows/graphviz-{{version}}.zip"
    },


    "cbmc" : {
        url_x86 :   "http://www.cprover.org/cbmc/download/cbmc-{{version}}-win.zip",
        url_amd64 : "http://www.cprover.org/cbmc/download/cbmc-{{version}}-win.zip"
    },

    "nusmv" : {
        url_x86 :   "http://nusmv.fbk.eu/distrib/NuSMV-{{version}}-i386-pc-mingw32.zip",
        url_amd64 : "http://nusmv.fbk.eu/distrib/NuSMV-{{version}}-x86_64-w64-mingw32.zip"
    },

    "yices" : {
        url_x86 :   "http://yices.csl.sri.com/cgi-bin/yices-newlicense.cgi?file=yices-{{version}}-i686-pc-mingw32.zip",
        url_amd64 : "http://yices.csl.sri.com/cgi-bin/yices-newlicense.cgi?file=yices-{{version}}-x86_64-pc-mingw32.zip"
    }


};

var install = {

    "mps" : {
        "dir" : "",
        "patch" : "a"
    },


    "java" : {
        "dir" : "",
        "options" : ""
    },


    "cliTools" : {
        dir : ''
    }



};
