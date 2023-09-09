const express = require("express");
const path = require("path");
var bodyParser = require("body-parser");
const PORT = process.env.PORT || 80;


express()
  .use(express.static(path.join(__dirname, "build")))
  .use(express.json())
  .use(bodyParser.urlencoded({ extended: false }))
  .listen(PORT, () => console.log(`Listening on ${PORT}`));