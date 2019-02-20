## Docker Setup

1. `cd docker`
1. `docker-compose up`
1. `docker-compose exec leaf-php-fpm composer install` to install app dependencies
1. To generate a unique app key run `docker-compose exec leaf-php-fpm php artisan key:generate`
1. Create the `leaf_routes` database: `docker-compose exec leaf-php-fpm php artisan db:routes:create`

## Laravel Setup

1. Copy `.env.example` and populate with relevant info
1. Run `artisan key:generate` to generate a unique app key
1. Run dev server (from project root) `artisan serve`

### `.env` Configuration

The `.env` file contains all environment specific info for the application.

* `DB_*` entries should use the connection details that access the portals/nexus databases.

* `ROUTES_DB_*` entries should use the connection details for accessing the `leaf_routes` database.

* `ADMIN_DB_*` entries should use the connection details for accessing any database with elevated privileges.


Set this in .env to log to command line:

`LOG_CHANNEL=stderr`


## Database

See `.env` configuration section above.

MariaDB specific setup is located in `app/AppServiceProvider.php`.

The `config/database.php` file contains all database connection info for the application, these should not be modified directly. Instead, configure the database connections through the `.env` file.

### Creating databases

Create the `leaf_routes` database: `artisan db:routes:create`

### Database Migrations

https://laravel.com/docs/5.7/migrations

Generate database migration:
* For Request Portal `artisan make:migration <migration_name> --path RequestPortal/database/migrations`
* For Nexus `artisan make:migration <migration_name> --path Nexus/database/migrations`

### Running migrations

Migrations are tracked in db `migrations` table. To specify which connection to use when running migrations:

```
artisan migrate --database="name_of_connection"
```

The connections are defined in `config/database.php`.

Or run Artisan command: `artisan db:routes:migrate`


## Info

All public (non-authenticated, non-database) routes are located in `routes/web.php`.

When adding new classes, ensure they can be autoloaded by including their path in `composer.json` in the "autoload" section. After editing that file, run `composer dump-autoload -o` to regenerate the autoload file.

All Request Portal Repositories/Daos are bound in `RequestPortal/app/Providers/RequestPortalRepositoryProvider.php`

All Request Portal global route pattern constraints are defined in `RequestPortal/app/Providers/RequestPortalRouteServiceProvider.php`.


### Important Laravel things to clear when things aren't working as expected

```
// clears any application caches
artisan cache:clear

// clears any cached configuration
artisan config:clear

// clears any cached routes
artisan route:clear
```

Or, run this command from the project root: `artisan clear:dev`
