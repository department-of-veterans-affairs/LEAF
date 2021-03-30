#!/bin/bash

# Go to main upload directory
cd /var/www/ERM_UPLOADS

#dev
# du --max-depth=3 * | sort -rn > /var/www/html/_portal-upload-sizes
#prod
du --max-depth=3 * | sort -rn > /var/www/html/launchpad/_portal-upload-sizes
