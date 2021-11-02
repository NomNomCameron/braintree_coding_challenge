## Design Decisions
I decided to use a standard ruby class that allows the logic to be applied in a separate ruby file or from the command line. This is done by checking to see if the file that executed the line_processor.rb file is the line_processor.rb file or if it's called elsewhere. This comes into play with being able to test the class in RSpec and not have to worry about the functionality of it being called directly from the command line.

The meat and potatoes of the class uses instance_variables to access the data between the different methods that are called. The ruby class itself tries to follow the service objects methodology by having a simple `call` method that gets run, while delegating different bits of logic to separate methods

## Install requirements
This project was written with Ruby 2.7.0, my ruby version manager of choice is RVM, whichever you prefer to use make sure that the terminal you'll be running the ruby script in is setup for Ruby 2.7.0

To get the dependecies (mainly RSpec) you will need to run `bundle install` to make sure that the gems in the Gemfile get run, this will be necessary if you would like to run the test suite

## How to run the code
From the terminal you can `cd` into the project directory and run `ruby line_processor.rb input.txt` or `ruby line_processor.rb < input.txt`. The script is setup to accept both a path to a file in question or to accept a stream from STDIN. The results will be output directly to STDOUT

To run the test suite, after you have run `bundle install`, you should just have to run `rspec spec/*.rb` to run all of the tests
