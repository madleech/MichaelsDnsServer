FROM ruby:2.3-onbuild

MAINTAINER Michael Adams <docker@michaeladams.org>

VOLUME ["/usr/src/app/config"]

COPY "config" "/usr/src/app/config"

WORKDIR "/usr/src/app"

CMD ["bundle", "exec", "rake", "run"]
