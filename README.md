# Pitahaya-CMS

Pitahaya CMS is a simple Content Management System (CMS) for small sites. Pitahaya-CMS is based on Mojolicious Web Framework and uses PostgreSQL as database backend.

If you want to contribute feel free to clone this repository and send pull requests.
If you want to talk, feel free to join pitahaya's irc channel on irc.freenode.net #pitahaya-cms.

## Internal structure

Pitahaya CMS has 2 main objects. One is called *Site* and the other is *Page*. A *Site* contains many *Pages*. The *Pages* are structured inside a tree. Internally Pitahaya uses a Nested-Set structure.

### Site

As said above, Sites contains Pages. You can think of a site like a virtual host representing the content of a domain. This is why you can manage multiple domains with one CMS installation.

### Page

A page always belong to one site, it is not possible that one page belongs to many sites. Every page is stored as a single entity inside PostgreSQL. It is possible to extend pages with own fields. These fields gets stored inside a PostgreSQL *jsonb* field.

Every page has a so called *type*. With such a type it is possible to add special functionality to it. For example to create a search, a sitemap or a special formula. Types are perl classes with methods to react to the different HTTP verbs like GET, POST, PUT, DELETE, ....

## Installation

Currently there is no installation routine, but you can just clone the git repository.

```
git clone https://github.com/krimdomu/pitahaya-cms.git
```

## Create a new Project

After you have installed pitahaya you can create a new project in a directory of your choice.

```
/path/to/pitahaya/bin/pitahaya admin project --name my_project
```

This will create the directory *my_project* with an initial directory structure.

### Create a initial configuration file

Before you can start initializing the database and creating sites you have to create the configuration file.

For this, change into your projects directory and execute:

```
bin/pitahaya admin config --host db-host --schema db-name --user db-user --password db-password --search_host sphinx-host --search_index sphinx-index
```

This will create a file *pitahaya.conf* inside your project root directory. You can tweak this file if you need this.

### Initialize the database

After you have created your configuration file, you can initialize the database with the following command:

```
bin/pitahaya admin db --init
```

### Create your first site

Now it is time to create your first site.

```
bin/pitahaya admin site --create --name example.org --skin example.org
```

## Starting the Application Server

After you created the first site, you can start the application server.

```
bin/pitahaya daemon
```

This will start a development server on port 3000.

## Login into Admin-Area


Now you can login into the admin area with the following url: http://localhost:3000/admin/login

You can login with the default user *admin* with the password *admin*. Please change this password before you go live ;-)



