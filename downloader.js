'use strict'

var progress = function () {

    var run = false;

    function progressing() {

        while (run) {
            WScript.StdOut.Write('.');
            WScript.Sleep(1000);
        }
    }

    return {
        start : function () {
            run = true;
            progressing();
        },
        stop : function () {
            run = false;
        }
    };

};


var e = {

    "100" : "Continue",
    "101" : "Switching protocols",
    "200" : "OK",
    "201" : "Created",
    "202" : "Accepted",
    "203" : "Non-Authoritative Information",
    "204" : "No Content",
    "205" : "Reset Content",
    "206" : "Partial Content",
    "300" : "Multiple Choices",
    "301" : "Moved Permanently",
    "302" : "Found",
    "303" : "See Other",
    "304" : "Not Modified",
    "305" : "Use Proxy",
    "307" : "Temporary Redirect",
    "400" : "Bad Request",
    "401" : "Unauthorized",
    "402" : "Payment Required",
    "403" : "Forbidden",
    "404" : "Not Found",
    "405" : "Method Not Allowed",
    "406" : "Not Acceptable",
    "407" : "Proxy Authentication Required",
    "408" : "Request Timeout",
    "409" : "Conflict",
    "410" : "Gone",
    "411" : "Length Required",
    "412" : "Precondition Failed",
    "413" : "Request Entity Too Large",
    "414" : "Request-URI Too Long",
    "415" : "Unsupported Media Type",
    "416" : "Requested Range Not Suitable",
    "417" : "Expectation Failed",
    "500" : "Internal Server Error",
    "501" : "Not Implemented",
    "502" : "Bad Gateway",
    "503" : "Service Unavailable",
    "504" : "Gateway Timeout",
    "505" : "HTTP Version Not Supported"
};

//
//
//
var httpDownloader = function () {

    var VERSION = '0.1',
        http = new ActiveXObject("WinHttp.WinHttpRequest.5.1"),
        adodb = new ActiveXObject("ADODB.Stream"),
        asynchron = true,
        status = 0;

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
    function writeHttpContent(res, packageName) {

        adodb = new ActiveXObject("ADODB.Stream");
        adodb.Open();
        adodb.Type = 1;
        adodb.Write(res);

        adodb.Position = 0;

        adodb.SaveToFile(packageName);
        adodb.Close();

    }

    //
    // http://msdn.microsoft.com/en-us/library/windows/desktop/aa384059(v=vs.85).aspx
    //
    function httpRequest(params, cb) {


    params = {
        url : 'https://phs.googlecode.com/files/Download%20File%20Test.zip',
        proxy : {
            settings : '',
            server : '',
            bypassList : ''
        }
    };


        try {

            // Use proxy_server for all requests outside of
            // the microsoft.com domain.
            httpq.SetProxy( HTTPREQUEST_PROXYSETTING_PROXY,
                "proxy_server:80",
                "*.aucoteam.de");

            http.Open("GET", params.url, asynchron);

            http.Send();

            while (!http.WaitForResponse(0)) {
                WScript.StdOut.Write('.');
                WScript.Sleep(1000);
            }
            WScript.StdOut.Write('\n');

            status = http.status;

            cb(null, http.ResponseBody);

        } catch (err) {
            cb(err, null);
        }

    }

    return {
        httpRequest : function (url, cb) {
            return httpRequest(url, cb);
        },
        status : function () {
            return status;
        }
    };

};

var dl = httpDownloader(),
//    url = 'http://www.graphviz.org/pub/graphviz/stable/windows/graphviz-2.32.zip';
    url = 'https://phs.googlecode.com/files/Download%20File%20Test.zip',

    params = {
        url : 'https://phs.googlecode.com/files/Download%20File%20Test.zip',
        proxy : ""
    };

/*
// HttpRequest SetCredentials flags.
HTTPREQUEST_PROXYSETTING_DEFAULT   = 0;
HTTPREQUEST_PROXYSETTING_PRECONFIG = 0;
HTTPREQUEST_PROXYSETTING_DIRECT    = 1;
HTTPREQUEST_PROXYSETTING_PROXY     = 2;
*/

dl.httpRequest(params, function (err, data) {

    var msg,
        status;


    WScript.Echo("Trying " + packageName);

    if (err !== null) {
        msg = "WinHTTP returned error: " + (err.number & 0xFFFF).toString() + "\n";
        msg += err.description;
    } else {
        status = dl.status();
        msg = status + ' ' + e[status];
    }

    WScript.Echo(msg);

});
