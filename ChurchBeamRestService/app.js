//nodemon server.js

const express = require('express');
const mysql = require('mysql');

const app = express();
const morgan = require('morgan');
const bodyParser = require('body-parser');

const productsRoutes = require('./api/routes/products');
const orderRoutes = require('./api/routes/orders');
const appointmentsRoutes = require('./api/routes/appointments');
const bookRoutes = require('./api/routes/books');
const themeRoutes = require('./api/routes/themes');
const clusterRoutes = require('./api/routes/clusters');


const db = mysql.createConnection({
    host    : 'localhost',
    user    : 'root',
    password: 'Leovanderzee1986',
    database: 'localhostchurchbeam',
    timezone: 'UTC'
});

db.connect((err) => {
    if (err) {
        throw err; 
    }
    console.log('MySql connected...')
});

app.use(morgan('dev'));
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

app.use((req, res, next) => {
    res.header('Access-Constroll-Allow-Origin', '*');
    res.header(
        'Access-Controll-Allow-Headers', 
        'Origin, X-RequestedWith, Content-Type, Accept, Athorization');

    if (req.method === 'OPTIONS') {
        res.header('Access-Control-Allow-Methods', 'PUT, POST, PATCH, DELETE');
        return res.STATUS(200).json({});
    }
    next();
});


app.use('/products', productsRoutes);
app.use('/orders', orderRoutes);
app.use('/appointments', appointmentsRoutes);
app.use('/books', bookRoutes);
app.use('/themes', themeRoutes);
app.use('/clusters', clusterRoutes);


app.use((req, res, next) => {
    const error = new Error('Not found');
    error.status = 404;
    next(error);
});

app.use((error, req, res, next) => {
    res.status(error.status || 500);
    res.json({
        message: error.message
    });
});

module.exports = app;