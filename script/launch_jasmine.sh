#!/bin/sh

JASMINE_URL="http://localhost:8888/?spec="

if [ -z "$1" ]; then
    echo "Opening $JASMINE_URL to run all the tests"
    open "$JASMINE_URL"
    exit 0
fi

# is this a spec file?
echo $1 | grep 'spec.js$'

if [ $? -eq 0 ]; then
  # ends with 'spec.js', probably a spec file
  SPECFILE=$1
else
  SPECFILE=$(script/find_spec_or_impl.rb $1)
  if [ -z "$SPECFILE" ]; then
    echo "Could not locate a spec file to go with $1" >&2
    exit 1
  fi

  echo "Detected $SPECFILE as matching spec for $1"
fi

DESCRIBE_LINE=$(grep describe $SPECFILE | head -n1)

if [ -z "$DESCRIBE_LINE" ]; then
    echo "This does not appear to be a spec file." >&2
    exit 1
fi

# to escape the single quotes in sed, you do: '\'' - escaping your single quotes, and wrapping that in single quotes
# see: http://muffinresearch.co.uk/archives/2007/01/30/bash-single-quotes-inside-of-single-quoted-strings/
SPEC=$(echo $DESCRIBE_LINE | sed 's/.*["'\'']\(.*\)["'\''][^"'\'']*$/\1/')

echo "Opening $JASMINE_URL$SPEC"

open "$JASMINE_URL$SPEC"
