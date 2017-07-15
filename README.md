# Rails Full Page Cache

A sample project to use full page caching on Rails (using *actionpack-page_caching*).

Main points:

- **app/controllers/application_controller.rb**: /update (js) route to send CSRF token, flash messages and optionally DOM elements to modify
- **app/controllers/posts_controller.rb**: caches_page actions, json only responses for create, update and destroy
- **app/models/application_record.rb**: update cache methods
- **app/models/post.rb**: cache callbacks, cache dependecies
- **app/views/layouts/application.html.erb**: on DOM ready an update AJAX call is made, data-remote AJAX callbacks (for forms)
- **app/views/posts/_form.html.erb**: form with remote option
- **config/environments/development.rb**: caching enabled, js compression, don't serve static files
- **config/initializers/actionpack-page_caching.rb**: cache directory, caching compression
- **lib/tasks/cache.rake**: cache routes, cache tasks: generate_all, generate

## Project setup

```sh
rails g model Author name:string age:integer email:string
rails g model Post title:string description:text author:belongs_to category:string dt:datetime position:float published:boolean
rails g model Detail description:text author:belongs_to
rails g model Tag name:string
rails g model PostTag post:belongs_to tag:belongs_to
```

## Serve static assets

```sh
rails assets:clean assets:precompile
rails cache:generate_all
rails server -b 0.0.0.0
```

### nginx sample conf

```conf
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;

    keepalive_timeout  65;

    gzip  on;
    gzip_min_length 1024;
    gzip_types application/json application/javascript application/x-javascript application/xml application/xml+rss text/plain text/css text/xml text/javascript;

    server {
        server_name  localhost;

        listen       8080;
        # listen       80;
        # listen       443 ssl http2;

        # ssl_certificate /usr/local/etc/nginx/ssl/server.pem;
        # ssl_certificate_key /usr/local/etc/nginx/ssl/server.key;

        large_client_header_buffers 4 16k;

        rewrite ^/(.*)/$ /$1 permanent;

        location / {
            error_page 418 = @app;
            recursive_error_pages on;

            if ($request_method != GET) {
                return 418;
                # proxy_pass http://0.0.0.0:3000;
            }

            root /projects/rails_full_page_cache/public;
            index index.html index.htm;
            gzip_static on;

            # try_files /out/$uri/index.html /out/$uri.html /out/$uri/ /out/$uri $uri $uri/ @app;
            try_files /cache/$uri.html $uri @app;

            # try_files /out/$uri/index.html /out/$uri /out/$uri/ $uri $uri/ @app;
        }

        location @app {
            proxy_pass http://0.0.0.0:3000;
            proxy_set_header  Host $host;
            proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header  X-Forwarded-Proto $scheme;
            proxy_set_header  X-Forwarded-Ssl on; # Optional
            proxy_set_header  X-Forwarded-Port $server_port;
            proxy_set_header  X-Forwarded-Host $host;
        }

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }

    include servers/*;
}
```
