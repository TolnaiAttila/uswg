#!/bin/bash

path=$1

if [ -f "$path" ]; then
    exit 0
else
    exit 151
fi