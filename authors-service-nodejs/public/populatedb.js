const CloudantSDK = require('@cloudant/cloudant');
const log4js = require('log4js');
const appName = require('./../package').name;
const logger = log4js.getLogger(appName);
logger.level = process.env.LOG_LEVEL || 'info';
const localConfig = require('../config.json');
const data = require('./populatedb.json');

logger.info(data.records.length);

var i;
for (i = 0; i < data.records.length; i++) {
  logger.info(JSON.stringify(data.records[i]));
}; 

/*
var dbname = "authors-test";

if (process.env.CLOUDANT_URL) {
    var cloudant_db = require('@cloudant/cloudant')(process.env.CLOUDANT_URL); 
} else {
    var cloudant_db = require('@cloudant/cloudant')(localConfig.CLOUDANT_URL);
    logger.info("Using DB: " + localConfig.CLOUDANT_URL);
}

// Check if db exists, if not create and insert view as designdoc
logger.info('Trying to create authors database, will "fail" if it already exists');
cloudant_db.db.create(dbname, function(err, res) {
    if (err) {
        logger.info('===>>  Could not create database, seems to exist: ' + err);
    } else {
        logger.info('===>>  Database created.'); 
        // Try to create view
        cloudant_db.use(dbname).insert(
            {"views": {"data_by_name": {"map": function (doc) {emit (doc.name, doc);}}}}, '_design/authorview', function (error, response) {
                if (error) { 
                    console.log("===>>  Inserting view failed. " + error); 
                } else { 
                    console.log("===>>  View 'authorview' inserted."); 
                } 
            }
        );  
    }
});
*/
