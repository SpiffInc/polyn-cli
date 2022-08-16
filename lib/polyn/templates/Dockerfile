FROM ruby:3.0.4-alpine3.15 as base
RUN apk add terraform
RUN gem install polyn-cli
WORKDIR /events
ADD events ./events
ADD tf ./tf
ENV POLYN_ENV='production'
RUN polyn tf_init
CMD polyn up