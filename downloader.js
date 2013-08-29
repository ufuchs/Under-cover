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
        downloadDir = "",
        msg = "",
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
    //
    //

    function setDownloadDir(dir) {
        downloadDir = dir;
    }

    //
    //
    //

    function getMsg() {
        return msg;
    }


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

            http.Open("GET", url, true);

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

    function acquireStatus(err) {

        msg = "";

        if (err !== null) {

            msg = "WinHTTP returned error: " + (err.number & 0xFFFF).toString() + "\n";
            msg += err.description;

        } else {

            msg = status + ' ' + statusToHuman[status] + " --> ";

        }

    }

    //
    //
    //

    function downloadPackage(uri) {

        var filename = utils.extractFilenameFromUri(uri);

        if (downloadDir === undefined) {
            throw new Error("property 'downloadDir' is undefined.");
        }

        httpRequest(uri, function (err, data) {

            acquireStatus(err);

            if (!err && status === 200) {

                fs.writeFile(downloadDir + '\\' + filename, data, function (err, data) {

                    if (!err) {
                        msg += data + " Bytes written";
                    }
                });

            } else {
                msg += "0 Bytes written";
            }

        });

    }

    //
    // the return section of this closure
    //
    return {

        downloadPackage : function (pkg) {
            return downloadPackage(pkg);
        },

        setDownloadDir : function (dir) {
            setDownloadDir(dir);
        },

        getMsg : function () {
            return getMsg();
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

WScript.Echo("Trying '" + pkg.desc + "'");
WScript.Echo("Trying " + pkg.uri);




httpDownloader.setDownloadDir(config.app.downloadDir);
httpDownloader.downloadPackage(pkg.uri);
WScript.Echo(httpDownloader.getMsg());

/*
toInstall = utils.getPackagesToInstall();

for (i = 0; i < toInstall.length; i++) {
    WScript.Echo(toInstall[i].fileName);
    WScript.Echo(toInstall[i].desc);
    WScript.Echo('------------------------');

}
*/
