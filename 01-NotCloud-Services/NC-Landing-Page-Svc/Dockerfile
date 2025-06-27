# Simple Nginx Dockerfile for static site on Cloud Run
FROM nginx:1.25-alpine

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy static site files
COPY . /usr/share/nginx/html

EXPOSE 8080
ENV PORT=8080

CMD ["nginx", "-g", "daemon off;"]
