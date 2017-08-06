'use strict';

const c = require('./createDB');

function setUpSQL() {
    c.createDB();
}

module.exports.setUpSQL = setUpSQL;