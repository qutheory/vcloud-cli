#!/bin/bash

brew upgrade ruby

sudo gem install require tty-prompt paint colorize json redis netrc tty-spinner

cp -R /Users/jonasschwartz/Documents/VaporCloud/tmp/dummy-cli ~/vcloud-cli

cp ~/vcloud-cli/vapor-alpha /usr/local/bin/vapor-alpha
chmod +x /usr/local/bin/vapor-alpha
