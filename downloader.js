 /*!
 * downloader
 * Copyright(c) 2013 Uli Fuchs <ufuchs@gmx.com>
 * MIT Licensed
 *
 */

//
//
//
var httpDownloader = (function () {

    'use strict';

    var VERSION = '0.1',
        http = new ActiveXObject("WinHttp.WinHttpRequest.5.1"),
//        adodb = new ActiveXObject("ADODB.Stream"),
        asynchron = true,
        status = 0,
        statusToHuman = {

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
    // http://msdn.microsoft.com/en-us/library/windows/desktop/aa384059(v=vs.85).aspx
    //
    // @api : private

    function httpRequest(url, cb) {

        var proxy = config.app.proxy;

        try {

            // Use proxy_server for all requests outside of
            // your domain.
            if (proxy.active === true) {
                http.SetProxy(proxy.settings, proxy.server,
                    proxy.bypassList);
            }

            http.Open("GET", url, asynchron);

            http.Send();

            // Draw '....' until download is finished
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

    //
    //
    //

    function downloadPackage(pkg) {

        WScript.Echo("Trying " + pkg.desc);
        WScript.Echo("Trying " + pkg.uri);

        httpRequest(pkg.uri, function (err, data) {

            var msg;

            if (err !== null) {

                msg = "WinHTTP returned error: " + (err.number & 0xFFFF).toString() + "\n";
                msg += err.description;
                pkg.msg = msg;
                pkg.status = 303;

            } else {

                pkg.msg = status + ' ' + statusToHuman[status];
                pkg.status = status;

                fs.writeFile(config.app.downloadDir + '\\' + pkg.fileName, data, function(err, data) {
                    WScript.Echo(err);
                })


            }

        });

    }

    //
    // the return section of this closure
    //
    return {

        downloadPackage : function (pkg) {
            return downloadPackage(pkg);
        }

    };

}());

var i,
    toInstall,
    pkg,
    params = {
//    url = 'http://www.graphviz.org/pub/graphviz/stable/windows/graphviz-2.32.zip',
//    url = 'https://phs.googlecode.com/files/Download%20File%20Test.zip',

    },
    pkg = {
        name : 'Test',        // name of the package
        desc : 'Test package',          // short description of the package
        fileName : 'Download%20File%20Test.zip',      // file to download
        uri : 'https://phs.googlecode.com/files/Download%20File%20Test.zip',           // URI of the package
        status : -1,        // http status code
        msg : ''            // installer msg
    };

httpDownloader.downloadPackage(pkg);
WScript.Echo(pkg.msg);

/*
toInstall = utils.getPackagesToInstall();

for (i = 0; i < toInstall.length; i++) {
    WScript.Echo(toInstall[i].fileName);
    WScript.Echo(toInstall[i].desc);
    WScript.Echo('------------------------');

}
*/
