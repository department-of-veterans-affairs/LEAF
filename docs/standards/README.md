# Code Standards

## PHP 

LEAF uses [PHP-CS-Fixer](https://github.com/FriendsOfPHP/PHP-CS-Fixer) to enforce PHP coding standards.

`PHP-CS-Fixer` should be installed on the development machine, and **NOT** as a dependency of this project.

Plugins for all major IDEs are available to assist in using `PHP-CS-Fixer`. Or it can be run from the command line.

All rules for LEAF are contained in [php-cs-config.php](php-cs-config.php), this is the file `PHP-CS-Fixer` should use as a config file.

All PHP files that have been changed must be run through `PHP-CS-Fixer` before being committed to the repository.

### Default File Header

[DefaultFileHeader.txt](DefaultFileHeader.txt) contains the default header `PHP-CS-Fixer` will append to the top of every file it runs against.