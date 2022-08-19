#!/usr/bin/env bash

# Check if jq lib is exists
if ! command -v jq &> /dev/null; then
  echo "jq not found. Please install and retry"

  xdg-open "https://stedolan.github.io/jq/download/"
  exit 1
fi

# variables init
pipeline_name=pipeline-$(date +"%d-%m-%Y").json 

declare -A ARGUMENTS_PROPS_MAP=( 
  [branch]="Branch" 
  [owner]="Owner" 
  [repo]="Repo" 
  [poll-for-source-changes]="PollForSourceChanges" 
  [configuration]="Configuration" 
)

# read arguments
opts=$(getopt \
  --longoptions "$(printf "%s:," "${!ARGUMENTS_PROPS_MAP[@]}")" \
  --name "$(basename "$0")" \
  --options "" \
  -- "$@"
)

eval set --$opts

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
        pollForSourceChanges=${2:-false}
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

# get path to the source file
path_to_source_file=$(echo $opts | sed 's/ -- /;/' | cut -d";" -f2 | tr -d "'")

if [[ ! -f $path_to_source_file ]]; then
  echo "Source file not found. Exiting"
  exit 1
fi

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

check_props_exist() {
  local prop=$1
  jq -e "(.pipeline.stages[] | select(.name == \"Source\") | .actions[].configuration.$prop)" ./$pipeline_name

  return $?
}

update_env_variables() {
  env_value=$1
  write_to_file <(jq "(.pipeline.stages[].actions[].configuration.EnvironmentVariables) |= (( select(. != null) | fromjson | .[].value |= \"$env_value\") | tojson)" ./$pipeline_name)
}

# create copy of pipeline.json
cp $path_to_source_file ./$pipeline_name

# check if prop exist
# check all except configuration
for prop in "${!ARGUMENTS_PROPS_MAP[@]::${#!ARGUMENTS_PROPS_MAP[@]} - 1}"; do
  key=${ARGUMENTS_PROPS_MAP[$prop]}
  param=${key,}

  if [[ -n ${!param} ]] && ! check_props_exist $key; then
    echo "Property $key not found. Exiting"
    exit 1
  fi
done

# change the pipeline json
write_to_file <(jq 'del(.metadata)' $pipeline_name)
write_to_file <(jq '.pipeline.version |= . + 1' $pipeline_name)

# update source configuration
[[ -n $branch ]] && update_source_configuration ${ARGUMENTS_PROPS_MAP[branch]} $branch
[[ -n $repo ]] && update_source_configuration ${ARGUMENTS_PROPS_MAP[repo]} $repo
[[ -n $pollForSourceChanges ]] && update_source_configuration ${ARGUMENTS_PROPS_MAP[pollForSourceChanges]} $pollForSourceChanges
[[ -n $owner ]] && update_source_configuration ${ARGUMENTS_PROPS_MAP['owner']} $owner
[[ -n $configuration ]] && update_env_variables $configuration

# result
cat $pipeline_name
