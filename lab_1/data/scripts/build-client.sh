#!/usr/bin/env bash
# Build the client application.

read -p "Enter the env name: " ENV_NAME

if [ -z "$ENV_NAME" ]; then
    ENV_NAME="development"

    echo "Environment name is set to default value: development"
fi

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

# invoke build with --configuration flag

npm run build --configuration=$ENV_NAME

# check if ../content/files/dist is exist

compressed_files_path="../content/files"

if [[ ! -d $compressed_files_path ]]; then
  mkdir -p $compressed_files_path
  echo "${compressed_files_path:3} directory created"
fi

# Compress with zip

if [[ -d 'dist' ]]; then
  echo "Compressing dist folder"
  zip -r $compressed_files_path/client-app.zip dist
fi

