#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'lib/jbox_database'

##################
##  GET PARAMS  ##
##################

def usage
  puts <<-EOF

jbox_database [OPTION] ... DIR

  This script allows to load/dump database into the DIR passed in argument.
  Database connexion infos *must* be passed through ENV vars.

  -h, --help                 Show this help
  -m, --migrate              Migrate database with base SQL dump
  -d, --dump                 Dump database to current dir
  --update-admin-password    Update Admin user password (Prestashop)
  --update-domain-name       Update domain name (Prestashop)

  DIR: The directory where to find database migrations / dump database

EOF
  exit 0
end

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--migrate', '-m', GetoptLong::NO_ARGUMENT  ],
  [ '--dump', '-d', GetoptLong::NO_ARGUMENT  ],
  [ '--update-admin-password', GetoptLong::NO_ARGUMENT  ],
  [ '--update-domain-name', GetoptLong::NO_ARGUMENT  ]
)

action = nil

begin
  opts.each do |opt, arg|
    case opt
    when '--help'
      usage
    when '--migrate'
      action = :migrate
    when '--dump'
      action = :dump
    when '--update-admin-password'
      action = :update_password
    when '--update-domain-name'
      action = :update_domain
    end
  end
rescue GetoptLong::InvalidOption => e
  usage
end

if ARGV.length != 1
  puts 'Missing dir argument (try --help)'
  exit 0
end

app_dir = ARGV.shift
app_dir = File.expand_path(app_dir)

if !Dir.exists?(app_dir)
  puts "Project dir '#{app_dir}' does not exist, exiting ..."
  exit 1
end

JboxDatabase.execute!(action, app_dir)
