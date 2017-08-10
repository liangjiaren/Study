'use strict';

const fs = require('fs');

var giftListData = [];

fs.readFile('./source/giftList.json', 'utf8', (err, data) => {
    if (err) {
        console.log("readFile giftList ==> " + err);
        return;
    }

    giftListData = JSON.parse(data);
});

giftListData.forEach((param) => {
    console.log(param);
});

function getPoints(giftID) {

}

module.exports = {
    giftListData: giftListData
};