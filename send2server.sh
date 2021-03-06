#!/bin/bash

controller() {
    case "${USE_PORT}" in
        Y)  ctrl_with_port
            ;;
        y)  ctrl_with_port
            ;;
        N)  ctrl_without_port
            ;;
        n)  ctrl_without_port
            ;;
        *)  echo "Input invalid. Please choose between [Y/N]."
            echo "Operation aborted."
            exit
    esac
}

compute() {
    case "${USE_PORT}" in
        Y)  comp_with_port
            ;;
        y)  comp_with_port
            ;;
        N)  comp_without_port
            ;;
        n)  comp_without_port
            ;;
        *)  echo "Input invalid. Please choose between [Y/N]."
            echo "Operation aborted."
            exit
    esac
}

ctrl_with_port() {
    read -p "Enter port number:" PORT
    scp -P $PORT controller $UNAME@$IP_ADDR:~
}

ctrl_without_port() {
    scp -r controller $UNAME@$IP_ADDR:~
}

comp_with_port() {
    read -p "Enter port number:" PORT
    scp -P $PORT compute -r [!.]* $UNAME@$IP_ADDR:~
}

comp_without_port() {
    scp -r compute $UNAME@$IP_ADDR:~
}

read -p "Enter Server type [A. Controller/B. Compute]: " SERVER
read -p "Enter Username: " UNAME
read -p "Enter IP Address: " IP_ADDR
read -p "Use Specific Port [Y/N]: " USE_PORT

case "${SERVER}" in
  A)  controller
      ;;
  a)  controller
      ;;
  B)  compute
      ;;
  b)  compute
      ;;
  *)  echo "Input invalid. Please choose between [A/B]."
      echo "Operation aborted."
      exit
esac
