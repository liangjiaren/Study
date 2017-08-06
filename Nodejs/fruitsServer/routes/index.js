'use strict';

const express = require('express');
const router = express.Router();

router.get('/', require('./welcome'));
router.get('/login', require('./login'));
router.get('/user', require('./user'));
router.post('/inquirePoints', require('./inquirePoints'));
router.post('/alterPoints', require('./alterPoints'));
router.all('/tunnel', require('./tunnel'));

module.exports = router;