#!/usr/bin/env bash

# run code quality tools

# check if repository exist

if [[ ! -d '../shop-angular-cloudfront' ]]; then
  echo 'Repository not found'
  
  echo "cloning repository"

  git clone git@github.com:EPAM-JS-Competency-center/shop-angular-cloudfront.git ../shop-angular-cloudfront
fi

# install dependencies

cd ../shop-angular-cloudfront || exit

if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
  echo "node or npm not found. Please install and retry"
  exit 1
fi

npm i

# check quality checks
npm run lint
npm run test 

