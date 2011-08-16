class BigfishPaymentGenerator < Rails::Generator::NamedBase

  LIB_DIR = File.join("..", "..", "..", "lib")

  def manifest
    record do |m|
      unless options[:skip_migration]
        m.migration_template 'create_providers.rb', File.join('db', 'migrate'), :migration_file_name => 'create_bigfish_payment_providers'
        m.sleep 1
        m.migration_template 'create_currencies.rb', File.join('db', 'migrate'), :migration_file_name => 'create_bigfish_payment_currencies'
        m.sleep 1
        m.migration_template 'create_transactions.rb', File.join('db', 'migrate'), :migration_file_name => 'create_bigfish_payment_transactions'
        m.sleep 1
        m.migration_template 'create_transaction_logs.rb', File.join('db', 'migrate'), :migration_file_name => 'create_bigfish_payment_transaction_logs'
      end

      unless options[:skip_tasks]
        m.directory "lib/tasks"
        m.file File.join(LIB_DIR, "tasks", "bigfish_payment.rake"), File.join("lib", "tasks", "bigfish_payment.rake")
      end

      unless options[:skip_configuration]
        m.file File.join(LIB_DIR, "config", "config_loader.rb"), File.join("config", "initializers", "bigfish_payment.rb")
        m.file File.join(LIB_DIR, "config", "config.yml"), File.join("config", "bigfish_payment.yml")
      end
    end
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-migration", "Don't generate a migrations") do |value|
      options[:skip_migration] = value
    end

    opt.on("--skip-tasks", "Don't add Rake tasks to lib/tasks") do |value|
      options[:skip_tasks] = value
    end

    opt.on("--skip-configuration", "Don't add config initializer to config/initializers") do |value|
      options[:skip_configuration] = value
    end
  end

  protected

    def banner
      %{Usage #{$0} #{spec.name}\nCreates the migrations for the models}
    end

end
