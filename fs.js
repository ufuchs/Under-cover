/*global ActiveXObject:false*/

 /*!
 * fs
 * Copyright(c) 2013 Uli Fuchs <ufuchs@gmx.com>
 * MIT Licensed
 *
 */

var fs = (function () {

    'use strict';

    var adodb = new ActiveXObject("ADODB.Stream"),
        // http://msdn.microsoft.com/en-us/library/2z9ffy99(v=vs.84).aspx
        fso = new ActiveXObject("Scripting.FileSystemObject");

    //
    //
    //
    function readFile(filename, callback) {

        var data,
            size = 0;

        try {

            adodb.Open();
            adodb.Type = 1;
            adodb.LoadFromFile(filename);
            data = adodb.Read();

        } catch (err) {

            callback(err, null);

        } finally {

            size = adodb.Size;
            adodb.Close();
            callback(null, data);

        }

        return size;

    }

    //
    //
    //
    function writeFile(filename, data, callback) {

        var size;

        try {

            adodb.Open();
            adodb.Type = 1;
            adodb.Write(data);

            adodb.Position = 0;
            adodb.SaveToFile(filename, 2);

        } catch (err) {

            callback(err, 0);

        } finally {

            size = adodb.Size;
            adodb.Close();
            callback(null, size);

        }

    }

    return {

        readFile : function (filename, callback) {
            return readFile(filename, callback);
        },

        writeFile : function (filename, data, callback) {
            writeFile(filename, data, callback);
        }

    };

}());

