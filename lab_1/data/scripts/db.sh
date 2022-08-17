#!/usr/bin/env bash

user_db_path="$(dirname $0)/../users.db"
# functions
check_users_db() {
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

	echo $username, $role >> $user_db_path
}

help() { 
    cat << EOF
Usage:
    $0 [<command>]

    These are commands available:
        help
        add
        backup
        find
        list

    ====================================================
    $0
        If not users.db exists, it will be created.
    add
        New entity of users.db should be a comma-separated value like: username, role
        Example:
            $0 add
    backup
        Creates a new file, named %date%-users.db.backup which is a copy of current users.db
        Example:
            $0 backup
    find
        Prompts the user to type a username, then prints username and role if such exists in users.db.
        If there is no user with the selected username, the script must print: “User not found”.
        If there is more than one user with such a username, print all found entries.
        Example:
            $0 find
    list [--inverse]
        Prints the content of the users.db in the format:
            N. username, role (N is the number of the user)
        --inverse
            Accepts an additional optional parameter --inverse which allows results in the opposite order – from bottom to top. 

EOF
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

# add, backup, find, list, help
# commands
case $1 in
	"add")
		add;;
	"help")
		help;;
esac


