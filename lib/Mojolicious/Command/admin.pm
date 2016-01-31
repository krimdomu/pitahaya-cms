package Mojolicious::Command::admin;

use Mojo::Base 'Mojolicious::Command';
use Getopt::Long qw(GetOptionsFromArray);
use DBIx::Class::DeploymentHandler;

use File::Path qw(make_path);
use FindBin;
use File::Basename qw(dirname basename);
use Data::Dumper;

use 5.010;

has description => 'Pitahaya Commands';
has usage => sub { shift->extract_usage };

my ( $dh, $from_version, $to_version, $version );

sub run {
    my ( $self, $command, @args ) = @_;

    if ( !$command || $command eq "help" ) {
        print q|
Commandas for pitahaya admin:
  project                         create a new project
    --name project_name
    
  config                          create an initial configuration
    --host db_host
    --schema db_name
    --user db_user
    --password db_password
    --search_host search_host
    --search_index search_index
    
  db                              manage the database
    --init                        initialize the tables
    --update                      update schema to a new version
    
  site                            manage sites
    --create                      create a new site
      --name site_name
      --skin skin_name
    --create_lang                 create a new language for site_name
      --for site_name
      --name language
    --create_content_type         create a new content-type for site_name
      --for site_name
      --name content-type-name
      --class class               the class name which should be loaded to parse
  
  virtual_host                    
    --add                         add a virtualhost to a site
    --rm                          remove a virtualhost from a site
    --site site_name
    --name virtual_host
      
  page_type                       manage page types
    --create                      create a new page type
      --site site_name
      --type type_name
      [--description desc]
    |;
        print "\n";

        return;
    }

    if ( $command eq "virtual_host" ) {
        my ( $name, $site, $add, $rm );
        GetOptionsFromArray \@args,
          's|site=s' => sub { $site = $_[1] },
          'n|name=s' => sub { $name = $_[1] },
          'a|add'    => sub { $add  = $_[1] },
          'r|rm'     => sub { $rm   = $_[1] };

        if ($add) {
            if ( !$name ) {
                $self->app->log->error(
"You have to specify the name of the name of the virtual host."
                );
                return;
            }

            if ( !$site ) {
                $self->app->log->error(
                    "You have to specify the name of the site.");
                return;
            }

            my $site_o =
              $self->app->db->resultset("Site")->search_rs( { name => $site } )
              ->next;

            if ( !$site_o ) {
                $self->app->log->error("No site $site found.");
                return;
            }

            my $vhost = $self->app->db->resultset("VirtualHost")->create(
                {
                    site_id => $site_o->id,
                    name    => $name,
                }
            );
        }

        if ($rm) {
            if ( !$name ) {
                $self->app->log->error(
"You have to specify the name of the name of the virtual host."
                );
                return;
            }

            if ( !$site ) {
                $self->app->log->error(
                    "You have to specify the name of the site.");
                return;
            }

            my $site_o =
              $self->app->db->resultset("Site")->search_rs( { name => $site } )
              ->next;

            if ( !$site_o ) {
                $self->app->log->error("No site $site found.");
                return;
            }

            my @vhost = $site_o->virtual_hosts(
                {
                    name => $name,
                }
            );

            if ( !$vhost[0] ) {
                $self->app->log->error("No virtual host found.");
                return;
            }

            $vhost[0]->delete;
        }

    }

    if ( $command eq "page_type" ) {
        my ( $name, $site, $desc, $create );
        GetOptionsFromArray \@args,
          's|site=s'        => sub { $site   = $_[1] },
          't|type=s'        => sub { $name   = $_[1] },
          'd|description=s' => sub { $desc   = $_[1] },
          'c|create'        => sub { $create = $_[1] };

        if ($create) {
            if ( !$name ) {
                $self->app->log->error(
                    "You have to specify the name of the page type.");
                return;
            }

            if ( !$site ) {
                $self->app->log->error(
                    "You have to specify the name of the site.");
                return;
            }

            my $site_o =
              $self->app->db->resultset("Site")->search_rs( { name => $site } )
              ->next;

            if ( !$site_o ) {
                $self->app->log->error("No site $site found.");
                return;
            }

            my $ref = {
                site_id     => $site_o->id,
                name        => $name,
                description => ( $desc || '' ),
            };

            my $new_type = $self->app->db->resultset("PageType")->create($ref);

            $self->app->log->info(
                "New page type created with id: " . $new_type->id );
        }
    }

    if ( $command eq "config" ) {
        my ( $db_host, $db_schema, $db_user, $db_pass, $search_host,
            $search_index );
        GetOptionsFromArray \@args,
          'h|host=s'         => sub { $db_host      = $_[1] },
          's|schema=s'       => sub { $db_schema    = $_[1] },
          'u|user=s'         => sub { $db_user      = $_[1] },
          'p|password=s'     => sub { $db_pass      = $_[1] },
          'f|search_host=s'  => sub { $search_host  = $_[1] },
          'i|search_index=s' => sub { $search_index = $_[1] };

        if ( !$db_host ) {
            $self->app->log->error("You have to specify the database host");
            exit 1;
        }

        if ( !$db_schema ) {
            $self->app->log->error("You have to specify the database schema");
            exit 1;
        }

        if ( !$db_user ) {
            $self->app->log->error("You have to specify the database user");
            exit 1;
        }

        if ( !$db_pass ) {
            $self->app->log->error("You have to specify the database password");
            exit 1;
        }

        if ( !$search_host ) {
            $self->app->log->error("You have to specify the search host");
            exit 1;
        }

        if ( !$search_index ) {
            $self->app->log->error("You have to specify the search index");
            exit 1;
        }

        open( my $fh, ">", "pitahaya.conf" )
          or die("Can't write pitahaya.conf: $!");
        print $fh qq~
{
  database => {
    host     => "$db_host",
    schema   => "$db_schema",
    username => "$db_user",
    password => "$db_pass",
  },
  tmp_dir  => "./tmp",
  data_dir => "./data",
  session  => {
    key => 'pitahaya.cms'
  },
  export => {
    dir => "./export",
  },
  search => {
    sphinx => {
      host  => "$search_host",
      index => "$search_index",
    },
  },
}
~;

        close($fh);

        $self->app->log->info(
            "Basic configuration file written (pitahaya.conf).");
    }

    if ( $command eq "project" ) {
        my ($project);
        GetOptionsFromArray \@args, 'n|name=s' => sub { $project = $_[1] };

        if ( !$project ) {
            $self->app->log->error(
                "You have to specify the name of the project");
            exit 1;
        }

        make_path "$project/bin";
        make_path "$project/tmp";
        make_path "$project/data";
        make_path "$project/export";

        symlink "$FindBin::Bin/$FindBin::Script",
          "$project/bin/" . $FindBin::Script;

        $self->app->log->info("New Pitahaya project created.");
        $self->app->log->info(
"You can now start with your project by switchting to $project directory."
        );
        $self->app->log->info(
            "Please create a configuration and initialize the database.");
        $self->app->log->info("");
        $self->app->log->info("To create a configuration file use:");
        $self->app->log->info(
"  bin/pitahaya admin config --host db_host --schema db_schema --user db_user --password db_pass"
        );
        $self->app->log->info("To initialize the database use:");
        $self->app->log->info("  bin/pitahaya admin db --init");
        $self->app->log->info("");
        $self->app->log->info("To create a new site use:");
        $self->app->log->info(
"  bin/pitahaya admin site --create --name your-site-name --skin your-skin-name"
        );
    }

    if ( $command eq "db" ) {

        if ( !-f "pitahaya.conf" ) {
            $self->app->log->error("No pitahaya.conf found.");
            exit 1;
        }

        my $schema                 = $self->app->schema;
        my $deployment_handler_dir = "$FindBin::RealBin/../db_upgrades";

        my ( $init, $update );
        GetOptionsFromArray \@args,
          'i|init'   => sub { $init   = $_[1] },
          'u|update' => sub { $update = $_[1] };

        $dh = DBIx::Class::DeploymentHandler->new(
            {
                schema           => $schema,
                script_directory => $deployment_handler_dir,
                databases        => 'PostgreSQL',
                force_overwrite  => 1,
            }
        );

        die "We only support positive integers for versions."
          unless $dh->schema_version =~ /^\d+$/;
        if ($init) {
            install();

            $self->app->log->info(
                "Database initialize. This database is empty.");
            $self->app->log->info("To continue you have to create a new site.");
            $self->app->log->info("");
            $self->app->log->info("To create a new site use:");
            $self->app->log->info(
"  bin/pitahaya admin site --create --name your-site-name --skin your-skin-name"
            );
        }

        if ($update) {
            upgrade();
        }
    }

    if ( $command eq "site" ) {
        my ( $name, $skin, $create, $create_lang, $for, $create_content_type, $class );
        GetOptionsFromArray \@args,
          'n|name=s'      => sub { $name        = $_[1] },
          's|skin=s'      => sub { $skin        = $_[1] },
          'l|create_lang' => sub { $create_lang = $_[1] },
          'f|for=s'       => sub { $for         = $_[1] },
          'create_content_type' => sub { $create_content_type = $_[1] },
          'class=s'       => sub { $class        = $_[1] },
          'c|create'      => sub { $create      = $_[1] };

        if ($create_content_type) {
            $self->app->log->error(
                "You have to specify the name of the site (for)")
              if ( !$for );
            $self->app->log->error(
                "You have to specify the class name that should parse the content (class)")
              if ( !$class );
            $self->app->log->error(
                "You have to specify the content type name (name)")
              if ( !$name );
        
            $self->app->log->info("Creating new content type $name for: $for");

            my $site_o =
              $self->app->db->resultset("Site")->search_rs( { name => $for } )
              ->next;

            if ( !$site_o ) {
                $self->app->log->error("No site $for found.");
                return;
            }

            my $content_type_o = $self->app->db->resultset("ContentType")
              ->create( { name => $name, site_id => $site_o->id, class => $class } );

            if( $content_type_o ) {              
              $self->app->log->info(
                  "Created new content type with id: " . $content_type_o->id );
            }
            else {
              $self->app->log->error("Failed creating new content type for site $for.");
              exit 1;
            }
              
        }

        if ($create_lang) {
            $self->app->log->error(
                "You have to specify the name of the site (for)")
              if ( !$for );
            $self->app->log->error(
                "You have to specify the name of the language (name)")
              if ( !$name );

            $self->app->log->info("Creating new language $name for: $for");

            my $site_o =
              $self->app->db->resultset("Site")->search_rs( { name => $for } )
              ->next;

            if ( !$site_o ) {
                $self->app->log->error("No site $for found.");
                return;
            }

            $skin ||= "$name." . $site_o->skin;

            my $lang_site_o = $self->app->db->resultset("Site")
              ->create( { name => $name . ".$for", skin => $skin } );

            if ($lang_site_o) {
                $self->app->log->info(
                    "Created new site with id: " . $lang_site_o->id );

                my @page_types_base  = $site_o->page_types;
                my @media_types_base = $site_o->media_types;
                my @pages_base       = $site_o->pages;
                my @medias_base      = $site_o->medias;

                my ( @page_types, @media_types );

                for my $pt (@page_types_base) {
                    my $page_type = $pt->name;
                    $self->app->log->info("Creating page type: $page_type");

                    push @page_types,
                      $self->app->db->resultset("PageType")->create(
                        {
                            site_id => $lang_site_o->id,
                            name    => $page_type,
                        }
                      );
                }

                for my $mt (@media_types_base) {
                    my $media_type = $mt->name;
                    $self->app->log->info("Creating media type: $media_type");

                    push @media_types,
                      $self->app->db->resultset("MediaType")->create(
                        {
                            site_id => $lang_site_o->id,
                            name    => $media_type,
                        }
                      );
                }

                for my $p (@pages_base) {
                    my $data = { $p->get_columns };
                    $data->{site_id} = $lang_site_o->id;
                    $self->app->db->resultset("Page")->create($data);
                }

                for my $m (@medias_base) {
                    my $data = { $m->get_columns };
                    $data->{site_id} = $lang_site_o->id;
                    $self->app->db->resultset("Media")->create($data);
                }
                
                $self->app->log->info("Registering language to $for");

                my $lang_o = $self->app->db->resultset("Language")->create({
                  master_site_id => $site_o->id,
                  lang_site_id   => $lang_site_o->id,
                });

                $self->app->log->info(
                    "Copying data files from data/$for to data/$name.$for");
                make_path "data/$name.$for";
                system "cp -R data/$for/* data/$name.$for";

                if ( $? != 0 ) {
                    $self->app->log->error(
                        "Failed copying data files from data/$for to data/$name"
                    );
                    exit(1);
                }

                $self->app->log->info("");
                $self->app->log->info("Language $name for $for is created.");

            }

        }

        if ( $create && -f "pitahaya.conf" ) {
            $self->app->log->error("You have to specify the name of the site")
              if ( !$name );
            $self->app->log->error("You have to specify the skin of the site")
              if ( !$skin );

            $self->app->log->info("Creating new site: $name with skin: $skin");

            my $site_o = $self->app->db->resultset("Site")
              ->create( { name => $name, skin => $skin } );

            if ($site_o) {
                $self->app->log->info(
                    "Created new site with id: " . $site_o->id );

                my $user_rs = $self->app->db->resultset("User")->search()->next;
                my $user_o;
                if ( !$user_rs ) {
                    $self->app->log->info("No users found. Creating new one.");
                    $user_o = $self->app->db->resultset("User")->create(
                        {
                            username => "admin",
                            password => "admin",
                        }
                    );

                    $self->app->log->info(
                        "Created new user admin with password admin.");
                }
                else {
                    $user_o = $user_rs;
                }

                my ( @page_types, @media_types );

                for my $page_type (qw/index page/) {
                    $self->app->log->info("Creating page type: $page_type");

                    push @page_types,
                      $self->app->db->resultset("PageType")->create(
                        {
                            site_id => $site_o->id,
                            name    => $page_type,
                        }
                      );
                }

                for my $media_type (qw/index folder image object/) {
                    $self->app->log->info("Creating media type: $media_type");

                    push @media_types,
                      $self->app->db->resultset("MediaType")->create(
                        {
                            site_id => $site_o->id,
                            name    => $media_type,
                        }
                      );
                }

                $self->app->log->info("Creating root page");
                my $root_page = $self->app->db->resultset("Page")->create(
                    {
                        site_id    => $site_o->id,
                        lft        => 1,
                        rgt        => 2,
                        level      => 0,
                        hidden     => 0,
                        navigation => 1,
                        active     => 1,
                        name       => 'Home',
                        url        => 'Home',
                        type_id    => $page_types[0]->id,
                        creator_id => $user_o->id,
                    }
                );

                $self->app->log->info("Creating root media folder");
                my $root_media = $self->app->db->resultset("Media")->create(
                    {
                        site_id    => $site_o->id,
                        lft        => 1,
                        rgt        => 2,
                        level      => 0,
                        hidden     => 0,
                        active     => 1,
                        name       => 'Root',
                        url        => 'Root.html',
                        type_id    => $media_types[0]->id,
                        creator_id => $user_o->id,
                    }
                );

                $self->app->log->info( "Page " . $site_o->name . " created." );

                # create needed folders
                my $bin_path = $FindBin::Bin;
                make_path "templates/skin/$skin";
                make_path "templates/layouts/$skin";
                make_path "vendor/site/$name";
            }

            $self->app->log->info("");
            $self->app->log->info(
"Your new site is now created. You can start the application server and login to the adminarea now."
            );
            $self->app->log->info("To start the application server use:");
            $self->app->log->info("  bin/pitahaya daemon");
            $self->app->log->info("");
            $self->app->log->info(
"To log into the adminarea point your browser to http://localhost:3000/admin/login"
            );
            $self->app->log->info("  User     : admin");
            $self->app->log->info("  Password : admin");
        }
    }
}

sub prepare {
    say "running prepare_install()";
    $dh->prepare_install;

    if ( defined $from_version && defined $to_version ) {
        say
"running prepare_upgrade({ from_version => $from_version, to_version => $to_version })";
        $dh->prepare_upgrade(
            {
                from_version => $from_version,
                to_version   => $to_version,
            }
        );
    }
}

sub install {
    if ( defined $version ) {
        $dh->install( { version => $version } );
    }
    else {
        $dh->install;
    }
}

sub upgrade {
    $dh->upgrade;
}

sub database_version {
    say $dh->database_version;
}

sub schema_version {
    say $dh->schema_version;
}

1;
