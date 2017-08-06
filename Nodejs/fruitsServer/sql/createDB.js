'use strict';

const mysql = require('mysql');

function createDB() {
    var conn = mysql.createConnection({
        host: 'localhost',
        port: '3306',
        user: 'root',
        password: '50839393'
    });

    conn.connect();

    conn.query('CREATE DATABASE fuirt_db', function(err, res) {
        creatTables();
        if (err) {
            console.log("CREATE DATABASE ==> " + err);
            return;
        }
        console.log("CREATE DATABASE SUCCESS");
    });

    conn.end();
}

function creatTables() {
    var conn = mysql.createConnection({
        host: 'localhost',
        port: '3306',
        user: 'root',
        password: '50839393',
        database: 'fuirt_db'
    });

    conn.connect();

    conn.query('CREATE TABLE IF NOT EXISTS t_userPoints (id integer primary key auto_increment, userID text, points integer)', function(err, res) {
        if (err) console.log("CREATE t_userPoints ==> " + err);
    });

    conn.end();
}

module.exports.createDB = createDB;