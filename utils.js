'use strict'

var utils = (function () {


    //
    // Gets the architecture of the processor
    // @return String - x86 or amd64
    function processorArch() {

        var WshShell = new ActiveXObject("WScript.Shell"),
            regKey = "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\PROCESSOR_ARCHITECTURE";

        return WshShell.RegRead(regKey).toLowerCase();

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
    // @api : private
    function fillTemplates(str, data) {
        return str.replace(/\{\{(\w+)\}\}/g, function (match, key) {
            if (data.hasOwnProperty(key)) {
                return data[key];
            }
            return "{{" + key + "}}";
        });
    }

    //
    //
    // @api : public
    function applyVersion(packageName, version) {
        return fillTemplates(packageName, {
            version : version
        });

    }

    //
    //
    // @api : public
    function getPackageVersion(packageNameOfInterest) {

        var packageName,
            res;

        for (packageName in versions) {

            if (versions.hasOwnProperty(packageName)) {

                if (packageNameOfInterest === packageName) {
                    res = versions[packageName];
                    break;
                }

            }

        }

        return res;

    }


    //
    //
    //
    return {

        processorArch : function () {
            return processorArch();
        },

        extractPackageNameFromUrl : function (url) {
            return extractPackageNameFromUrl(url);
        },

        applyVersion : function (packageName, version) {
            return applyVersion(packageName, version);
        },

        getPackageVersion : function (packageNameOfInterest) {
            return getPackageVersion(packageNameOfInterest);
        }

    };


}());

function lookupPackage(packageName, package) {

    var packageProps,
        url = null,
        arch = 'amd64',
        version = utils.getPackageVersion(packageName),
        o = { name : packageName };

    WScript.Echo(utils.getPackageVersion(packageName));

    for (packageProps in package) {

        if (packageName.hasOwnProperty(packageProps)) {

            if (packageProps.substr(0,3) === 'url' && url === null) {

                if (packageProps.lenght === 3) {
                    url = packageProps;
                } else {
                    url = 'url_' + arch;
                }

                WScript.Echo(packageName[url]);
                WScript.Echo(version);





            }


        }
    }


    return o;

}

function xy() {

    var packageName;

    for (packageName in downloads) {

        if (downloads.hasOwnProperty(packageName)) {

            WScript.Echo(packageName);
            lookupPackage(packageName, downloads[packageName]);

        }

    }

}

xy();
