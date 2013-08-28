/*global ActiveXObject:false*/
/*global config:false*/

/*!
 * utils
 * Copyright(c) 2013 Uli Fuchs <ufuchs@gmx.com>
 * MIT Licensed
 *
 */

'use strict'

var utils = (function () {

    //
    // Gets the architecture of the processor
    // @return String - x86 or amd64
    // @api : public

    function processorArch() {

        var WshShell = new ActiveXObject("WScript.Shell"),
            regKey = "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\PROCESSOR_ARCHITECTURE";

        return WshShell.RegRead(regKey).toLowerCase();

    }

    //
    //
    // @api : private

    function extractPackageNameFromUrl(url) {

        var packageName = url.substr(url.lastIndexOf("/") + 1, url.length),
            pos = packageName.lastIndexOf("=") + 1;

        if (pos > 0) {
            packageName = packageName.substr(pos, packageName.length);
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

    // Populate the placeholder {{version}} with the real package version
    // @param1 {packageName} String
    // @param2 {version} String
    // @return String - the packagename with a real world version
    // @api : private

    function applyVersion(packageName, version) {
        return fillTemplates(packageName, {
            version : version
        });

    }

    // Gets the version of 'packageNameOfInterest' from 'depVhain'
    // @param1 {packageNameOfInterest} String
    // @api : private

    function getPackageVersion(packageNameOfInterest) {

        var packageName,
            res;

        for (packageName in config.dependencies) {

            if (config.dependencies.hasOwnProperty(packageName)) {

                if (packageNameOfInterest === packageName) {
                    res = config.dependencies[packageName];
                    break;
                }

            }

        }

        return res;

    }

    //
    //
    // @param {name} String - name of package
    // @param {content} Object - content of the package from 'config.packages'
    // @return Object - { name, fileName, downloadUri}
    // @api : private
    //

    function lookupPackage(name, content) {

        var prop,
            uri = null,
            version = getPackageVersion(name),
            pkg = {
                name : name,        // name of the package
                desc : '',          // short description of the package
                fileName : '',      // file to download
                uri : '',           // URI of the package
                status : -1,        // http status code
                msg : ''            // installer msg
            };

        for (prop in content) {

            if (content.hasOwnProperty(prop)) {

                // test for 'url*'
                if (prop.substr(0, 3) === 'uri' && uri === null) {

                    if (prop.length === 3) {
                        // platform indepentend package
                        uri = prop;
                    } else {
                        // package depends on platform type
                        uri = 'uri_' + processorArch();
                    }

                    // patch the filename with the version number
                    pkg.uri = applyVersion(content[uri], version);

                    // name of the installer file (exe or zip)
                    pkg.fileName = extractPackageNameFromUrl(pkg.uri);

                    pkg.desc = applyVersion(content.desc, version);



                }

            }
        }

        return pkg;

    }

    //
    //
    //

    function getPackagesToInstall() {

        var name,
            i = 0,
            toInstall = [];

        for (name in config.packages) {

            if (config.packages.hasOwnProperty(name)) {
                toInstall[i++] = lookupPackage(name, config.packages[name]);
            }

        }

        return toInstall;

    }

    //
    // the return section of this closure
    //
    return {

        processorArch : function () {
            return processorArch();
        },

        getPackagesToInstall : function () {
            return getPackagesToInstall();
        }

    };

}());

