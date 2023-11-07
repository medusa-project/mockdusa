# Keep this version in sync with .ruby-version and Gemfile!
FROM ruby:3.2.2-slim

RUN apt-get update && apt-get install -y \
  build-essential \
  curl \
  git

RUN mkdir app
WORKDIR app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

# Copy everything else except whatever is listed in .dockerignore.
COPY . ./

EXPOSE 4567

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "4567"]
