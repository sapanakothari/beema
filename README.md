# beema
rails full-stack app Vehicle Fleet and customer management user story

This README would normally document whatever steps are necessary to get the
application up and running.

* Ruby version
    ruby-2.7.4

* Postgres
    postgresql-11

* Redis
    redis 4


* System dependencies

    1. To install dependencies use rvm to create a gemset
    
    ```
       $ rvm gemset use beem --create
       $ rvm-prompt
         ruby-2.7.4@beema
    ```
    
    2. We've now created an isolated environment to install our dependencies. Let's
       install our dependency manager
       
    ```
        $ gem install bundler
        $ bundle --version
          Bundler version 2.1.4

    ```

    3. Install dependencies

    ```
        $ bundle install
    ```

    4. Create databases. This creates our development and test databases

    ```
        $ cp config/database.yml.sample config/database.yml
        $ rails db:prepare RAILS_ENV=development
        $ rails db:prepare RAILS_ENV=test
    ```

    5. Migrate databases

    ```
        $ rails db:migrate RAILS_ENV=development
        $ rails db:test:prepare OR rails db:migrate RAILS_ENV=test
    ```

    6. Ensure redis is running (not required for csv story)
    7. Install direnv and create .envrc file in the application root to install development env specific configurations
           Follow directions here https://direnv.net/
    ```
        # local configs
        export DB_URL=postgres://sapanakothari@localhost/beema_development
        export RAILS_ENV=development    
    ```

    8. Run tests to verify everything is working
    
    ```
        $ rspec spec/
    ```
