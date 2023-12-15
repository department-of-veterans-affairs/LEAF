FROM nginxinc/nginx-unprivileged:1.22-alpine
COPY ./docker/nginx/leaf_nginx.conf.template /etc/nginx/templates/default.conf.template
#COPY ./docker/nginx/src/index.html /var/www/html/index.html
# COPY ./docker/nginx/nginx.conf /etc/nginx/nginx.conf
#COPY ./LEAF_Nexus /var/www/html/LEAF_Nexus
#COPY ./LEAF_Request_Portal /var/www/html/LEAF_Request_Portal
#COPY ./health_checks /var/www/html/health_checks

#Setting up "non-privledged"
# RUN chown -R nginx:nginx /var/cache/nginx &&  \
#         chmod -R 777 /var/cache/nginx && \
#         chown -R nginx:nginx /var/log/nginx && \
#         chmod -R 777 /var/log/nginx && \
#         chown -R nginx:nginx /etc/nginx/conf.d && \
#         chmod -R 777 /etc/nginx/conf.d && \
#         chown -R nginx:nginx /etc/nginx/templates && \
#         chmod -R 777 /etc/nginx/templates
# RUN touch /var/run/nginx.pid && \
#         chown -R nginx:nginx /var/run/nginx.pid && \
#         chmod -R 777 /var/run/nginx.pid

# RUN chown -R nginx:nginx /var/cache/nginx &&  \
#         chown -R nginx:nginx /var/log/nginx && \
#         chown -R nginx:nginx /etc/nginx/conf.d && \
#         chown -R nginx:nginx /etc/nginx/templates
# RUN touch /var/run/nginx.pid && \
#         chown -R nginx:nginx /var/run/nginx.pid 

# # USER nginx

# RUN chgrp -R 0 /etc/nginx/conf.d && \  
#         chmod -R g=u /etc/nginx/conf.d && \
#         chmod a+rws -R /etc/nginx/conf.d



#        chgrp -R 0 /ScanCentral  && \
#        chmod -R g=u /ScanCentral && \
#        chmod a+rwx -R /ScanCentral/tomcat/logs && \
#        chmod +x /ScanCentral/tomcat/bin/startup.sh && \
#        chmod +x /ScanCentral/tomcat/bin/catalina.sh 

USER 1001