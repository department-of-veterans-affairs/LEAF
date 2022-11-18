#!/bin/bash

while getopts u:a:f: flag
do
    case "${flag}" in
        u) username=${OPTARG};;
        a) age=${OPTARG};;
        f) fullname=${OPTARG};;
    esac
done

echo $username
echo $(date)
echo 'moo'
sleep 5m
echo $(date)