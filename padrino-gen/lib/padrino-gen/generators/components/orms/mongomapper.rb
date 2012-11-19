MONGO = (<<-MONGO) unless defined?(MONGO)
require 'yaml'

MongoMapper.setup(YAML.load_file(Padrino.root('config','database.yml')), PADRINO_ENV)
MONGO

YML = (<<-YML) unless defined?(YML)
defaults: &defaults
  adapter: mongodb
  host: localhost
  port: 27017

development:
  <<: *defaults
  database: !NAME!_development

test:
  <<: *defaults
  database: !NAME!_test

production:
  <<: *defaults
  database: !NAME!_production
YML

def setup_orm
  require_dependencies 'mongo_mapper'
  require_dependencies 'bson_ext', :require => 'mongo'
  require_dependencies('SystemTimer', :require => 'system_timer') if RUBY_VERSION =~ /1\.8/ && (!defined?(RUBY_ENGINE) || RUBY_ENGINE == 'ruby')
  create_file("config/database.rb", MONGO.gsub(/!NAME!/, @app_name.underscore))
  create_file("config/database.yml", YML.gsub(/!NAME!/, @app_name.underscore))
end

MM_MODEL = (<<-MODEL) unless defined?(MM_MODEL)
class !NAME!
  include MongoMapper::Document

  # key <name>, <type>
  !FIELDS!
  timestamps!
end
MODEL

# options => { :fields => ["title:string", "body:string"], :app => 'app' }
def create_model_file(name, options={})
  model_path = destination_root(options[:app], 'models', "#{name.to_s.underscore}.rb")
  field_tuples = options[:fields].map { |value| value.split(":") }
  column_declarations = field_tuples.map { |field, kind| "key :#{field}, #{kind.underscore.camelize}" }.join("\n  ")
  model_contents = MM_MODEL.gsub(/!NAME!/, name.to_s.underscore.camelize)
  model_contents.gsub!(/!FIELDS!/, column_declarations)
  create_file(model_path, model_contents)
end

def create_model_migration(filename, name, fields)
  # NO MIGRATION NEEDED
end

def create_migration_file(migration_name, name, columns)
  # NO MIGRATION NEEDED
end
