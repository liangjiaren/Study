'use strict';

function resFormat(code, msg, res) {
    this.code = code;
    this.msg = msg;
    this.res = res;
};

function resJSON(code, msg, res) {
    var r = new resFormat(code, msg, res);
    return JSON.stringify(r, null, 4);
}

module.exports.resJSON = resJSON;