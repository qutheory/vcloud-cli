#!/bin/bash

sudo gem install require tty-prompt paint colorize json redis netrc tty-spinner terminal-table faye-websocket eventmachine

if [ -d ~/vcloud-cli ]; then
	rm -fr ~/vcloud-cli
fi
git clone https://github.com/vapor-cloud/vcloud-cli.git ~/vcloud-cli

cp ~/vcloud-cli/vapor-alpha /usr/local/bin/vapor-alpha
chmod +x /usr/local/bin/vapor-alpha

vapor-alpha cloud --help
