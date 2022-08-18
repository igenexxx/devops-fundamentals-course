#!/usr/bin/env bash

files_path="../content/files"

# Get options values
ARGUMENT_LIST=(
    "branch"
    "owner"
    "repo"
    "poll-for-source-changes"
    "configuration"
)

# read arguments
opts=$(getopt \
  --longoptions "$(printf "%s:," "${ARGUMENT_LIST[@]}")" \
  --name "$(basename "$0")" \
  --options "" \
  -- "$@"
)

eval set --$opts

echo $opts
while [[ $# -gt 0 ]]; do
  case $1 in
    --branch)
        branch=${2:-main}
        shift 2
        ;;
    --owner)
        owner=$2
        shift 2
        ;;
    --repo)
        repo=$2
        shift 2
        ;;
    --poll-for-source-changes)
        pollForSourceChanges=TRUE
        shift 2
        ;;
    --configuration)
        configuration=$2
        shift 2
        ;;
    *)
        break;;
    esac
done

# Check if jq lib is exists
if ! command -v jq &> /dev/null; then
  echo "jq not found. Please install and retry"
  echo "trying to install"

  sudo apt update && sudo apt install jq -y
fi

pipeline_name=pipeline-$(date +"%d-%m-%Y").json 

# helper functions
write_to_file() {
  cat $1 > temp.json && cat temp.json > ./$pipeline_name && rm temp.json  
}

update_source_configuration() {
  prop=$1
  value=$2
  default=$3

  write_to_file <(jq "(.pipeline.stages[] | select(.name == \"Source\") | .actions[].configuration.$prop) |= \"${value:-$default}\"" ./$pipeline_name) 
}

# create copy of pipeline.json
cp $files_path/pipeline.json ./$pipeline_name

# change the pipeline json
write_to_file <(jq 'del(.metadata)' $pipeline_name)
write_to_file <(jq '.pipeline.version |= . + 1' $pipeline_name)

# update source configuration
update_source_configuration "Branch" $branch main
update_source_configuration "Repo" $repo

# result
cat $pipeline_name
