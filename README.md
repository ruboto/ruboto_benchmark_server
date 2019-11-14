## Welcome to the Ruboto Benchmarks Server

[[http://ruboto-startup.herokuapp.com/]]

The purpose of this project is to measure different benchmarks for Ruboto on
different configurations.  The startup benchmark has been the main focus for a
while, but now that we start measuring startup times below 4 seconds, other
benchmarks become more interesting.  One central benchmark type is the loading
and initializing of libraries and user code.

To try it with your device, install the
[Ruboto Benchmarks](https://play.google.com/store/apps/details?id=org.ruboto.benchmarks)
app on Google Play, start it, and click the **Report** button.

If there are benchmarks you would like people to run, or you want to contribute
in any way to the Ruboto project, please leave us a message as descibed on the
[Contributing](https://github.com/ruboto/ruboto/wiki/Contributing) page.

The results of the benchmark measurements are reported to and stored on this
[server at Heroku](http://ruboto-startup.herokuapp.com/).

[http://ruboto-startup.herokuapp.com/](http://ruboto-startup.herokuapp.com/)


## Maintenance

This is a pretty plain Ruby on Rails app.

To update this server, make your changes, and commit them to master.
Heroku will auto-deploy the changes.

* Make changes
* `rake test`
* `git commit -m "<your description here>"`

# Pull requests welcome!
