# FROM node:alpine3.12
# WORKDIR /validator-frontend
# COPY ./build .
# RUN npm i serve -g
# CMD ["serve", "-s", "-l", "8081"]

# stage 1
FROM node:16-alpine as builder
RUN apk add --update yarn
RUN mkdir /app
WORKDIR /app
COPY /validator-frontend /app/
RUN cd validator-frontend && yarn install
RUN yarn build
EXPOSE 8081

# Stage 2
FROM nginx:1.14.2-alpine
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=builder /validator-frontend/build .
ENTRYPOINT [ "nginx", "-g", "daemon off;" ]