#!/usr/bin/env bash

# functions
check_users_db() {
	user_db_path="$(dirname $0)/../users.db"

	if [[ ! -e $user_db_path ]]; then
		confirm "users.db is not exist. Do you want create it?" && touch $user_db_path 

		echo 'users.db was created'
	fi
}

add() {
	check_users_db
	validator_requirements="[Latin letters only]"
	quetion_username="Please enter username $validator_requirements > "
	quetion_role="Please enter role $validator_requirements > "

	read -p "$quetion_username" username
  until [[ $username =~ ^[a-zA-Z]+$ ]]; do
		read -p "$quetion_username" username
  done

	read -p "$quetion_role" role
  until [[ $role =~ ^[a-zA-Z]+$ ]]; do
      read -p "$quetion_role" role
  done

	echo $username, $role
}

help() {

}

confirm() {
	echo "$1"
  select yn in "Yes" "No"; do
      case $yn in
          Yes ) break;;
          No ) exit;;
      esac
  done
}


# commands
case $1 in
	"add")
		add;;
	"help")
		help;;
esac


