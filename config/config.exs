use Mix.Config

config :app, App.Importing.Users.PreProcessor,
 csv_writer: App.Importing.Users.PreProcessor

import_config "#{Mix.env()}.exs"
