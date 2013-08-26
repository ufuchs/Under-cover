/*jslint bitwise:true*/

/*!
 * retrieve
 * Copyright(c) 2013 Uli Fuchs <ufuchs@gmx.com>
 * MIT Licensed
 *
 * [ The true sign of intelligence is not knowledge but imagination. ]
 * [                                             - Albert Einstein - ]
 *
 *
 * Invoke at your Windows console:
 * cscript //NoLogo this_filename
 *
 */

'use strict';

// ////////////////////////////////////////////////////////////////////////////
// configuration
// ////////////////////////////////////////////////////////////////////////////

// http://download.jetbrains.com/mps/MPS-2.5.4.zip
// http://download.oracle.com/otn-pub/java/jdk/6u45-b06/jre-6u45-windows-i586.exe
// http://download.jetbrains.com/mps/MPS-2.5.4.exe

var packages = {

    "mps" : {
        "url" : "http://download.jetbrains.com/mps/MPS-2.5.4.zip",
        "install" : {
            "dir" : "",
            "options" : "b",
            "patch" : "a"
        }
    },

    "java6" : {
        "url" : "http://download.oracle.com/otn-pub/java/jdk/6u45-b06/jre-6u45-windows-i586.exe",
        "install" : {
            "dir" : "",
            "options" : ""
        }
    },


    "cliTools" : {


        "installDir" : "",


        "packages" : {

            "all": {
                "graphviz" : "http://www.graphviz.org/pub/graphviz/stable/windows/graphviz-2.32.zip",
                "cbmc": "http://www.cprover.org/cbmc/download/cbmc-4-4-win.zip"
            },

            "x86" : {
                "nusmv": "http://nusmv.fbk.eu/distrib/NuSMV-2.5.4-i386-pc-mingw32.zip",
                "yices": "http://yices.csl.sri.com/cgi-bin/yices-newlicense.cgi?file=yices-1.0.39-i686-pc-mingw32.zip"
            },

            "amd64" : {
                "nusmv": "http://nusmv.fbk.eu/distrib/NuSMV-2.5.4-x86_64-w64-mingw32.zip",
                "yices": "http://yices.csl.sri.com/cgi-bin/yices-newlicense.cgi?file=yices-1.0.39-x86_64-pc-mingw32.zip"
            }
        }

    }

};

// ////////////////////////////////////////////////////////////////////////////
// common function
// ////////////////////////////////////////////////////////////////////////////

//
//
//
function processorArch() {

    var WshShell = new ActiveXObject("WScript.Shell"),
        regKey = "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\PROCESSOR_ARCHITECTURE";

    return WshShell.RegRead(regKey);

}

// ////////////////////////////////////////////////////////////////////////////
// cli tools
// ////////////////////////////////////////////////////////////////////////////

//
//
//
function getIndependentCliToolsUrl() {
    return [packages.cliTools.packages.all.graphviz, packages.cliTools.packages.all.cbmc];
}

//
//
//
function getX86CliToolsUrl() {

    var independentCliToolsUrl = getIndependentCliToolsUrl(),
        x86CliToolsUrl = [packages.cliTools.packages.x86.nusmv, packages.cliTools.packages.x86.yices];

    return independentCliToolsUrl.concat(x86CliToolsUrl);
}

//
//
//
function getAmd64CliToolsUrl() {

    var independentCliToolsUrl = getIndependentCliToolsUrl(),
        amd64CliToolsUrl = [packages.cliTools.packages.amd64.nusmv, packages.cliTools.packages.amd64.yices];

    return independentCliToolsUrl.concat(amd64CliToolsUrl);

}

//
//
//
function getCliToolsUrl() {

    var arch = processorArch(),
        url;


    if (arch === 'AMD64') {
        url = getAmd64CliToolsUrl();
    } else {
        url = getX86CliToolsUrl();
    }

    return url;

}

//
//
//
function extractPackageNameFromUrl(url) {

    var packageName = url.substr(url.lastIndexOf("/") + 1, url.lenght),
        pos = packageName.lastIndexOf("=") + 1;

    if (pos > 0) {
        packageName = packageName.substr(pos, packageName.lenght);
    }

    return packageName;
}

//
//
//
function removePackage(packageName) {

    var fso = new ActiveXObject("Scripting.FileSystemObject");

    if (fso.FileExists(packageName)) {
        fso.DeleteFile(packageName);
    }


}

//
//
//
function writePackageContent(res, packageName) {

    var adoStream;

    adoStream = new ActiveXObject("ADODB.Stream");
    adoStream.Open();
    adoStream.Type = 1;
    adoStream.Write(res);

    adoStream.Position = 0;

    adoStream.SaveToFile(packageName);
    adoStream.Close();

}


var http;
//
//
//
function getText(url, callback) {

    var strResult,
        status,
//        http,
        packageName = extractPackageNameFromUrl(url);


    try {
        // Create the WinHTTPRequest ActiveX Object.
        http = new ActiveXObject("WinHttp.WinHttpRequest.5.1");

//        http = new ActiveXObject("Microsoft.XMLHTTP");

        //  Create an HTTP request.
        http.Open("GET", url, true);


//        http.onreadystatechange = http_OnResponseFinished;

        //  Send the HTTP request.
        http.Send();

        WScript.Echo("Trying " + packageName);

//        http.OnResponseDataAvailable = null;

        WScript.Echo(http.WaitForResponse());


        /*


var xmlServerHttp = new ActiveXObject("Msxml2.ServerXMLHTTP.6.0");
xmlServerHttp.open("GET", "http://localhost/sample.xml", true);
xmlServerHttp.send();
while (xmlServerHttp.readyState != 4) {
   xmlServerHttp.waitForResponse(1000);
}



        */


        //
        // http://msdn.microsoft.com/en-us/library/ms765535(v=vs.85).aspx
        //
        while (http.WaitForResponse() === -1) {
            WScript.StdOut.Write('.');
            WScript.Sleep(1000);
        }

        status = http.Status;

        if (status !== 200) {
            WScript.Echo("FAILED to download: HTTP Status " + status);
            WScript.Quit(1);
        }

        callback(http.ResponseBody, packageName);


    } catch (err) {
        strResult = err + "\n";
        strResult += "WinHTTP returned error: " +
            (err.number & 0xFFFF).toString() + "\n\n";
        strResult += err.description;
    }

    //  Return the response text.
    return strResult;
}

function http_OnResponseDataAvailable(data) {
    WScript.Echo('Daten');
}

function http_OnResponseFinished() {
    WScript.Echo('Schluß');
}

function http_OnResponseStart(status, contenttype) {
    WScript.Echo(status);
}

//WScript.Echo(getCliToolsUrl());


getText("http://www.graphviz.org/pub/graphviz/stable/windows/graphviz-2.32.zip", writePackageContent);

//getText("https://phs.googlecode.com/files/Download%20File%20Test.zip", writePackageContent);

//var str = packages.x86.yices;

//WScript.Echo(extractPackageNameFromUrl(str));
