#!/bin/bash

# copy distribution file to all example projects
cd ./examples
ls | xargs -n 1 cp ../src/LineWobbler.pde