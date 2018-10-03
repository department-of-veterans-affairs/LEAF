#!/usr/bin/env bash
printf 'adding values to configs...\n'
nexusdir=( $(find . -name config.php) )
requestdir=( $(find . -name db_config.php) )
existsInNexus=$(awk '/leafSecure/{print NR}' $nexusdir)
existsInRequest=$(awk '/leafSecure/{print NR}' $requestdir)
if test -z "$existsInNexus"
then
      perl -pi -e '$_ .= qq(\n    public static \$leafSecure = false; \n) if /public \$dbPass/' $nexusdir
      echo "added to config.php"
else
      echo "Nexus is already LEAF-Secure ready"
fi
if test -z "$existsInRequest"
then
      perl -pi -e '$_ .= qq(\n    public static \$leafSecure = false; \n) if /public \$phonedbPass/' $requestdir
      echo "added to db_config.php"
else
      echo "Request Portal is already LEAF-Secure ready"
fi
printf 'done\n'