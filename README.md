# Allegro crawler

Hi! Welcome to the allegro crawler. The application crawls page https://sklepklocki.pl. 
You can run this program to collect the most important data from the page based on the key words and save them in the database.

## How to set up and run this app locally

1. Download the application using ```git clone https://github.com/PiotrStoklosa/allegro-crawler```
2. Go to the project source code: ```cd allegro-crawler```
3. Download required dependencies ```bundle install```
4. Run the application ```ruby crawler.rb <keywords>```
5. Data will be displayed in your console and saved in the table product in database 'sqlite://lego.db' 

## Technologies

- Ruby
- Nokogiri
- SQLite
