/*jslint bitwise:true*/


'use strict';

var packages = {

    "all": {
        "graphviz" : "http://www.graphviz.org/pub/graphviz/stable/windows/graphviz=graphviz-2.32.zip",
        "cbmc": "http://www.cprover.org/cbmc/download/cbmc-4-4-win.zip"
    },

    "x86" : {
        "nusmv": "http://nusmv.fbk.eu/distrib/NuSMV-2.5.4-i386-pc-mingw32.zip",
        "yices": "http://yices.csl.sri.com/cgi-bin/yices-newlicense.cgi?file=yices-1.0.39-i686-pc-mingw32.zip"
    },

    "x86_64" : {
        "nusmv": "http://nusmv.fbk.eu/distrib/NuSMV-2.5.4-x86_64-w64-mingw32.zip",
        "yices": "http://yices.csl.sri.com/cgi-bin/yices-newlicense.cgi?file=yices-1.0.39-x86_64-pc-mingw32.zip"
    }

};

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
function writeResponseBody (responseBody, fromUrl) {

    var adoStream,
        fileSystem,
        packageName = extractPackageNameFromUrl(fromUrl);

    adoStream = CreateObject("ADODB.Stream");
    adoStream.Open();
    adoStream.Type = 1;
    adoStream.Write(responseBody);
    adoStream.Position = 0;

    fileSystem = CreateObject("Scripting.FileSystemObject");

    if (fileSystem.FileExists(packageName)) {
        fileSystem.DeleteFile(packageName);
    }

    adoStream.SaveToFile(packageName);
    adoStream.Close();

}

//
//
//
function getText(url) {

    var strResult,
        status,
        http,
        adoStream;

    try {
        // Create the WinHTTPRequest ActiveX Object.
        http = new ActiveXObject("WinHttp.WinHttpRequest.5.1");

        //  Create an HTTP request.
        http.Open("GET", url, false);

        //  Send the HTTP request.
        http.Send();

        status = http.Status;

        if (status !== 200) {
            WScript.Echo("FAILED to download: HTTP Status " + status);
            WScript.Quit(1);
        }

        writeResponseBody(http.ResponseBody, url);


    } catch (err) {
        strResult = err + "\n";
        strResult += "WinHTTP returned error: " +
            (err.number & 0xFFFF).toString() + "\n\n";
        strResult += err.description;
    }

    //  Return the response text.
    return strResult;
}

var str = packages.x86.yices;

WScript.Echo(extractPackageNameFromUrl(str));
