# FROM node:alpine3.12
# WORKDIR /validator-frontend
# COPY ./build .
# RUN npm i serve -g
# CMD ["serve", "-s", "-l", "8081"]

# stage 1
FROM node:16-alpine AS builder
RUN apk add --update yarn
RUN mkdir /app
WORKDIR /app
COPY ./jumia_phone_validator/validator-frontend /app/
RUN pwd && ls
RUN yarn install
RUN yarn build

# Stage 2
FROM nginx:1.14.2-alpine
COPY --from=builder /app/build /usr/share/nginx/html
COPY --from=builder /app/nginx.conf /etc/nginx/conf.d/default.conf
RUN pwd && ls
EXPOSE 80
CMD [ "nginx", "-g", "daemon off;" ]
