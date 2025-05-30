Salut! My name is Jose Miguel Vazquez Mendez, and this wordpress project, running on nginx, mysql, phpmyadmin and php, to demonstrate how to run a simple wordpress docker build with good practices, that are to be expected in production builds.

Anyways, with that out of the way, the assesment requires me to write a README explaining:

a) How to run the service
b) A misconfiguration
c) What security controls I implemented
d) What is the "vulnerability" and how to fix it

So, lets dive in!

a) how to run the service:

You need:
a.- docker: I ran this thing on debian, so a lot of the configs here might need further tinkering if you're trying to run it through another linux distro, windows or mac.
b.- firewalld or some sort of virtual firewall so the rules make sense
c.- python3, pip and psutil
d.- your own SSL certificates in case the ones provided in the /cert/ folder dont work.
e.- at least 2gbs of space for the entire project after its done compiling

1.- A misconfiguration: the phpmyadmin portal being openly reachable

Lets assume for a moment that the docker image is mounted on an actual web server of some sort and available to the internet for anyone to reach. There are several issues with this:

a.- You shouldn't be able to reach this in first place, unless you're the admin
b.- The database and API is exposed to SQL injections

We can easily create a .htaccess file in the phpmyadmin folder and only allow the desired IP addresses to reach it.

It looks like this:

Order Deny, Allow
Deny from All
Allow from 172.18.0.3

where 172.18.0.3 is my IP address assigned to docker's bridge to my network card.

Next step is to, if they manage to access the portal, put another wall in front so they require another password to login. In the .htaccess file, its as simple as writing the following:

Admin1234 -c chemi

Now we must protect the folder phpmyadmin, which is still straight forward:

AuthUserFile ~/Documents/IT_support_3/phpmyadmin
AuthType Basic
AuthName "secret"
Require valid-user

It should be noted the path for authuserfile needs to be full. In this case, I'm running debian on a partitioned disk, so I use the root symbol ~.

In order to tell phpmyadmin which file we want to protect, we can use a straight forward html-esque tag to enclose it and let phpmyadmin know which user, or users, can access it:

<Files "index.html">
  Require valid-user
</Files>


2.- sql injections:

Now, in case the hacker can bypass all of the aforementioned and still get to the admin page, how can we avoid SQL injections so he can only, in the worst case scenario,
see the admin page but not be able to get anything out of the database? Well, the root of all sql injections is that they rely on mishandling the input when  creating an SQL statement, we have created a safe way to pass any "raw" queries into the database. Its as simple as logging into the mysql bash and running this thing:

ENCODED=$(echo $1 | base64); echo "SELECT * FROM T WHERE V=FROM_BASE64('$ENCODED');" | mysql

In reality, we rarely if ever interact directly with the actual database. With PHP for instance we use PDOs, which encapsulate the query so it cannot be modified or overseen in any way.

3.-  777 and read-write permissions in a "rootless" environment

Out of lack of time and to meet a deadline, I was forced to install sudo in the rootless nginx, use root as user and write all directories and files with either 777 or full read/write permissions. This is obviously bad practice, and in production you create users and usergroups with their own corresponding permissions. If I had more time, I would go back and rewrite the code so it doesn't require this. 

I did my best to make this service as stripped down of junk processes and privileges as possible, if you try to do anything inside the containers themselves, even send a ping to the internet, it will not allow you to. However, there is no such thing as too much security and I could further improve this, if given more time.
