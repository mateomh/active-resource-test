FROM ruby:3.1.2-alpine

# Dependencies
RUN apk add --update --no-cache build-base nodejs yarn tzdata ncurses bash git openjdk8
RUN apk add --no-cache chromium openssh curl-dev postgresql libpq-dev
RUN apk add --no-cache libxml2-dev pixman tiff giflib libpng lcms2 libjpeg libcurl
RUN apk add --no-cache fontconfig freetype libgomp
RUN apk add --no-cache msttcorefonts-installer poppler-utils
RUN update-ms-fonts

# ARM Dependecies
RUN apk add --no-cache gcompat

# Bundler & app setup
ENV LANG=C.UTF-8 BUNDLE_JOBS=3 BUNDLE_RETRY=3 BUNDLE_WITHOUT=production:staging
ENV APP_PATH /app
ENV PATH $APP_PATH/bin:$PATH

# Bundle install
WORKDIR $APP_PATH
COPY ../Gemfile .
COPY ../Gemfile.lock .
COPY ../vendor vendor
RUN gem install bundler -v '~>2.4.21'
RUN bundle install

# Copy application
COPY ../ .

# Compile assets
RUN bundle exec bootsnap precompile --gemfile app/ lib/

# Startup
EXPOSE 3000
