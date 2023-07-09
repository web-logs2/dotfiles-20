FROM nginx:alpine
RUN wget https://github.com/mayswind/AriaNg/releases/download/1.3.6/AriaNg-1.3.6.zip \
    && unzip *.zip -o -d /usr/share/nginx/html/ui \
    && find /usr/share/nginx/html -type f -size +1k | egrep "\.(js|css|html|svg)$" | \
        xargs -I {} sh -c 'gzip --best -c "{}" > "{}".gz && echo "{}.gz"'
COPY ./nginx.conf /etc/nginx/nginx.conf