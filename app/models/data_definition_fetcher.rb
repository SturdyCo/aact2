require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

class DataDefinitionFetcher
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
  APPLICATION_NAME = 'Google Sheets API Ruby Quickstart'
  CLIENT_SECRETS_PATH = 'client_secret.json'
  CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                               "sheets.googleapis.com-ruby-quickstart.yaml")
  SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY

  def self.get_spreadsheet_values(id:)
    service = Google::Apis::SheetsV4::SheetsService.new
    service.authorization = new.authorize
    sheets = service.get_spreadsheet(id, include_grid_data: true).sheets

    sheets.flat_map { |sheet| sheet.data.first.row_data }
          .flat_map { |row| row.values }
          .flat_map { |value| value.effective_value.try(:string_value) }
  end

  ##
  # Ensure valid credentials, either by restoring from the saved credentials
  # files or intitiating an OAuth2 authorization. If authorization is required,
  # the user's default browser will be launched to approve the request.
  #
  # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
  def authorize
    FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

    client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'])
    token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(
      client_id, SCOPE, token_store)
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(
        base_url: OOB_URI)
      puts "Open the following URL in the browser and enter the " +
        "resulting code after authorization"
      puts url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI)
    end
    credentials
  end
end
