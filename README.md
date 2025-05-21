Salut! My name is Jose Miguel Vazquez Mendez, and this wordpress project, running on nginx, mysql, phpmyadmin and php, is the test given to me for admission for a IT support job in france. If you, the recruiter, are reading this, then you can acquire a copy of my CV (both in english and french) in the /docs/ folder! The answers to the questionnaire were sent to my recruiter's email. I also have a document where I explain, step by step, how I created the project.

Anyways, I leave my contact here just so its easier to reach out in case I do make it to the next part of the interview:

email: jose.vqz.mdz@gmail.com
phone: +523541090470

Anyways, with that out of the way, the assesment requires me to write a README explaining:

a) A misconfiguration that can be exploited
b) How to run the service
c) What security controls I implemented
d) What is the "vulnerability" and how to fix it

So, lets dive in!

a) A misconfiguration: the phpmyadmin portal being openly reachable

Lets assume for a moment that the docker image is mounted on an actual web server of some sort and available to the internet for anyone to reach. There are several issues with this:

1.- You shouldn't be able to reach this in first place, unless you're the admin
2.- It has no limit to how many tries you have, making it a bruteforcer's golden opportunity to hack his way into you
3.- Shows the IP of the service itself, further compromising how the container is managed in first place.

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

Now, in case the hacker can bypass all of the aforementioned and still get to the admin page, how can we kick him once he fails 3 times to log in? We are going to use fail2ban, a firewall library for linux, which will be configured in the docker host.

W