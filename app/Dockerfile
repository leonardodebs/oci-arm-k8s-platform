FROM nginx:alpine

LABEL maintainer="plataforma@empresa.com"
LABEL description="Nginx demo app for OCI ARM Kubernetes Platform"

ENV TZ=America/Sao_Paulo

RUN apk add --no-cache tzdata curl

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html
COPY health.html /usr/share/nginx/html/health.html

USER nginx

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/healthz || exit 1

CMD ["nginx", "-g", "daemon off;"]