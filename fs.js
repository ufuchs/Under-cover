/*global ActiveXObject:false*/

 /*!
 * fs
 * Copyright(c) 2013 Uli Fuchs <ufuchs@gmx.com>
 * MIT Licensed
 *
 */

if (typeof fs !== 'object') {
    fs = {};
}

(function () {

    'use strict';

    var adodb = new ActiveXObject("ADODB.Stream"),
        // http://msdn.microsoft.com/en-us/library/2z9ffy99(v=vs.84).aspx
        fso = new ActiveXObject("Scripting.FileSystemObject");

    //
    //
    //
    fs.readFile = function (filename, callback) {

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

    };

    //
    //
    //
    fs.writeFile = function (filename, data, callback) {

        try {

            adodb.Open();
            adodb.Type = 1;
            adodb.Write(data);
            adodb.Position = 0;
            adodb.SaveToFile(filename, 2);

        } catch (err) {

            callback(err, null);

        } finally {

            adodb.Close();
            callback(null, null);

        }

    };

}());

