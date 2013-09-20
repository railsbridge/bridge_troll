#!/bin/bash

if [ -z "$1" ]; then
    echo "This script must be called with an argument" >&2
    exit 1
fi

/usr/local/bin/mine $(script/find_spec_or_impl.rb $1)
