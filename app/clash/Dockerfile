FROM dreamacro/clash-premium
RUN set -e \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories \
    && apk add --no-cache iptables inotify-tools tini \
    && wget https://github.com/haishanh/yacd/releases/download/v0.3.8/yacd.tar.xz \
    && tar xf yacd.tar.xz \
    && mv public ui
COPY scripts/* /
USER 0:2023
ENTRYPOINT ["tini","-g", "--", "/entrypoint.sh"]
