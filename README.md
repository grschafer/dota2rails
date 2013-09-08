# dota2rails

## What is it

This is a repo where I will experiment with the Steam WebAPI and Dota2
replay analysis and stats, along with Rails and backend/frontend tools and
libraries that I am currently unfamiliar with. I hope this will eventually
result in some valuable tool or resource for the Dota2 community such as has
been accomplished by [datdota][datdota], [dotabuff][dotabuff], etc.

## How to get it working

Here is a walkthrough I wrote while making this: <http://grschafer.com/guides/2013/09/07/steam-openid-and-webapi-with-rails/>

1. Clone the repo

2. `bundle install` to pull gems (omniauth-steam, figaro)

3. Run `rake figaro:install` to generate `config/application.yml` or rename the
existing `config/application.example.yml` and enter your
[steam web api key][steamkey] and Rails app secret key (from running `rake
secret`)

4. Run `rails server` to see it working locally

## To Deploy to Heroku

5. Login to Heroku and create the Heroku application:

    ```bash
    $ heroku login
    $ heroku create
    ```

6. Set Heroku environment variables, either by running `rake figaro:heroku`
(though that didn't work for me due to some lurking ActiveRecord config) or by
running the following with your api key and app secret:

    ```bash
    $ heroku config:add STEAM_WEB_API_KEY='234F789DC78E6A88B987AD87F00F'
    $ heroku config:add SECRET_TOKEN='904150a195ef13012705d0c15751b333b2b79cb1678ffe4191d29635d0c57175ea7354b8f4c3290b1085363b7eb546b7d49ca7e40bebee3dced5dc9524f4cbe7'
    ```

7. Push the app to heroku and it should deploy successfully:

    ```bash
    $ git push heroku master
    $ heroku open
    ```

Let me know if you encounter any issues!

More detailed instructions can be found at the afore-linked walkthrough: <http://grschafer.com/guides/2013/09/07/steam-openid-and-webapi-with-rails/>



[datdota]: http://www.datdota.com/
[dotabuff]: http://dotabuff.com/
[steamkey]: http://steamcommunity.com/dev/apikey
