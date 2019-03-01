const express = require('express');
const author  = require('../../public/authors');
//const populatedb  = require('../../public/populatedb');

module.exports = function(app){
  const router = express.Router();
  
  router.get('/getauthor', author.author_get);

  router.get('/list', author.author_list);

  app.use('/api/v1', router);
}

