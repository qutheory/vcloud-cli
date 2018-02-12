require 'tty-prompt'
require 'whirly'
require 'paint'
require "net/http"
require "uri"
require "colorize"
require "yaml"
require "json"
require "redis"
require "netrc"

require "./Api/get"
require "./Api/post"
require "./Api/patch"
require "./Api/refresh_token"
require "./Authentication/login"
require "./Authentication/secret_file"
require "./application"
