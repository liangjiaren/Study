'use strict';

const dbOperation = require('../sql/operation');
const model = require('../models/resModel');

module.exports = (req, res) => {
    dbOperation.inquirePoints(req.body.userID, (errMsg, result) => {
        var code = 0;

        if (errMsg != '') {
            code = 2001;
            result = 0;
        }

        res.send(model.resJSON(code, errMsg, { memberPoints: result }));
    });
};