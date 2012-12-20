role :web, "www.smkw.org"                          # Your HTTP server, Apache/etc
role :app, "www.smkw.org"                          # This may be the same as your `Web` server
role :db,  "www.smkw.org", :primary => true # This is where Rails migrations will run
