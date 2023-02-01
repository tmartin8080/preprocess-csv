import Config

config :app, :user_import_preprocessor, App.Importing.Users.PreprocessCSV

import_config "#{Mix.env()}.exs"
