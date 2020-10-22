#!/bin/bash
# vim: set filetype=sh :

set -eu

test $(curl -o /dev/null -sw 'x%{http_code}' http://localhost/nginx_status) == 'x200'
test $(curl -o /dev/null -sw 'x%{http_code}' http://localhost/status) == 'x200'
test $(curl -o /dev/null -sw 'x%{http_code}' http://localhost/ping) == 'x200'
test $(curl -o /dev/null -sw 'x%{http_code}' http://localhost/healthcheck/) == 'x200'



