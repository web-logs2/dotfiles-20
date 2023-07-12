{{- $env := .Env -}}
{{- $external_https_port := $env.HTTPS_PORT -}}
{{- $external_http_port := $env.HTTP_PORT -}}

{{- range .Servers }}
# {{ .Host }}/
{{ if .UpStream }}
upstream {{ .Host }} {
    server {{ .UpStream }};
}
{{ end }}
server {
    server_name {{ .Host }};
    listen {{ $external_http_port }} ;
    access_log /var/log/nginx/access.log vhost;
    # Do not HTTPS redirect Let's Encrypt ACME challenge
    location ^~ /.well-known/acme-challenge/ {
        auth_basic off;
        auth_request off;
        allow all;
        root /usr/share/nginx/html;
        try_files $uri =404;
        break;
    }
    location / {
        return 301 https://$host:8443$request_uri;
    }
}
server {
    server_name {{ .Host }};
    http2 on;
    access_log /var/log/nginx/access.log vhost;
    listen {{ $external_https_port }} ssl ;
    ssl_session_timeout 5m;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;
    ssl_certificate /etc/nginx/certs/home.lubui.com.crt;
    ssl_certificate_key /etc/nginx/certs/home.lubui.com.key;
    set $sts_header "";
    if ($https) {
        set $sts_header "max-age=31536000";
    }
    add_header Strict-Transport-Security $sts_header always;
    {{- if .UpStream }}
    location / {
        {{- if .EnableSSO }}
        satisfy any;
        allow 127.0.0.0/8;
        allow 192.168.0.0/16;
        allow 172.16.0.0/12;
        allow 10.0.0.0/8;
        deny  all;
        auth_request /auth;
        error_page 401 = @error401;
        {{- end }}
        proxy_pass http://{{ .Host }};
        set $upstream_keepalive false;
    }
    {{ end }}
    {{- if .LocationOfHtml }}
    location {{ .LocationOfHtml }} {
        gzip_static on;
        root /usr/share/nginx/html/{{ .Host }};
        try_files $uri $uri/ /index.html;
    }
    {{ end }}
    {{- if .EnableSSO }}
    location /auth {
        internal;
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";
        proxy_pass {{ $env.SSO_INTERNAL_AUTH_ADDR }};
    }
    location @error401 {
        add_header Set-Cookie "redirect=$scheme://$http_host$request_uri;Domain={{ $env.SSO_COOKIE_DOMAIN }};Path=/;Max-Age=3000";
        return 302 {{ $env.SSO_LOGIN_ADDR }};
    }
    {{- end }}
}
{{ end }}