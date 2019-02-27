const express = require('express');
const author  = require('../../public/authors');

module.exports = function(app){
  const router = express.Router();
  router.get('/getauthor', author.author_get);
  /*router.get('/getauthor', function(req, res, next) {
    res.writeHead(200, { "Content-Type": "application/json" }); 
    res.end('respond with: ');
    console.log(req.query.name);
  });*/

  router.get('/list', author.author_list);

  app.use('/api/v1', router);
}

