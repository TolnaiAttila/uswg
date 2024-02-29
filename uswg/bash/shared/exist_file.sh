#!/bin/bash

path=$1

if [ -f "$path" ]; then
    #letezik
    exit 0
else
    #nem
    exit 1
fi