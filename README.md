# dotarecap

Note: The working title was "Dota2rails", so many pieces of this project still
bear that name.

## What is it

Dotarecap.com is my side project from Fall-Winter 2013, with the main purpose
of learning new tech (ruby/rails, coffeescript, sass, d3.js, celery with
rabbitmq, vagrant, ansible, and more). The website allows users to request or
upload Dota 2 replays, which are then parsed for critical information that is
displayed on the website. Users can scrub through the duration of parsed
replays, inspecting data such as player positions, gold, xp, k/d/a, and more,
all animated with d3.js.


## How to get it working

The entire website can be deployed with <https://github.com/grschafer/dotarecap-deploy>,
which uses vagrant and ansible. This repo only contains the rails webapp
portion of the site, which is independent from the replay-parsing backend
(alacrity), but still depends on mongodb for match/league metadata.

Project architecture/overview blogpost coming soon.

