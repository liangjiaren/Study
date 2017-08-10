'use strict';

const resModel = require('../models/resModel');
const giftModel = require('../models/giftModel');

module.exports = (req, res) => {
    var code = 0;
    var msg = '';
    if (giftModel.giftListData == undefined) {
        code = 2002;
        msg = 'READ_JSON_ERROR';
    }

    res.send(resModel.resJSON(code, msg, giftModel.giftListData));
};