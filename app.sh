#!/bin/bash
case $1 in
  "spec")
    mocha --compilers coffee:coffee-script --recursive --reporter spec spec/helper.coffee spec/schema-spec.coffee spec/model-spec.coffee spec/collection-spec.coffee
    ;;

  "test")
    mocha --compilers coffee:coffee-script --recursive --reporter spec test/helper.coffee test
    ;;
esac