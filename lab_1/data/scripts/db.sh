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
esac


