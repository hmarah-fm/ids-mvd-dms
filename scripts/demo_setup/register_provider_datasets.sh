#!/bin/bash

echo
echo Running demo registration...
echo

## Seed linked assets to Catalog Server
newman run ./deployment/postman/DEMO.postman_collection.json  \
  --reporters cli,html \
  --reporter-html-export report.html