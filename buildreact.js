#!/bin/bash

browserify -t [ babelify --presets [ react ] ] web/assets/js/index.jsx -o web/assets/js/index.js
