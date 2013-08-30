#!/bin/bash
case $1 in
  "spec")
    mocha --compilers coffee:coffee-script --recursive --reporter spec spec/helper.coffee  spec
    ;;

  "test")
    mocha --compilers coffee:coffee-script --recursive --reporter spec test/helper.coffee test
    ;;
esac