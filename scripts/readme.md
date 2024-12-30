#this line goes where php would be run within the docker-compose.yml php needs to see this
- ../scripts:/var/www/scripts 

#when the container gets fired up
php /var/www/scripts/refreshOrgchartEmployees.php