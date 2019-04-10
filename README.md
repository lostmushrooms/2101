# cs2102_ay1819_s2
CS2102 Database Systems: Introduction to Web Application Development

Setting up:

1. Clone this repository to your computer.

2. Navigate into the root folder using command line.

3. Run `npm install`.

4. Make a new .env file in the root folder. Copy the following two lines into the .env file and replace the parameters in square bracket with your database host information:

    DATABASE_URL=postgres://[sql username]:[sql password]@[host]:[port number]/[database name] 

    SECRET='secret' 

5. Run the /postgresql_scripts/initialization.sql script in your sql server.

6. Run `npm start` in your root directory. 

7. Open localhost:3000 with your default browser. You should see the index page.

8. If there are code corruption, please download the latest copy of code at https://github.com/lostmushrooms/2102.

