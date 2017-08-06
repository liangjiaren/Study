'use strict';

const mysql = require('mysql');

const pool = mysql.createPool({
    host: 'localhost',
    port: '3306',
    user: 'root',
    password: '50839393',
    database: 'fuirt_db'
});

// 查询积分,若没有查询结果,新建数据
function inquirePoints(userID, callback) {
    pool.getConnection((err, conn) => {
        if (err) {
            console.log("POOL ==> " + err);
            callback('DB_ERROR', null);
            conn.release();
            return;
        }

        var inquireSql = `SELECT * From t_userPoints WHERE userID = '${userID}'`;

        conn.query(inquireSql, (err, res) => {
            if (err) {
                console.log("SELECT t_userPoints ==> " + err);
                callback('DB_ERROR', null);
                conn.release();
                return;
            }

            if (res.length == 0) {
                var addSql = 'INSERT INTO t_userPoints (userID, points) VALUES (?, ?)'
                var addSqlParams = [userID, 100];

                conn.query(addSql, addSqlParams, (err, res) => {
                    conn.release();
                    if (err) {
                        console.log("INSERT t_userPoints ==> " + err);
                        callback('DB_ERROR', null);
                        return;
                    }

                    callback('', addSqlParams[1]);
                });
                return;
            }

            callback('', res[0].points);
            conn.release();
        });
    });
}

// 用户积分操作,若积分不够返回错误
function alterPoints(userID, alterPoints, callback) {
    pool.getConnection((err, conn) => {
        if (err) {
            console.log("POOL ==> " + err);
            callback('DB_ERROR', null);
            conn.release();
            return;
        }

        // 获取积分
        inquirePoints(userID, (errMsg, points) => {
            if (errMsg != '') {
                callback(errMsg, null);
                conn.release();
                return;
            }

            var updatePoints = alterPoints + points;

            if (updatePoints < 0) {
                callback('POINTS_NOT_ENOUGH', null);
                conn.release();
                return;
            }

            var updateSql = `UPDATE t_userPoints SET points = ${updatePoints} WHERE userID = '${userID}'`;
            conn.query(updateSql, (err, res) => {
                conn.release();

                if (err) {
                    console.log("UPDATE t_userPoints ==> " + err);
                    callback('DB_ERROR', null);
                    return;
                }

                callback('', updatePoints);
            });

        });

    });
}

module.exports = {
    inquirePoints: inquirePoints,
    alterPoints: alterPoints
};