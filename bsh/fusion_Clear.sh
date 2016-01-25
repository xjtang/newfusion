#!/bin/bash

# clear results for one site of a typical fusion process
# clear only change detection result by default
# Input Arguments: 
#   -a clear all results
#   1.Path to data

if [ $1 = "-a" ]; then
    echo 'Removing all results.'
    rm $2/MOD09FUS/*
    rm $2/MOD09DIF/*
    rm -r $2/ETMDIF/*
    rm $2/CACHE/*
    rm $2/COEFMAP/*
    rm $2/CHGMAP/*
    rm $2/CHGMAT/*
else
    echo 'Removing change detection results only.'
    rm $1/COEFMAP/*
    rm $1/CHGMAP/*
    rm $1/CHGMAT/*
fi

echo 'done'

# end
